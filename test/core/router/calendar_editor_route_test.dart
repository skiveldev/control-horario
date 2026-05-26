import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/features/admin/presentation/screens/calendar_editor_screen.dart';
import 'package:control_horario/features/admin/models/work_calendar_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Simple stub implementation of WorkCalendarModel for route testing.
/// Avoids the complexity of the full Firestore-backed model.
class _FakeWorkCalendar extends WorkCalendarModel {
  _FakeWorkCalendar(
      {required super.id, required super.name, required super.year})
      : super(
          events: const [],
          isActive: true,
        );
}

void main() {
  setUpAll(() {
    // Required by table_calendar package used in CalendarEditorScreen
    initializeDateFormatting('es', null);
  });

  group('AppRouter.adminCalendarEditor', () {
    test('existe y equivale a "/admin/calendars/:id/edit"', () {
      // RED: AppRouter.adminCalendarEditor no existe aún — esta prueba fallará en compilación.
      expect(
          AppRouter.adminCalendarEditor, equals('/admin/calendars/:id/edit'));
    });

    test('es distinta de la ruta padre adminCalendars', () {
      expect(AppRouter.adminCalendarEditor,
          isNot(equals(AppRouter.adminCalendars)));
    });

    testWidgets(
        'CalendarEditorScreen acepta existingCalendar y renderiza modo nuevo', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalendarEditorScreen(existingCalendar: null),
        ),
      );

      // Title for new calendar mode is "Nuevo Calendario"
      expect(find.text('Nuevo Calendario'), findsOneWidget);
    });

    testWidgets(
        'CalendarEditorScreen muestra nombre del calendario en modo edición', (
      tester,
    ) async {
      final calendar = _FakeWorkCalendar(
        id: 'cal-001',
        name: 'Festivos Nacionales',
        year: 2025,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CalendarEditorScreen(existingCalendar: calendar),
        ),
      );

      // In edit mode, the calendar name should be visible as editable text
      expect(find.text('Festivos Nacionales'), findsOneWidget);
    });
  });
}
