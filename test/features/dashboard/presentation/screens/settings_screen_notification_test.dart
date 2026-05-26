import 'package:control_horario/core/providers/theme_provider.dart';
import 'package:control_horario/features/dashboard/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsScreen notification triage', () {
    testWidgets('notification section is absent when no service exists',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Notification section title should NOT exist
      expect(find.text('Notificaciones'), findsNothing);
      // Notification switches should NOT exist
      expect(find.text('Notificaciones por correo'), findsNothing);
      expect(find.text('Notificaciones push'), findsNothing);
      expect(find.text('Recordatorios de fichaje'), findsNothing);
      // Switch widgets should NOT exist for notifications
      expect(find.byType(Switch), findsOneWidget); // Only dark mode switch
    });

    testWidgets('other sections remain intact after notification removal',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Preferencias section should still exist
      expect(find.text('Preferencias'), findsOneWidget);
      expect(find.text('Modo oscuro'), findsOneWidget);
      expect(find.text('Idioma'), findsOneWidget);

      // Cuenta section should still exist
      expect(find.text('Cuenta'), findsOneWidget);
      expect(find.text('Mi perfil'), findsOneWidget);

      // Acerca de section should still exist
      expect(find.text('Acerca de'), findsOneWidget);
      expect(find.text('Versión'), findsOneWidget);

      // Cerrar sesión should still exist
      expect(find.text('Cerrar sesión'), findsOneWidget);
    });

    testWidgets('no notification state variables cause issues after removal',
        (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Screen should render without crashing
      expect(find.text('Mi cuenta'), findsOneWidget);
    });
  });
}
