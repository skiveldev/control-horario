import 'dart:async';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/recent_records_card.dart';
import 'package:control_horario/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/mock_time_records.dart';

void main() {
  group('RecentRecordsCard grouping', () {
    testWidgets(
      'agrupa antes de limitar: 20 registros en 15 dias -> 5 dias visibles',
      (tester) async {
        final records = buildMockRecordsForDays([
          ('2025-05-26', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-26', RecordCategory.breakTime, '12:00', '12:30', 30),
          ('2025-05-25', RecordCategory.work, '09:00', '17:00', 420),
          ('2025-05-25', RecordCategory.breakTime, '12:00', '12:15', 15),
          ('2025-05-24', RecordCategory.work, '09:00', '14:00', 240),
          ('2025-05-24', RecordCategory.work, '09:00', '15:00', 300),
          ('2025-05-23', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-23', RecordCategory.breakTime, '12:00', '12:30', 30),
          ('2025-05-23', RecordCategory.work, '13:00', '18:00', 300),
          ('2025-05-22', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-21', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-20', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-19', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-18', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-17', RecordCategory.work, '09:00', '14:00', 240),
          ('2025-05-16', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-15', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-14', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-13', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-12', RecordCategory.work, '09:00', '18:00', 480),
        ]);

        final controller = StreamController<List<TimeRecordModel>>();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              last30DaysRecordsProvider.overrideWith(
                (ref) => controller.stream,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: RecentRecordsCard()),
            ),
          ),
        );
        await tester.pump();
        controller.add(records);
        await tester.pump();
        await tester.pump();
        await controller.close();

        // Dias mas viejos NO visibles
        expect(find.text('12/05/2025'), findsNothing);
        expect(find.text('13/05/2025'), findsNothing);
        expect(find.text('16/05/2025'), findsNothing);

        // 5 dias mas nuevos visibles
        expect(find.text('26/05/2025'), findsAtLeast(1));
        expect(find.text('25/05/2025'), findsAtLeast(1));
        expect(find.text('24/05/2025'), findsAtLeast(1));
        expect(find.text('23/05/2025'), findsAtLeast(1));
        expect(find.text('22/05/2025'), findsAtLeast(1));

        // Info text dice 5 dias (con acentos)
        expect(
          find.textContaining('Mostrando los \u00faltimos 5 d\u00edas'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'multiples registros mismo dia cuentan como uno',
      (tester) async {
        final records = buildMockRecordsForDays([
          ('2025-05-23', RecordCategory.work, '09:00', '13:00', 240),
          ('2025-05-23', RecordCategory.breakTime, '13:00', '13:30', 30),
          ('2025-05-23', RecordCategory.work, '13:30', '18:00', 270),
          ('2025-05-22', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-21', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-20', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-19', RecordCategory.work, '09:00', '18:00', 480),
          ('2025-05-18', RecordCategory.work, '09:00', '18:00', 480),
        ]);

        final controller = StreamController<List<TimeRecordModel>>();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              last30DaysRecordsProvider.overrideWith(
                (ref) => controller.stream,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: RecentRecordsCard()),
            ),
          ),
        );
        await tester.pump();
        controller.add(records);
        await tester.pump();
        await tester.pump();
        await controller.close();

        // 23/05 aparece al menos una vez (puede aparecer en tabla tambien)
        expect(find.text('23/05/2025'), findsAtLeast(1));
        // Total = 240+270 = 510min = 8h 30min
        expect(find.text('8h 30min'), findsOneWidget);
      },
    );

    testWidgets('boton Ver todo presente', (tester) async {
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
          child: const MaterialApp(
            home: Scaffold(body: RecentRecordsCard()),
          ),
        ),
      );
      await tester.pump();
      controller.add(records);
      await tester.pump();
      await tester.pump();
      await controller.close();

      expect(find.text('Ver todo'), findsOneWidget);
    });

    testWidgets('muestra estado vacio si lista vacia', (tester) async {
      final controller = StreamController<List<TimeRecordModel>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            last30DaysRecordsProvider.overrideWith(
              (ref) => controller.stream,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: RecentRecordsCard()),
          ),
        ),
      );
      await tester.pump();
      controller.add([]);
      await tester.pump();
      await tester.pump();
      await controller.close();

      expect(
        find.text('No hay registros recientes'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.event_busy), findsOneWidget);
    });
  });
}
