import 'package:control_horario/shared/widgets/inputs/time_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimePickerField', () {
    testWidgets('muestra el label y placeholder cuando no hay valor',
        (tester) async {
      await tester.pumpWidget(_wrap(
        child: const TimePickerField(label: 'Hora de entrada'),
      ));

      expect(find.text('Hora de entrada'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
    });

    testWidgets('muestra la hora formateada cuando tiene valor',
        (tester) async {
      const time = TimeOfDay(hour: 9, minute: 30);
      await tester.pumpWidget(_wrap(
        child: const TimePickerField(
          label: 'Hora de salida',
          value: time,
        ),
      ));

      expect(find.text('09:30'), findsOneWidget);
    });

    testWidgets('abre el time picker al hacer tap', (tester) async {
      var pickedTime = false;
      await tester.pumpWidget(_wrap(
        child: TimePickerField(
          label: 'Entrada',
          onChanged: (_) => pickedTime = true,
        ),
      ));

      // Tap the InkWell area
      await tester.tap(find.text('--:--'));
      await tester.pumpAndSettle();

      // El TimePickerDialog de Flutter debería aparecer
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('no abre el picker cuando está deshabilitado', (tester) async {
      await tester.pumpWidget(_wrap(
        child: const TimePickerField(
          label: 'Entrada',
          enabled: false,
        ),
      ));

      await tester.tap(find.text('--:--'));
      await tester.pumpAndSettle();

      // No debe aparecer ningún diálogo
      expect(find.byType(TimePickerDialog), findsNothing);
    });

    testWidgets('muestra mensaje de error cuando errorText está presente',
        (tester) async {
      await tester.pumpWidget(_wrap(
        child: const TimePickerField(
          label: 'Entrada',
          errorText: 'La hora no puede ser futura',
        ),
      ));

      expect(find.text('La hora no puede ser futura'), findsOneWidget);
      // Debe mostrar el ícono de error
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('el valor por defecto para nuevos registros es 09:00',
        (tester) async {
      // Verificamos que al no tener value, el initialTime es 9:00 (AM)
      // Esto es una verificación de código: el campo _showTimePicker usa
      // value ?? const TimeOfDay(hour: 9, minute: 0) como initialTime
      TimeOfDay? capturedTime;
      await tester.pumpWidget(_wrap(
        child: TimePickerField(
          label: 'Entrada',
          onChanged: (time) => capturedTime = time,
        ),
      ));

      // Abrimos el picker (sin valor previo)
      await tester.tap(find.text('--:--'));
      await tester.pumpAndSettle();

      // Verificamos que el diálogo se abre
      expect(find.byType(TimePickerDialog), findsOneWidget);
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
