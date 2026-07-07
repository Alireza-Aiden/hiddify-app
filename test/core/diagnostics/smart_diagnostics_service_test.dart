import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/diagnostics/smart_diagnostics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SmartDiagnosticsService', () {
    late SmartDiagnosticsService service;

    setUp(() {
      service = SmartDiagnosticsService();
    });

    test('should detect DNS issues', () async {
      final results = await service.analyzeConnectionError('Failed to resolve host', null);
      expect(results.length, 1);
      expect(results.first.type, DiagnosticIssueType.dns);
    });

    test('should detect MTU issues', () async {
      final results = await service.analyzeConnectionError('fragmentation required', null);
      expect(results.length, 1);
      expect(results.first.type, DiagnosticIssueType.mtu);
    });

    test('should fallback to general on unknown error', () async {
      final results = await service.analyzeConnectionError('unknown error', null);
      expect(results.length, 1);
      expect(results.first.type, DiagnosticIssueType.general);
    });
  });
}
