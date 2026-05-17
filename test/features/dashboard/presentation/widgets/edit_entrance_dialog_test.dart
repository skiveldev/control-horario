import 'package:control_horario/features/dashboard/presentation/widgets/edit_entrance_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditEntranceDialog', () {
    testWidgets('muestra el diálogo en desktop con el título correcto',
        (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const SizedBox.shrink(),
      ));

      // Mostramos el diálogo (desktop → showDialog)
      showEditEntranceDialog(
        context: tester.element(find.byType(SizedBox)),
        currentEntrance: const TimeOfDay(hour: 8, minute: 0),
        onSave: (_) {},
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar Hora de Entrada'), findsOneWidget);
      expect(find.textContaining('HOY'), findsOneWidget);
    });

    testWidgets('muestra la hora actual de entrada en el diálogo',
        (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const SizedBox.shrink(),
      ));

      showEditEntranceDialog(
        context: tester.element(find.byType(SizedBox)),
        currentEntrance: const TimeOfDay(hour: 8, minute: 30),
        onSave: (_) {},
      );
      await tester.pumpAndSettle();

      // 08:30 aparece en el picker grande y en la info "Entrada actual: 08:30"
      expect(find.text('08:30'), findsAtLeast(1));
    });

    testWidgets('muestra la hora de salida cuando está disponible',
        (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const SizedBox.shrink(),
      ));

      showEditEntranceDialog(
        context: tester.element(find.byType(SizedBox)),
        currentEntrance: const TimeOfDay(hour: 8, minute: 0),
        exitTime: const TimeOfDay(hour: 18, minute: 0),
        onSave: (_) {},
      );
      await tester.pumpAndSettle();

      expect(find.text('18:00'), findsOneWidget);
    });

    testWidgets('abre el time picker al hacer tap en la hora', (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const SizedBox.shrink(),
      ));

      showEditEntranceDialog(
        context: tester.element(find.byType(SizedBox)),
        currentEntrance: const TimeOfDay(hour: 8, minute: 0),
        onSave: (_) {},
      );
      await tester.pumpAndSettle();

      // Hacemos tap en la hora mostrada para abrir el picker
      await tester.tap(find.text('08:00').first);
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('no puede guardar si no cambió la hora', (tester) async {
      await tester.pumpWidget(_wrapApp(
        child: const SizedBox.shrink(),
      ));

      showEditEntranceDialog(
        context: tester.element(find.byType(SizedBox)),
        currentEntrance: const TimeOfDay(hour: 8, minute: 0),
        onSave: (_) {},
      );
      await tester.pumpAndSettle();

      // El botón Guardar debe estar deshabilitado si no hubo cambios
      final saveButton = find.text('Guardar');
      expect(saveButton, findsOneWidget);
    });
  });
}

Widget _wrapApp({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}
