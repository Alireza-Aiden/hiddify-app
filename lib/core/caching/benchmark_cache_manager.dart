import 'package:hiddify/core/battery_saver/battery_saver_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'benchmark_cache_manager.g.dart';

@Riverpod(keepAlive: true)
BenchmarkCacheManager benchmarkCacheManager(BenchmarkCacheManagerRef ref) {
  return BenchmarkCacheManager();
}

class BenchmarkCacheManager {
  final Map<String, _BenchmarkResult> _cache = {};
  final BatterySaverService _batterySaver = BatterySaverService();

  Future<bool> shouldBenchmark(String tag, {bool force = false}) async {
    if (force) return true;

    if (await _batterySaver.shouldPauseHeavyTasks()) {
      return false; // Skip entirely if battery is low or saving power
    }

    final entry = _cache[tag];
    if (entry == null) return true; // New node

    if (entry.hasFailed) return true; // Failed node

    if (entry.isDegraded) return true; // Degraded performance

    return entry.isExpired;
  }

  void updateCache(String tag, int delay, {bool isDegraded = false, bool hasFailed = false}) {
    _cache[tag] = _BenchmarkResult(
      timestamp: DateTime.now(),
      delay: delay,
      isDegraded: isDegraded,
      hasFailed: hasFailed,
    );
  }

  int? getCachedDelay(String tag) => _cache[tag]?.delay;

  void clearCache() {
    _cache.clear();
  }
}

class _BenchmarkResult {
  final DateTime timestamp;
  final int delay;
  final bool isDegraded;
  final bool hasFailed;

  _BenchmarkResult({
    required this.timestamp,
    required this.delay,
    this.isDegraded = false,
    this.hasFailed = false,
  });

  bool get isExpired {
    return DateTime.now().difference(timestamp) > const Duration(minutes: 10);
  }
}
