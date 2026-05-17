import 'dart:typed_data';

import 'package:control_horario/features/admin/presentation/screens/reports_screen.dart';
import 'package:control_horario/features/dashboard/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportsScreen', () {
    testWidgets('muestra título y selector de mes', (tester) async {
      final container = _containerWithState();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar el título
      expect(find.text('Generar Reportes'), findsOneWidget);
    });

    testWidgets('muestra botón de generar reporte', (tester) async {
      final container = _containerWithState();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar el botón de generar
      expect(find.text('Generar Reporte PDF'), findsOneWidget);
    });

    testWidgets('muestra selector de período', (tester) async {
      final container = _containerWithState();
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe haber un selector de mes
      expect(find.text('Período'), findsOneWidget);
    });

    testWidgets('muestra estado de generación cuando se genera el PDF',
        (tester) async {
      final container = _containerWithState(isGenerating: true);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      // Usar pump() en vez de pumpAndSettle() porque CircularProgressIndicator
      // es una animación infinita que nunca "settlea"
      await tester.pump();

      // Durante la generación, muestra loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('muestra indicador cuando el PDF está listo para descargar',
        (tester) async {
      final container = _containerWithState(hasPdf: true);
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Debe mostrar mensaje de PDF listo
      expect(find.text('PDF generado correctamente'), findsOneWidget);
    });

    testWidgets('el botón generar llama al notifier generateReport',
        (tester) async {
      final fakeService = _FakeReportService();
      final fakeNotifier = ReportsScreenNotifier(fakeService);

      final container = ProviderContainer(
        overrides: [
          reportsScreenProvider.overrideWith((ref) => fakeNotifier),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrapApp(container: container));
      await tester.pumpAndSettle();

      // Tap the generate button
      await tester.tap(find.text('Generar Reporte PDF'));
      await tester.pump();

      expect(fakeService.generateCalled, isTrue,
          reason:
              'El botón Generar debe llamar a generateReport del notifier');
    });
  });
}

ProviderContainer _containerWithState({
  bool isGenerating = false,
  bool hasPdf = false,
}) {
  return ProviderContainer(
    overrides: [
      reportsScreenProvider.overrideWith(
        (ref) {
          final service = ref.watch(reportServiceProvider);
          return ReportsScreenNotifier(
            service,
            ReportsScreenState(
              isGenerating: isGenerating,
              hasPdf: hasPdf,
              selectedMonth: DateTime(2026, 5, 1),
            ),
          );
        },
      ),
    ],
  );
}

Widget _wrapApp({required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: ReportsScreen(),
    ),
  );
}

/// Fake ReportService que registra si se llamó a generateMonthlyReport
class _FakeReportService extends ReportService {
  _FakeReportService() : super();

  bool generateCalled = false;

  @override
  Future<Uint8List> generateMonthlyReport({
    required String employeeName,
    required String companyName,
    required String period,
    required double totalHoursWorked,
    required int totalBreakMinutes,
    required double overtimeHours,
    required Map<String, int> anomalyCountByType,
    required String validationSummary,
  }) async {
    generateCalled = true;
    return Uint8List(0);
  }
}
