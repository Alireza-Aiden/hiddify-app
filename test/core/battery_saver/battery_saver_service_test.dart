import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/battery_saver/battery_saver_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BatterySaverService', () {
    late BatterySaverService service;

    setUp(() {
      service = BatterySaverService();
    });

    test('should return default values gracefully', () async {
      // Due to the plugin running on un-implemented platforms during unit tests
      // it should fall back to false gracefully without throwing exceptions.
      expect(await service.isBatteryLow(), isFalse);
      expect(await service.isInPowerSaveMode(), isFalse);
      expect(await service.shouldPauseHeavyTasks(), isFalse);
    });
  });
}
