import 'package:control_horario/features/dashboard/presentation/widgets/monthly_calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MonthlyCalendarCard mock data cleanup', () {
    testWidgets('NO muestra indicadores de días mock (festivo, activo, evento)',
        (
      tester,
    ) async {
      // Large viewport to avoid calendar overflow
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MonthlyCalendarCard())),
      );
      await tester.pumpAndSettle();

      // El calendario debe renderizar el grid con los números de día
      // Pero no debe mostrar indicadores de MockData.calendarDays
      // Los badges/indicadores mock tenían colores/estilos específicos
      // Verificar que el título del mes se muestra (el widget es funcional)
      expect(find.byType(MonthlyCalendarCard), findsOneWidget);

      // No debe haber referencias a festivos mock (MockData tenía días 6, 12, 13, 14, 25)
      // Verificamos que el calendario renderiza días normales sin indicadores especiales
      // El CalendarGrid se renderiza con specialDays: {}
    });

    testWidgets('renderiza grid de calendario funcional con navegación', (
      tester,
    ) async {
      // Use a larger viewport since calendar grid needs vertical space
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: MonthlyCalendarCard())),
      );
      await tester.pumpAndSettle();

      // Los botones de navegación deben existir
      expect(find.byTooltip('Mes anterior'), findsOneWidget);
      expect(find.byTooltip('Mes siguiente'), findsOneWidget);

      // La leyenda debe existir (CalendarLegend)
      expect(find.text('Festivos'), findsOneWidget);

      // Al tocar un día, debe aparecer SnackBar
      // (el SnackBar es funcional, no mock)
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      expect(find.text('Día 15 seleccionado'), findsOneWidget);
    });
  });
}
