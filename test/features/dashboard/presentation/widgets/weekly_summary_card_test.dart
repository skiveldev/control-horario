import 'package:control_horario/features/dashboard/presentation/widgets/weekly_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklySummaryCard mock data cleanup', () {
    testWidgets('muestra estado vacío "Sin datos disponibles"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeeklySummaryCard())),
      );
      await tester.pumpAndSettle();

      // Debe mostrar el mensaje de estado vacío
      expect(find.text('Sin datos disponibles'), findsOneWidget);
      // Subtítulo de placeholder
      expect(
        find.text('El resumen semanal estará disponible próximamente'),
        findsOneWidget,
      );
    });

    testWidgets('NO muestra valores mock del resumen semanal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeeklySummaryCard())),
      );
      await tester.pumpAndSettle();

      // Valores mock de MockData.weeklySummary NO deben aparecer
      expect(find.text('37.5h'), findsNothing);
      expect(find.text('40h'), findsNothing);
      expect(find.text('Total semanal'), findsNothing);
      // Barras de días mock NO deben aparecer
      expect(find.text('8.0h'), findsNothing);
      expect(find.text('8.5h'), findsNothing);
      expect(find.text('7.5h'), findsNothing);
      expect(find.text('5.5h'), findsNothing);
      // Porcentaje mock NO debe aparecer
      expect(find.textContaining('% de la semana'), findsNothing);
    });

    testWidgets('preserva header "Esta Semana"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeeklySummaryCard())),
      );
      await tester.pumpAndSettle();

      // El título se preserva para la futura integración
      expect(find.text('Esta Semana'), findsOneWidget);
    });
  });
}
