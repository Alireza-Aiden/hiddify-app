import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/caching/benchmark_cache_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BenchmarkCacheManager', () {
    late BenchmarkCacheManager cacheManager;

    setUp(() {
      cacheManager = BenchmarkCacheManager();
    });

    test('shouldBenchmark returns true for new tag', () async {
      expect(await cacheManager.shouldBenchmark('node_new'), isTrue);
    });

    test('shouldBenchmark returns false for recently cached tag', () async {
      cacheManager.updateCache('node_cached', 100);
      expect(await cacheManager.shouldBenchmark('node_cached'), isFalse);
    });

    test('shouldBenchmark returns true when forced', () async {
      cacheManager.updateCache('node_cached', 100);
      expect(await cacheManager.shouldBenchmark('node_cached', force: true), isTrue);
    });
  });
}
