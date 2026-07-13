import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/utils/link_parsers.dart';

void main() {
  group('LinkParser', () {
    group('generateSubShareLink', () {
      test('basic sub link', () {
        expect(LinkParser.generateSubShareLink('https://example.com/sub'), 'https://example.com/sub');
      });

      test('sub link with name', () {
        expect(LinkParser.generateSubShareLink('https://example.com/sub', 'my name'), 'https://example.com/sub#my%20name');
      });

      test('sub link with existing name', () {
        expect(LinkParser.generateSubShareLink('https://example.com/sub#oldName', 'my name'), 'https://example.com/sub#my%20name');
      });

      test('sub link with only existing name', () {
        expect(LinkParser.generateSubShareLink('https://example.com/sub#oldName'), 'https://example.com/sub#oldName');
      });

      test('sub link with empty name', () {
        expect(LinkParser.generateSubShareLink('https://example.com/sub#oldName', ''), 'https://example.com/sub');
      });

      test('sub link with query', () {
        expect(LinkParser.generateSubShareLink('https://example.com/sub?test=1', 'name'), 'https://example.com/sub?test=1#name');
      });

      test('sub link with port', () {
        expect(LinkParser.generateSubShareLink('https://example.com:8080/sub?test=1', 'name'), 'https://example.com:8080/sub?test=1#name');
      });

      test('sub link with auth', () {
        expect(LinkParser.generateSubShareLink('https://user:pass@example.com/sub?test=1', 'name'), 'https://user:pass@example.com/sub?test=1#name');
      });

      test('invalid link', () {
        expect(LinkParser.generateSubShareLink(''), '');
        expect(LinkParser.generateSubShareLink('invalid'), 'invalid');
      });
    });

    group('parse simple', () {
      test('basic', () {
        expect(LinkParser.parse('https://example.com/sub'), (url: 'https://example.com/sub', name: ''));
      });
      test('with name query', () {
        expect(LinkParser.parse('https://example.com/sub?name=test'), (url: 'https://example.com/sub?name=test', name: 'test'));
      });
      test('invalid link', () {
        expect(LinkParser.parse('invalid'), null);
      });
    });

    group('parse deep hiddify schema', () {
      test('import link with direct sub link', () {
        expect(LinkParser.parse('hiddify://import/https://example.com/sub'), (url: 'https://example.com/sub', name: ''));
      });

      test('import link with direct sub link and hash name', () {
        expect(LinkParser.parse('hiddify://import/https://example.com/sub#test'), (url: 'https://example.com/sub', name: 'test'));
      });

      test('import link with query url and name', () {
        expect(LinkParser.parse('hiddify://import/?url=https://example.com/sub&name=test'), (url: 'https://example.com/sub', name: 'test'));
      });

      test('import link with query url but no name', () {
        expect(LinkParser.parse('hiddify://import/?url=https://example.com/sub'), (url: 'https://example.com/sub', name: ''));
      });

      test('import link with complex sub link query parameters (unencoded ampersand)', () {
        expect(
          LinkParser.parse('hiddify://import/?url=https://example.com/sub?query=1&query2=2&name=testName'),
          (url: 'https://example.com/sub?query=1&query2=2', name: 'testName')
        );
      });

      test('import link with complex sub link', () {
        expect(
          LinkParser.parse('hiddify://import/https://user:pass@example.com:8080/sub?query=1&query2=2#testName'),
          (url: 'https://user:pass@example.com:8080/sub?query=1&query2=2', name: 'testName')
        );
      });
    });

    group('parse deep other schemas', () {
      test('v2ray import link', () {
        expect(LinkParser.parse('v2ray://import/?url=https://example.com/sub&name=test'), (url: 'https://example.com/sub', name: 'test'));
      });
      test('v2ray import link with complex url parameter (unencoded ampersand)', () {
        expect(LinkParser.parse('v2ray://import/?url=https://example.com/sub?q=1&q2=2&name=testName'), (url: 'https://example.com/sub?q=1&q2=2', name: 'testName'));
      });
      test('clash import link', () {
        expect(LinkParser.parse('clash://import/?url=https://example.com/sub&name=test'), (url: 'https://example.com/sub', name: 'test'));
      });
      test('sing-box import link', () {
        expect(LinkParser.parse('sing-box://import/?url=https://example.com/sub&name=test'), (url: 'https://example.com/sub', name: 'test'));
      });
      test('v2rayng import link without name', () {
        expect(LinkParser.parse('v2rayng://import/?url=https://example.com/sub'), (url: 'https://example.com/sub', name: ''));
      });
      test('unknown schema', () {
        expect(LinkParser.parse('unknown://import/?url=https://example.com/sub&name=test'), null);
      });
    });
  });
}
