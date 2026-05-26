import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/features/admin/presentation/screens/admin_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter.adminSettings', () {
    test('existe y equivale a "/admin/settings"', () {
      // RED: AppRouter.adminSettings no existe aún — esta prueba fallará en compilación.
      expect(AppRouter.adminSettings, equals('/admin/settings'));
    });

    test('es distinta de la ruta settings del empleado', () {
      expect(AppRouter.adminSettings, isNot(equals(AppRouter.settings)));
    });

    testWidgets('renderiza el placeholder honesto de configuración del sistema',
        (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminSettingsScreen(),
        ),
      );

      expect(find.text('Configuración del sistema'), findsWidgets);
      expect(find.text('Coming soon'), findsOneWidget);
      expect(
        find.textContaining('parámetros globales del sistema'),
        findsOneWidget,
      );
    });
  });
}
