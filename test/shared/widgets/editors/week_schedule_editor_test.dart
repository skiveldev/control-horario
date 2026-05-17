import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/shared/widgets/editors/week_schedule_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeekScheduleEditor', () {
    Map<String, DaySchedule> defaultSchedule() {
      return {
        'monday': DaySchedule(
          isWorkDay: true,
          shifts: const [TimeShift(startTime: '09:00', endTime: '17:00')],
          dailyHours: 8.0,
        ),
        'tuesday': DaySchedule(
          isWorkDay: true,
          shifts: const [TimeShift(startTime: '09:00', endTime: '17:00')],
          dailyHours: 8.0,
        ),
        'wednesday': DaySchedule(
          isWorkDay: true,
          shifts: const [TimeShift(startTime: '09:00', endTime: '17:00')],
          dailyHours: 8.0,
        ),
        'thursday': DaySchedule(
          isWorkDay: true,
          shifts: const [TimeShift(startTime: '09:00', endTime: '17:00')],
          dailyHours: 8.0,
        ),
        'friday': DaySchedule(
          isWorkDay: true,
          shifts: const [TimeShift(startTime: '09:00', endTime: '17:00')],
          dailyHours: 8.0,
        ),
        'saturday': DaySchedule(
          isWorkDay: false,
          shifts: const [],
          dailyHours: 0,
        ),
        'sunday': DaySchedule(
          isWorkDay: false,
          shifts: const [],
          dailyHours: 0,
        ),
      };
    }

    testWidgets('muestra el total de horas semanales', (tester) async {
      await tester.pumpWidget(_wrap(
        child: WeekScheduleEditor(
          initialSchedule: defaultSchedule(),
          onChanged: (_) {},
        ),
      ));

      await tester.pumpAndSettle();

      // 5 días × 8 horas = 40 horas
      expect(find.textContaining('40 horas semanales'), findsOneWidget);
    });

    testWidgets('muestra los días de la semana', (tester) async {
      await tester.pumpWidget(_wrap(
        child: WeekScheduleEditor(
          initialSchedule: defaultSchedule(),
          onChanged: (_) {},
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Lunes'), findsOneWidget);
      expect(find.text('Martes'), findsOneWidget);
      expect(find.text('Miércoles'), findsOneWidget);
      expect(find.text('Jueves'), findsOneWidget);
      expect(find.text('Viernes'), findsOneWidget);
      expect(find.text('Sábado'), findsOneWidget);
      expect(find.text('Domingo'), findsOneWidget);
    });

    testWidgets('abre el time picker al hacer tap en una hora de turno',
        (tester) async {
      await tester.pumpWidget(_wrap(
        child: WeekScheduleEditor(
          initialSchedule: defaultSchedule(),
          onChanged: (_) {},
        ),
      ));

      await tester.pumpAndSettle();

      // Expandimos el primer día (Lunes) para ver los turnos
      await tester.tap(find.text('Lunes'));
      await tester.pumpAndSettle();

      // Hacemos tap en la hora de inicio (09:00)
      await tester.tap(find.text('09:00').first);
      await tester.pumpAndSettle();

      // Debe aparecer el TimePickerDialog
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('el día no laborable no muestra turnos', (tester) async {
      await tester.pumpWidget(_wrap(
        child: WeekScheduleEditor(
          initialSchedule: defaultSchedule(),
          onChanged: (_) {},
        ),
      ));

      await tester.pumpAndSettle();

      // Expandimos Sábado (no laborable)
      await tester.tap(find.text('Sábado'));
      await tester.pumpAndSettle();

      // No debe mostrar horas de turno para días no laborables
      expect(find.text('09:00'), findsNothing);
    });
  });
}

Widget _wrap({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
