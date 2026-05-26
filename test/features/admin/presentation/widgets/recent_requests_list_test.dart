import 'package:control_horario/features/admin/presentation/widgets/recent_requests_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecentRequestsList empty state', () {
    testWidgets('muestra estado vacío cuando la lista está vacía', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecentRequestsList(requests: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Debe mostrar mensaje de estado vacío
      expect(find.text('No hay solicitudes pendientes'), findsOneWidget);
    });

    testWidgets('NO muestra items mock cuando la lista está vacía', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecentRequestsList(requests: []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // El título sigue visible
      expect(find.text('Últimas Solicitudes'), findsOneWidget);
      // Nombres mock no deben aparecer
      expect(find.text('Usuario 1'), findsNothing);
      expect(find.text('Usuario 2'), findsNothing);
      expect(find.text('Usuario 3'), findsNothing);
    });

    testWidgets('renderiza items cuando la lista no está vacía',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecentRequestsList(requests: [
              {
                'name': 'Ana López',
                'type': 'Vacaciones',
                'status': 'Pendiente'
              },
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ana López'), findsOneWidget);
      expect(find.text('Vacaciones'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      // Con datos, NO muestra el mensaje de vacío
      expect(find.text('No hay solicitudes pendientes'), findsNothing);
    });
  });
}
