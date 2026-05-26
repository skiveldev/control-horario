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

  testWidgets('SettingsScreen muestra título "Mi cuenta"', (tester) async {
    // RED: Actualmente el título es "Configuración", debe ser "Mi cuenta"
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
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // The CustomAppBar should display "Mi cuenta"
    expect(find.text('Mi cuenta'), findsOneWidget);

    // The old title "Configuración" should NOT appear
    expect(find.text('Configuración'), findsNothing);
  });
}
