import 'package:control_horario/features/admin/presentation/widgets/control_alerts_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ControlAlertsPanel empty state', () {
    testWidgets('muestra estado vacío cuando la lista está vacía', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ControlAlertsPanel(alerts: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Debe mostrar mensaje de estado vacío
      expect(find.text('Sin alertas activas'), findsOneWidget);
    });

    testWidgets('NO muestra alertas mock cuando la lista está vacía', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ControlAlertsPanel(alerts: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // El título sigue visible
      expect(find.text('Alertas de Control'), findsOneWidget);
      // Alertas mock no deben aparecer
      expect(find.text('Fichajes Incompletos'), findsNothing);
      expect(find.text('Sistema operativo'), findsNothing);
    });

    testWidgets('renderiza alertas cuando la lista no está vacía', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ControlAlertsPanel(alerts: [
              {'type': 'info', 'title': 'Test Alerta', 'message': 'Mensaje'},
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Alerta'), findsOneWidget);
      expect(find.text('Mensaje'), findsOneWidget);
      // Con datos, NO muestra el mensaje de vacío
      expect(find.text('Sin alertas activas'), findsNothing);
    });
  });
}
