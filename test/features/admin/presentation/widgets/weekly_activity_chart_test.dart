import 'package:control_horario/features/admin/presentation/widgets/weekly_activity_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeeklyActivityChart empty state', () {
    testWidgets('muestra "Sin datos" cuando el mapa de datos está vacío', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklyActivityChart(data: {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Debe mostrar un mensaje de placeholder
      expect(find.text('Sin datos'), findsOneWidget);
    });

    testWidgets('NO renderiza dropdown activo cuando datos están vacíos', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklyActivityChart(data: {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Las opciones del dropdown NO deben estar visibles
      expect(find.text('Esta semana'), findsNothing);
      expect(find.text('Última semana'), findsNothing);
      expect(find.text('Últimos 30 días'), findsNothing);

      // En su lugar, muestra el badge de construcción "Más adelante"
      expect(find.text('Más adelante'), findsOneWidget);

      // Y el mensaje de construcción en el área del gráfico
      expect(
          find.text(
              'Datos históricos en construcción — disponibles próximamente'),
          findsOneWidget);
    });

    testWidgets('NO renderiza barras cuando datos están vacíos', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklyActivityChart(data: {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // El título "Actividad Semanal" debe seguir visible
      expect(find.text('Actividad Semanal'), findsOneWidget);
      // No deben aparecer valores de datos mock (420, 490 son valores únicos de MockData)
      expect(find.text('420'), findsNothing);
      expect(find.text('490'), findsNothing);
      // Nota: 450 es una etiqueta del eje Y (maxValue/4) — no es un valor de dato mock
    });

    testWidgets('renderiza normalmente con datos no vacíos', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklyActivityChart(
              data: {'Lun': 100, 'Mar': 200},
              maxValue: 300,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Con datos reales, muestra los valores
      expect(find.text('100'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      // Con datos, NO debe mostrar "Sin datos"
      expect(find.text('Sin datos'), findsNothing);
    });

    testWidgets('dropdown visible cuando hay datos reales', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeeklyActivityChart(
              data: {'Lun': 100, 'Mar': 200},
              maxValue: 300,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // El dropdown con período por defecto debe estar visible
      expect(find.text('Esta semana'), findsOneWidget);
    });
  });
}
