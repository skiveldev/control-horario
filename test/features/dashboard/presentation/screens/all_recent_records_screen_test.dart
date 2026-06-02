import 'dart:async';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/presentation/screens/all_recent_records_screen.dart';
import 'package:control_horario/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/mock_time_records.dart';

void main() {
  group('AllRecentRecordsScreen', () {
    testWidgets('muestra todos los dias agrupados sin limite', (tester) async {
      final records = buildMockRecordsForDays([
        ('2025-05-26', RecordCategory.work, '09:00', '18:00', 480),
        ('2025-05-25', RecordCategory.work, '09:00', '17:00', 420),
        ('2025-05-24', RecordCategory.work, '09:00', '14:00', 240),
        ('2025-05-23', RecordCategory.work, '09:00', '18:00', 480),
        ('2025-05-23', RecordCategory.breakTime, '12:00', '12:30', 30),
        ('2025-05-22', RecordCategory.work, '09:00', '18:00', 480),
        ('2025-05-21', RecordCategory.work, '09:00', '18:00', 480),
        ('2025-05-20', RecordCategory.work, '09:00', '18:00', 480),
      ]);

      final controller = StreamController<List<TimeRecordModel>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            last30DaysRecordsProvider.overrideWith(
              (ref) => controller.stream,
            ),
          ],
          child: const MaterialApp(home: AllRecentRecordsScreen()),
        ),
      );
      await tester.pump();
      controller.add(records);
      await tester.pump();
      await tester.pump();
      await controller.close();

      // Dias visibles en el header y lista (date aparece en card + RecordsTable)
      expect(find.text('26/05/2025'), findsAtLeast(1));
      expect(find.text('25/05/2025'), findsAtLeast(1));
      expect(find.text('24/05/2025'), findsAtLeast(1));
      // Scrollear para ver dias mas antiguos
      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -600));
      await tester.pump();
      await tester.drag(listView, const Offset(0, -600));
      await tester.pump();
      expect(find.text('22/05/2025'), findsAtLeast(1));
      expect(find.text('21/05/2025'), findsAtLeast(1));
      expect(find.text('20/05/2025'), findsAtLeast(1));
    });

    testWidgets('agrupa registros del mismo dia', (tester) async {
      final records = buildMockRecordsForDays([
        ('2025-05-23', RecordCategory.work, '09:00', '13:00', 240),
        ('2025-05-23', RecordCategory.breakTime, '13:00', '13:30', 30),
        ('2025-05-23', RecordCategory.work, '13:30', '18:00', 270),
      ]);

      final controller = StreamController<List<TimeRecordModel>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            last30DaysRecordsProvider.overrideWith(
              (ref) => controller.stream,
            ),
          ],
          child: const MaterialApp(home: AllRecentRecordsScreen()),
        ),
      );
      await tester.pump();
      controller.add(records);
      await tester.pump();
      await tester.pump();
      await controller.close();

      // Solo una card para 23/05 (aunque aparezca 2 veces por RecordsTable)
      expect(find.text('23/05/2025'), findsAtLeast(1));
      // 240+270 = 510min = 8h 30min
      expect(find.text('8h 30min'), findsOneWidget);
    });

    testWidgets('muestra estado vacio si no hay registros', (tester) async {
      final controller = StreamController<List<TimeRecordModel>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            last30DaysRecordsProvider.overrideWith(
              (ref) => controller.stream,
            ),
          ],
          child: const MaterialApp(home: AllRecentRecordsScreen()),
        ),
      );
      await tester.pump();
      controller.add([]);
      await tester.pump();
      await tester.pump();
      await controller.close();

      expect(
        find.text('No hay registros en los \u00faltimos 30 d\u00edas'),
        findsOneWidget,
      );
    });

    testWidgets('boton volver presente', (tester) async {
      final records = buildMockRecordsForDays([
        ('2025-05-26', RecordCategory.work, '09:00', '18:00', 480),
      ]);

      final controller = StreamController<List<TimeRecordModel>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            last30DaysRecordsProvider.overrideWith(
              (ref) => controller.stream,
            ),
          ],
          child: const MaterialApp(home: AllRecentRecordsScreen()),
        ),
      );
      await tester.pump();
      controller.add(records);
      await tester.pump();
      await tester.pump();
      await controller.close();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
