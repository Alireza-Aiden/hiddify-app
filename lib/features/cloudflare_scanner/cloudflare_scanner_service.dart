import 'dart:async';
import 'package:dart_ping/dart_ping.dart';
import 'package:hiddify/core/battery_saver/battery_saver_service.dart';
import 'package:hiddify/features/cloudflare_scanner/model/cloudflare_ip_info.dart';
import 'package:hiddify/utils/custom_loggers.dart';

class CloudflareScannerService with AppLogger {
  List<String> candidateIps = [
    '1.1.1.1',
    '1.0.0.1',
    '104.16.132.229',
    '104.16.133.229',
    '104.16.134.229',
  ];

  final BatterySaverService _batterySaver = BatterySaverService();
  final Map<String, CloudflareIpInfo> _scanCache = {};

  Future<CloudflareIpInfo?> getBestIp({bool forceScan = false}) async {
    if (!forceScan && await _batterySaver.shouldPauseHeavyTasks()) {
      loggy.info('Skipping Cloudflare IP scan due to battery constraints');
      return _getBestCachedIp();
    }

    final bestCached = _getBestCachedIp();
    if (!forceScan && bestCached != null && bestCached.isReachable && bestCached.latency < 200) {
      loggy.debug('Reusing cached Cloudflare IP: ${bestCached.ip}');
      return bestCached;
    }

    loggy.info('Starting Cloudflare IP scan');
    final results = <CloudflareIpInfo>[];

    for (final ip in candidateIps) {
      final ping = Ping(ip, count: 3, timeout: 2);
      int totalTime = 0;
      int receivedCount = 0;

      await for (final data in ping.stream) {
        if (data.response != null && data.response!.time != null) {
          totalTime += data.response!.time!.inMilliseconds;
          receivedCount++;
        }
      }

      int packetLoss = receivedCount > 0 ? ((3 - receivedCount) / 3 * 100).toInt() : 100;
      int latency = receivedCount > 0 ? (totalTime / receivedCount).toInt() : -1;

      final info = CloudflareIpInfo(ip: ip, latency: latency, packetLoss: packetLoss);
      _scanCache[ip] = info;

      if (info.isReachable) {
        results.add(info);
      }
    }

    if (results.isEmpty) {
      loggy.warning('No reachable Cloudflare IP found');
      return null;
    }

    results.sort((a, b) {
      if (a.packetLoss != b.packetLoss) return a.packetLoss.compareTo(b.packetLoss);
      return a.latency.compareTo(b.latency);
    });

    return results.first;
  }

  CloudflareIpInfo? _getBestCachedIp() {
    if (_scanCache.isEmpty) return null;
    final cachedReachable = _scanCache.values.where((info) => info.isReachable).toList();
    if (cachedReachable.isEmpty) return null;

    cachedReachable.sort((a, b) {
      if (a.packetLoss != b.packetLoss) return a.packetLoss.compareTo(b.packetLoss);
      return a.latency.compareTo(b.latency);
    });
    return cachedReachable.first;
  }
}
