import 'package:flutter/material.dart';
import 'package:hiddify/features/dashboard/notifier/performance_dashboard_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PerformanceDashboardWidget extends HookConsumerWidget {
  const PerformanceDashboardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final dashboardStateAsync = ref.watch(performanceDashboardNotifierProvider);

    return dashboardStateAsync.when(
      data: (dashboardState) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Dashboard', style: textTheme.titleLarge),
                const Divider(),
                _buildStatRow('Node Score:', dashboardState.nodeScore),
                _buildStatRow('Ping:', dashboardState.ping),
                _buildStatRow('Download:', dashboardState.downloadSpeed),
                _buildStatRow('Upload:', dashboardState.uploadSpeed),
                _buildStatRow('Packet Loss:', dashboardState.packetLoss),
                _buildStatRow('Jitter:', dashboardState.jitter),
                _buildStatRow('Uptime:', dashboardState.connectionUptime),
                _buildStatRow('Protocol:', dashboardState.currentProtocol),
                _buildStatRow('Memory Usage:', dashboardState.memoryUsage),
                _buildStatRow(
                  'Battery Impact:',
                  dashboardState.isLowBattery ? 'High (Battery Saver Active)' : 'Normal',
                  valueColor: dashboardState.isLowBattery ? Colors.red : Colors.green,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error loading dashboard: $error'),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
