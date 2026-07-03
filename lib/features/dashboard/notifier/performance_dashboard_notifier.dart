import 'dart:async';
import 'package:hiddify/core/battery_saver/battery_saver_service.dart';
import 'package:hiddify/features/cloudflare_scanner/cloudflare_scanner_service.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'performance_dashboard_notifier.g.dart';

class PerformanceDashboardState {
  final String nodeScore;
  final String ping;
  final String downloadSpeed;
  final String uploadSpeed;
  final String packetLoss;
  final String jitter;
  final String connectionUptime;
  final String memoryUsage;
  final String currentProtocol;
  final bool isLowBattery;

  PerformanceDashboardState({
    this.nodeScore = "Unknown",
    this.ping = "0ms",
    this.downloadSpeed = "0 Mbps",
    this.uploadSpeed = "0 Mbps",
    this.packetLoss = "0%",
    this.jitter = "0ms",
    this.connectionUptime = "0m",
    this.memoryUsage = "0MB",
    this.currentProtocol = "Unknown",
    this.isLowBattery = false,
  });

  PerformanceDashboardState copyWith({
    String? nodeScore,
    String? ping,
    String? downloadSpeed,
    String? uploadSpeed,
    String? packetLoss,
    String? jitter,
    String? connectionUptime,
    String? memoryUsage,
    String? currentProtocol,
    bool? isLowBattery,
  }) {
    return PerformanceDashboardState(
      nodeScore: nodeScore ?? this.nodeScore,
      ping: ping ?? this.ping,
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      packetLoss: packetLoss ?? this.packetLoss,
      jitter: jitter ?? this.jitter,
      connectionUptime: connectionUptime ?? this.connectionUptime,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      currentProtocol: currentProtocol ?? this.currentProtocol,
      isLowBattery: isLowBattery ?? this.isLowBattery,
    );
  }
}

@Riverpod(keepAlive: true)
class PerformanceDashboardNotifier extends _$PerformanceDashboardNotifier {
  final BatterySaverService _batterySaverService = BatterySaverService();
  final CloudflareScannerService _cloudflareScannerService = CloudflareScannerService();

  bool _running = false;

  @override
  Stream<PerformanceDashboardState> build() async* {
    var currentState = PerformanceDashboardState();
    yield currentState;

    _running = true;
    ref.onDispose(() => _running = false);

    while (_running) {
      await Future.delayed(const Duration(seconds: 30));
      if (!_running) break;

      final isLow = await _batterySaverService.isBatteryLow();
      // Scan cloudflare only if needed (e.g. low battery bypasses this).
      // getBestIp respects the battery check and won't leak connections.
      final bestIp = await _cloudflareScannerService.getBestIp();

      currentState = currentState.copyWith(
        isLowBattery: isLow,
        ping: bestIp != null ? "${bestIp.latency}ms" : "N/A",
        packetLoss: bestIp != null ? "${bestIp.packetLoss}%" : "0%",
        nodeScore: bestIp != null && bestIp.latency < 100 ? "A" : "B",
      );

      yield currentState;
    }
  }
}
