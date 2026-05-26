import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_colors_dark.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/shared/widgets/navigation/mobile_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Pure function test: initialsFromName extracts correct initials.
void main() {
  group('initialsFromName', () {
    test('two-part name returns first letters of first and last', () {
      expect(initialsFromName('Juan Pérez'), 'JP');
    });

    test('three-part name returns first letters of first and first surname',
        () {
      expect(initialsFromName('Juan Pérez López'), 'JP');
    });

    test('single name returns single initial', () {
      expect(initialsFromName('María'), 'M');
    });

    test('empty string returns U for Usuario', () {
      expect(initialsFromName(''), 'U');
    });

    test('name with extra whitespace is trimmed', () {
      expect(initialsFromName('  Ana  María  '), 'AM');
    });

    test('single-letter name returns uppercase', () {
      expect(initialsFromName('a'), 'A');
    });
  });

  group('MobileDrawer with real user', () {
    testWidgets('shows real full name and derived initials', (tester) async {
      final testUser = UserModel(
        userId: 'user-1',
        employeeId: 'EMP-001',
        email: 'juan@example.com',
        displayName: 'Juan Pérez López',
        role: UserRole.employee,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'Juan',
        apellido1: 'Pérez',
        apellido2: 'López',
      );

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => const Scaffold(
              drawer: MobileDrawer(),
              body: SizedBox(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Open the drawer to make its content visible
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Verify real name is displayed
      expect(find.text('Juan Pérez López'), findsOneWidget);

      // Verify derived initials are displayed
      expect(find.text('JP'), findsOneWidget);

      // Verify hardcoded placeholder is gone
      expect(find.text('María García López'), findsNothing);
      expect(find.text('MG'), findsNothing);
    });

    testWidgets('null user shows Usuario fallback and U initials',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => const Scaffold(
              drawer: MobileDrawer(),
              body: SizedBox(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => const Stream<UserModel?>.empty(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Verify fallback name and initials
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
    });

    testWidgets('user with single name shows single initial', (tester) async {
      final testUser = UserModel(
        userId: 'user-2',
        employeeId: 'EMP-002',
        email: 'maria@example.com',
        displayName: 'María',
        role: UserRole.employee,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'María',
      );

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => const Scaffold(
              drawer: MobileDrawer(),
              body: SizedBox(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('María'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
    });
  });

  group('MobileDrawer dark mode header gradient', () {
    testWidgets(
      'drawer header gradient uses dark brand gradient, not green in dark mode',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final router = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => const Scaffold(
                drawer: MobileDrawer(),
                body: SizedBox(),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
              themeMode: ThemeMode.dark,
              darkTheme: AppTheme.darkTheme,
              theme: AppTheme.lightTheme,
            ),
          ),
        );

        final scaffoldState =
            tester.state<ScaffoldState>(find.byType(Scaffold));
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        // Find the DrawerHeader which wraps the user avatar area
        final drawerHeaders = tester.widgetList<DrawerHeader>(
          find.byType(DrawerHeader),
        );

        expect(drawerHeaders.isNotEmpty, isTrue,
            reason: 'MobileDrawer should have a DrawerHeader');

        final drawerHeader = drawerHeaders.first;
        final decoration = drawerHeader.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull,
            reason: 'DrawerHeader decoration should have a gradient');

        final gradient = decoration.gradient! as LinearGradient;

        // The dark brand gradient should match AppColorsDark.primaryGradient
        // (cyan #06B6D4 → purple #A855F7), NOT green from colorScheme.primary.
        expect(
          gradient.colors,
          equals(AppColorsDark.primaryGradient.colors),
          reason:
              'MobileDrawer header gradient in dark mode must use dark brand '
              'gradient (cyan→purple), not the green colorScheme.primary.',
        );
      },
    );

    testWidgets(
      'drawer header gradient uses light brand gradient in light mode',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final router = GoRouter(
          initialLocation: '/test',
          routes: [
            GoRoute(
              path: '/test',
              builder: (context, state) => const Scaffold(
                drawer: MobileDrawer(),
                body: SizedBox(),
              ),
            ),
          ],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp.router(
              routerConfig: router,
              themeMode: ThemeMode.light,
              darkTheme: AppTheme.darkTheme,
              theme: AppTheme.lightTheme,
            ),
          ),
        );

        final scaffoldState =
            tester.state<ScaffoldState>(find.byType(Scaffold));
        scaffoldState.openDrawer();
        await tester.pumpAndSettle();

        final drawerHeaders = tester.widgetList<DrawerHeader>(
          find.byType(DrawerHeader),
        );

        expect(drawerHeaders.isNotEmpty, isTrue,
            reason: 'MobileDrawer should have a DrawerHeader');

        final drawerHeader = drawerHeaders.first;
        final decoration = drawerHeader.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull,
            reason: 'DrawerHeader decoration should have a gradient');

        final gradient = decoration.gradient! as LinearGradient;

        // Light mode uses the original branded gradient (deep blue→violet).
        expect(
          gradient.colors,
          equals(AppColors.primaryGradient.colors),
          reason:
              'MobileDrawer header gradient in light mode must use the branded '
              'light gradient (deep blue→violet), not a dark mode gradient.',
        );
      },
    );
  });
}
