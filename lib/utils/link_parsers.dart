import 'dart:convert';

import 'package:hiddify/utils/validators.dart';

typedef ProfileLink = ({String url, String name});

// TODO: test and improve
abstract class LinkParser {
  static String generateSubShareLink(String url, [String? name]) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';

    String? newFragment = name ?? uri.fragment;
    if (newFragment.isEmpty) {
      newFragment = null;
    }

    final modifiedUri = Uri(
      scheme: uri.scheme.isEmpty ? null : uri.scheme,
      userInfo: uri.userInfo.isEmpty ? null : uri.userInfo,
      host: uri.host.isEmpty ? null : uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
      query: uri.query.isEmpty ? null : uri.query,
      fragment: newFragment,
    );
    // return 'hiddify://import/$modifiedUri';
    return '$modifiedUri';
  }

  // protocols schemas
  static const protocols = ['hiddify', 'v2ray', 'v2rayn', 'v2rayng', 'clash', 'clashmeta', 'sing-box'];

  static ProfileLink? parse(String link) {
    return simple(link) ?? deep(link);
  }

  static ProfileLink? simple(String link) {
    if (!isUrl(link)) return null;
    final uri = Uri.parse(link.trim());
    return (url: uri.toString(), name: uri.queryParameters['name'] ?? '');
  }

  static ProfileLink? deep(String link) {
    final uri = Uri.tryParse(link.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;

    // We shouldn't use uri.queryParameters directly because parsing a query string like
    // ?url=https://example.com/sub?q=1&q2=2&name=testName will parse it as:
    // url: https://example.com/sub?q=1
    // q2: 2
    // name: testName
    // Which means we lose &q2=2 from the URL. So we'll try parsing differently if there's a url parameter.

    final originalQuery = uri.query;
    final urlParamRegex = RegExp(r'url=([^&]+)(?:&|$)');
    final nameParamRegex = RegExp(r'name=([^&]+)(?:&|$)');

    String? urlFromQuery;
    String? nameFromQuery;

    final urlMatch = urlParamRegex.firstMatch(originalQuery);
    if (urlMatch != null) {
      // Decode the URL component in case it was encoded
      urlFromQuery = Uri.decodeComponent(urlMatch.group(1)!);

      // If we found a url parameter, the rest of the query might belong to the url,
      // EXCEPT for known parameters like 'name' that belong to the outer scheme.
      // A more robust way to handle this without losing URL parameters that contain &
      // is to look for where url starts, and just extract everything up to name= if present
      // or up to the end if not.

      // But a simpler approach for now is if url= is provided, it might not be properly encoded.
      // Hiddify deep links can be formed as v2ray://import/?url=URL_UNENCODED&name=NAME
      // If the URL itself contains &, the standard Uri parser breaks it.

      // Let's manually parse url= taking the rest of the string until &name= or end
      int urlStart = originalQuery.indexOf('url=') + 4;
      int nextParamStart = originalQuery.indexOf('&name=', urlStart);

      if (nextParamStart != -1) {
         urlFromQuery = Uri.decodeComponent(originalQuery.substring(urlStart, nextParamStart));
      } else {
         // Maybe name= is before url=
         urlFromQuery = Uri.decodeComponent(originalQuery.substring(urlStart));
      }
    }

    final nameMatch = nameParamRegex.firstMatch(originalQuery);
    if (nameMatch != null) {
      nameFromQuery = Uri.decodeComponent(nameMatch.group(1)!);
    }

    final queryParams = uri.queryParameters;

    switch (uri.scheme) {
      case 'hiddify':
        if (urlFromQuery != null) {
          return (url: urlFromQuery, name: nameFromQuery ?? queryParams['name'] ?? '');
        } else {
          return (url: uri.path.substring(1) + (uri.hasQuery ? "?${uri.query}" : ""), name: uri.fragment);
        }
      case 'v2ray' || 'v2rayn' || 'v2rayng' || 'clash' || 'clashmeta' || 'sing-box':
        return urlFromQuery != null ? (url: urlFromQuery, name: nameFromQuery ?? queryParams['name'] ?? '') : null;
      default:
        return null;
    }
  }
}

String safeDecodeBase64(String str) {
  try {
    return utf8.decode(base64Decode(str));
  } catch (e) {
    return str;
  }
}
