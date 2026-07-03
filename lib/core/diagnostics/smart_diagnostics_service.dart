import 'dart:async';
import 'package:hiddify/utils/custom_loggers.dart';

enum DiagnosticIssueType { dns, mtu, ipv6, routing, general }

class DiagnosticResult {
  final DiagnosticIssueType type;
  final String description;
  final String suggestion;

  DiagnosticResult({
    required this.type,
    required this.description,
    required this.suggestion,
  });
}

class SmartDiagnosticsService with AppLogger {
  Future<List<DiagnosticResult>> analyzeConnectionError(dynamic error, String? stackTrace) async {
    loggy.info('Analyzing connection error: $error');
    final results = <DiagnosticResult>[];
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('dns') || errorString.contains('resolve')) {
      results.add(
        DiagnosticResult(
          type: DiagnosticIssueType.dns,
          description: 'DNS resolution failed. The application could not resolve the server address.',
          suggestion: 'Try changing your DNS server settings (e.g., to 1.1.1.1 or 8.8.8.8) or disable IPv6 if your network does not support it.',
        ),
      );
    }

    if (errorString.contains('mtu') || errorString.contains('fragment')) {
      results.add(
        DiagnosticResult(
          type: DiagnosticIssueType.mtu,
          description: 'MTU size issue detected. Packets may be dropping because they are too large.',
          suggestion: 'Lower the MTU size in the connection settings. A value of 1280 to 1420 often helps.',
        ),
      );
    }

    if (errorString.contains('ipv6') || errorString.contains('network is unreachable')) {
      results.add(
        DiagnosticResult(
          type: DiagnosticIssueType.ipv6,
          description: 'IPv6 connectivity issue detected.',
          suggestion: 'Try forcing IPv4 in the settings if your ISP does not fully support IPv6.',
        ),
      );
    }

    if (errorString.contains('route') || errorString.contains('no route to host')) {
      results.add(
        DiagnosticResult(
          type: DiagnosticIssueType.routing,
          description: 'Routing problem detected. The connection cannot reach the server.',
          suggestion: 'Check if you are on a restricted network. You might need to change the node or enable a proxy.',
        ),
      );
    }

    if (results.isEmpty) {
      results.add(
        DiagnosticResult(
          type: DiagnosticIssueType.general,
          description: 'A general connection error occurred.',
          suggestion: 'Check your internet connection, try a different node, or update the app.',
        ),
      );
    }

    return results;
  }
}
