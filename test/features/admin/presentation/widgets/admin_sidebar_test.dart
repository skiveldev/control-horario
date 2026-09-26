import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_colors_dark.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('AdminSidebar muestra "Mi cuenta" y "Configuración del sistema"',
      (
    tester,
  ) async {
    // Use a tall surface to ensure all sidebar items are visible
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      initialLocation: AppRouter.admin,
      routes: [
        GoRoute(
          path: AppRouter.admin,
          builder: (context, state) => const Scaffold(
            body: AdminSidebar(),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // PR#11 correction: "Configuración del sistema" MUST remain in sidebar.
    // "Mi cuenta" must be removed — profile access is via header avatar only.
    expect(find.text('Configuración del sistema'), findsOneWidget);
    expect(find.text('Mi cuenta'), findsNothing);
  });

  testWidgets(
    'AdminSidebar solo contiene "Configuración del sistema", no "Mi cuenta"',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: AppRouter.admin,
        routes: [
          GoRoute(
            path: AppRouter.admin,
            builder: (context, state) => const Scaffold(
              body: AdminSidebar(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // PR#11: "Configuración del sistema" must stay; "Mi cuenta" must be removed
      expect(find.text('Configuración del sistema'), findsOneWidget);
      expect(find.text('Mi cuenta'), findsNothing);
    },
  );

  testWidgets(
    'AdminSidebar header has NO gradient and matches employee panel pattern in dark mode',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: AppRouter.admin,
        routes: [
          GoRoute(
            path: AppRouter.admin,
            builder: (context, state) => const Scaffold(
              body: AdminSidebar(),
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
      await tester.pumpAndSettle();

      // Assert NO gradient containers exist anywhere in the rendered widget
      final gradientContainers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).gradient != null,
        ),
      );
      expect(gradientContainers.isEmpty, isTrue,
          reason: 'AdminSidebar header must NOT use a gradient — it must match '
              'the employee panel plain-background pattern.');

      // Assert the exact repository brand is visible
      expect(find.text('controlhorario-rega'), findsOneWidget);

      // Assert the clock icon exists
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    },
  );

  testWidgets(
    'AdminSidebar header has NO gradient and matches employee panel pattern in light mode',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: AppRouter.admin,
        routes: [
          GoRoute(
            path: AppRouter.admin,
            builder: (context, state) => const Scaffold(
              body: AdminSidebar(),
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
      await tester.pumpAndSettle();

      // Assert NO gradient containers exist anywhere in the rendered widget
      final gradientContainers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).gradient != null,
        ),
      );
      expect(gradientContainers.isEmpty, isTrue,
          reason: 'AdminSidebar header must NOT use a gradient — it must match '
              'the employee panel plain-background pattern.');

      // Assert the exact repository brand is visible
      expect(find.text('controlhorario-rega'), findsOneWidget);

      // Assert the clock icon exists
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    },
  );

  testWidgets(
    'AdminSidebar brand header height (64px) and border align with main admin header',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: AppRouter.admin,
        routes: [
          GoRoute(
            path: AppRouter.admin,
            builder: (context, state) => const Scaffold(
              body: AdminSidebar(),
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
      await tester.pumpAndSettle();

      // Find the brand header Container: the one with a bottom border
      // (only the header has a bottom border AND explicit height: 64;
      //  outer container now also carries a BoxDecoration with a right border,
      //  so minHeight==64 disambiguates).
      final headerFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.minHeight == 64 &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).border?.bottom != null,
      );

      expect(headerFinder, findsAtLeast(1),
          reason: 'AdminSidebar brand header must have a bottom border');

      final headerContainer = tester.widget<Container>(headerFinder.first);

      // Assert rendered height matches main admin header (64px)
      final headerSize = tester.getSize(headerFinder.first);
      expect(
        headerSize.height,
        equals(64.0),
        reason: 'Brand header must be 64px tall to align its bottom divider '
            'with the main admin header bottom border.',
      );

      // Assert border color uses colorScheme.outline (matching main header)
      final decoration = headerContainer.decoration! as BoxDecoration;
      final bottomBorder = decoration.border!.bottom;
      final theme = Theme.of(tester.element(headerFinder.first));
      expect(
        bottomBorder.color,
        equals(theme.colorScheme.outline),
        reason: 'Brand header bottom border must use colorScheme.outline '
            'to match the adjacent main admin header border.',
      );
    },
  );

  testWidgets(
    'AdminSidebar brand header border matches main header in dark mode too',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: AppRouter.admin,
        routes: [
          GoRoute(
            path: AppRouter.admin,
            builder: (context, state) => const Scaffold(
              body: AdminSidebar(),
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
      await tester.pumpAndSettle();

      // Find brand header Container (minHeight==64 disambiguates from
      // the outer container which now also has a BoxDecoration+border)
      final headerFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.minHeight == 64 &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).border?.bottom != null,
      );

      expect(headerFinder, findsAtLeast(1));

      final headerContainer = tester.widget<Container>(headerFinder.first);
      final headerSize = tester.getSize(headerFinder.first);
      final decoration = headerContainer.decoration! as BoxDecoration;
      final bottomBorder = decoration.border!.bottom;
      final theme = Theme.of(tester.element(headerFinder.first));

      expect(headerSize.height, equals(64.0),
          reason: 'Dark mode sidebar header must also be 64px tall');
      expect(bottomBorder.color, equals(theme.colorScheme.outline),
          reason: 'Dark mode sidebar border must use colorScheme.outline');
      expect(decoration.gradient, isNull,
          reason: 'No gradient — employee panel pattern');
    },
  );

  testWidgets(
    'AdminSidebar "Configuración del sistema" navigates to admin settings',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Track which route was navigated to
      String? lastLocation;
      final router = GoRouter(
        initialLocation: AppRouter.admin,
        routes: [
          GoRoute(
            path: AppRouter.admin,
            builder: (context, state) => const Scaffold(
              body: AdminSidebar(),
            ),
          ),
          GoRoute(
            path: AppRouter.adminSettings,
            builder: (context, state) {
              lastLocation = AppRouter.adminSettings;
              return const Scaffold(
                body: Center(child: Text('Admin Settings Page')),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Configuración del sistema"
      await tester.tap(find.text('Configuración del sistema'));
      await tester.pumpAndSettle();

      // Should navigate to admin settings
      expect(lastLocation, equals(AppRouter.adminSettings),
          reason: '"Configuración del sistema" debe ir a admin settings');
    },
  );
}
