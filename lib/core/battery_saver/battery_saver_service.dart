import 'package:battery_plus/battery_plus.dart';

class BatterySaverService {
  final Battery _battery = Battery();

  Future<bool> isBatteryLow() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      return level < 20 && state != BatteryState.charging && state != BatteryState.full;
    } catch (e) {
      // In case of error (e.g. running on unsupported platform), assume false
      return false;
    }
  }

  Future<bool> isInPowerSaveMode() async {
    try {
      return await _battery.isInBatterySaveMode;
    } catch (e) {
      return false;
    }
  }

  Future<bool> shouldPauseHeavyTasks() async {
    final isLow = await isBatteryLow();
    final isSaving = await isInPowerSaveMode();
    return isLow || isSaving;
  }
}
