import 'package:control_horario/core/providers/theme_provider.dart';
import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_colors_dark.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/features/dashboard/presentation/screens/settings_screen.dart';
import 'package:control_horario/shared/widgets/layouts/admin_layout.dart';
import 'package:control_horario/shared/widgets/navigation/mobile_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/admin/presentation/widgets/admin_sidebar_harness.dart';

/// MaterialApp wrapper for dark-mode widget tests.
Widget wrapDark(Widget child) {
  return MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: AppTheme.darkTheme,
    theme: AppTheme.lightTheme,
    home: child,
  );
}

/// MaterialApp.router wrapper for dark-mode widget tests.
Widget wrapDarkRouter(GoRouter router, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp.router(
      routerConfig: router,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
    ),
  );
}

void main() {
  // ============================================================================
  // 3.1: MobileDrawer dark mode
  // ============================================================================
  group('MobileDrawer dark mode', () {
    testWidgets(
        'header avatar background uses theme onPrimary, not light white',
        (tester) async {
      final testUser = UserModel(
        userId: 'dm-1',
        employeeId: 'EMP-DM1',
        email: 'dark@example.com',
        displayName: 'José Darko',
        role: UserRole.employee,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'José',
        apellido1: 'Darko',
      );

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => Scaffold(
              drawer: const MobileDrawer(),
              body: const SizedBox(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        wrapDarkRouter(router, overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(testUser)),
        ]),
      );

      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // The avatar should NOT use hardcoded AppColors.textOnPrimary (white #FFFFFFFF)
      // in dark mode — it should use theme.colorScheme.onPrimary (dark text).
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundColor, isNot(AppColors.textOnPrimary));
    });

    testWidgets('header text uses theme onPrimary, not hardcoded white',
        (tester) async {
      final testUser = UserModel(
        userId: 'dm-2',
        employeeId: 'EMP-DM2',
        email: 'ana@example.com',
        displayName: 'Ana Luz',
        role: UserRole.employee,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'Ana',
        apellido1: 'Luz',
      );

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => Scaffold(
              drawer: const MobileDrawer(),
              body: const SizedBox(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        wrapDarkRouter(router, overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(testUser)),
        ]),
      );

      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Both name and initials text should be visible (not lost on dark bg).
      // The text exists and is rendered.
      expect(find.text('Ana Luz'), findsOneWidget);
      expect(find.text('AL'), findsOneWidget);

      // The CircleAvatar child Text should not use hardcoded AppColors.textOnPrimary.
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      final avatarChild = avatar.child as Text;
      expect(
        avatarChild.style?.color,
        isNot(AppColors.textOnPrimary),
      );
    });

    testWidgets('dark mode drawer renders without crashing', (tester) async {
      // Smoke test: proves the widget renders in dark mode at all.
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => Scaffold(
              drawer: const MobileDrawer(),
              body: const SizedBox(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        wrapDarkRouter(router, overrides: [
          currentUserProvider.overrideWith(
            (ref) => const Stream<UserModel?>.empty(),
          ),
        ]),
      );

      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Verify fallback still renders
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
    });
  });

  // ============================================================================
  // 3.2: AdminSidebar dark mode
  // ============================================================================
  /// Builds dark-mode GoRouter wrapping [child].
  Widget wrapAdminTest(Widget child) {
    final router = GoRouter(
      initialLocation: '/admin',
      routes: [
        GoRoute(
          path: '/admin',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/admin/:section',
          builder: (context, state) => child,
        ),
      ],
    );
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        theme: AppTheme.lightTheme,
      ),
    );
  }

  group('AdminSidebar dark mode', () {
    testWidgets('sidebar surface is not hardcoded white in dark mode',
        (tester) async {
      await tester.pumpWidget(
        wrapAdminTest(const AdminSidebarHarness()),
      );
      await tester.pumpAndSettle();

      // Find the root Container of AdminSidebar and verify its color
      // is not the light-mode AppColors.surface white.
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundSidebarSurface = false;
      for (final c in containers) {
        final deco = c.decoration;
        if (deco is BoxDecoration && deco.color != null) {
          // The sidebar root has color: AppColors.surface; dark mode
          // should replace it with a theme-aware token.
          expect(deco.color, isNot(AppColors.surface));
          foundSidebarSurface = true;
          break;
        }
      }
      expect(foundSidebarSurface, isTrue,
          reason: 'Should find a Container with BoxDecoration color');
    });

    testWidgets('sidebar header icon uses theme onPrimary, not hardcoded white',
        (tester) async {
      await tester.pumpWidget(
        wrapAdminTest(const AdminSidebarHarness()),
      );
      await tester.pumpAndSettle();

      // The header clock icon should not be hardcoded white in dark mode.
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      bool foundHeaderIcon = false;
      for (final icon in icons) {
        // Header clock icon: Icons.access_time inside the _buildHeader method
        if (icon.icon == Icons.access_time) {
          expect(icon.color, isNot(AppColors.textOnPrimary));
          foundHeaderIcon = true;
        }
      }
      expect(foundHeaderIcon, isTrue,
          reason: 'Should find header clock icon (Icons.access_time)');
    });

    testWidgets('sidebar active item uses theme primary, not hardcoded',
        (tester) async {
      await tester.pumpWidget(
        wrapAdminTest(const AdminSidebarHarness()),
      );
      await tester.pumpAndSettle();

      // Sidebar items render without crashing in dark mode.
      // The visible items at the top should be present.
      expect(find.text('Panel Principal'), findsOneWidget);
      // The header clock icon should use theme onPrimary, not hardcoded white.
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      bool foundActiveIcon = false;
      for (final icon in icons) {
        // Active sidebar item icons should not use light-mode primary
        if (icon.color == AppColors.primary) {
          fail('AdminSidebar icon still uses hardcoded AppColors.primary '
              'for active items in dark mode.');
        }
        if (icon.color != null) foundActiveIcon = true;
      }
      expect(foundActiveIcon, isTrue,
          reason: 'Should find rendered icons in the sidebar');
    });
  });

  // ============================================================================
  // 3.3: AdminLayout dark mode
  // ============================================================================
  group('AdminLayout dark mode', () {
    testWidgets('header surface is not hardcoded white in dark mode',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) =>
                const AdminLayout(child: Text('Content')),
          ),
        ],
      );

      await tester.pumpWidget(
        wrapDarkRouter(router, overrides: [
          currentUserProvider.overrideWith(
            (ref) => const Stream<UserModel?>.empty(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // The _AdminHeader container has decoration color AppColors.surface.
      // In dark mode this must not be white.
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundHeaderBg = false;
      for (final c in containers) {
        final deco = c.decoration;
        if (deco is BoxDecoration && deco.color == AppColors.surface) {
          // Found a container still using light-mode surface — FAIL.
          fail('AdminLayout header still uses hardcoded AppColors.surface '
              '(white) in dark mode. Should use theme.colorScheme.surface.');
        }
        if (deco is BoxDecoration && deco.color != null) {
          foundHeaderBg = true;
        }
      }
      expect(foundHeaderBg, isTrue,
          reason: 'Should find header containers with decoration colors');
    });

    testWidgets('admin avatar uses theme primary in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) =>
                const AdminLayout(child: Text('Content')),
          ),
        ],
      );

      await tester.pumpWidget(
        wrapDarkRouter(router, overrides: [
          currentUserProvider.overrideWith(
            (ref) => const Stream<UserModel?>.empty(),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      // The avatar CircleAvatar uses AppColors.primary as backgroundColor.
      // In dark mode, this must use theme.colorScheme.primary instead
      // of the light-mode hardcoded value.
      final avatars =
          tester.widgetList<CircleAvatar>(find.byType(CircleAvatar));
      bool foundAvatar = false;
      for (final a in avatars) {
        if (a.radius == 16) {
          // The admin header avatar has radius 16
          expect(a.backgroundColor, isNot(AppColors.primary));
          foundAvatar = true;
        }
      }
      expect(foundAvatar, isTrue,
          reason: 'Should find admin header avatar (radius 16)');
    });

    testWidgets('header subtitle does not use hardcoded textSecondary',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final adminUser = UserModel(
        userId: 'a-1',
        employeeId: 'EMP-A1',
        email: 'j@ex.com',
        displayName: 'Juan Pérez',
        role: UserRole.admin,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'Juan',
        apellido1: 'Pérez',
      );

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) =>
                const AdminLayout(child: Text('Content')),
          ),
        ],
      );

      await tester.pumpWidget(
        wrapDarkRouter(router, overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(adminUser)),
        ]),
      );
      await tester.pumpAndSettle();

      // The subtitle Text widget should NOT use AppColors.textSecondary
      // in dark mode (that's a medium gray that may be invisible on dark bg).
      final texts = tester.widgetList<Text>(find.byType(Text));
      bool foundSubtitle = false;
      for (final t in texts) {
        if (t.style?.color == AppColors.textSecondary &&
            t.style?.fontSize == 11) {
          fail(
              'AdminLayout subtitle still uses hardcoded AppColors.textSecondary '
              'in dark mode. Should use theme-aware color.');
        }
        if (t.style?.fontSize == 11) {
          foundSubtitle = true;
        }
      }
      // At minimum the subtitle text widget exists
      expect(foundSubtitle, isTrue,
          reason: 'Should find admin header subtitle text (fontSize 11)');
    });
  });

  // ============================================================================
  // 3.5: SettingsScreen dark mode
  // ============================================================================
  group('SettingsScreen dark mode', () {
    /// Creates a MaterialApp.router-wrapped SettingsScreen with dark theme
    /// and required provider overrides for shared_preferences.
    Future<Widget> wrapSettingsDark() async {
      SharedPreferences.setMockInitialValues({});
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
      return ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
        ),
      );
    }

    testWidgets('section icon uses theme primary, not hardcoded',
        (tester) async {
      await tester.pumpWidget(await wrapSettingsDark());
      await tester.pumpAndSettle();

      // The section title icons should NOT use hardcoded AppColors.primary
      // in dark mode — they should use Theme.of(context).colorScheme.primary.
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      bool foundSectionIcon = false;
      for (final icon in icons) {
        if (icon.size == 20) {
          // Section title icons (size 20 = AppSpacing.iconMd)
          expect(icon.color, isNot(AppColors.primary));
          foundSectionIcon = true;
        }
      }
      expect(foundSectionIcon, isTrue,
          reason: 'Should find section title icons (size 20)');
    });

    testWidgets(
        'navigation item icon container uses theme surface in dark mode',
        (tester) async {
      await tester.pumpWidget(await wrapSettingsDark());
      await tester.pumpAndSettle();

      // Navigation items (Profile, Password) have a leading Container with
      // BoxDecoration. In dark mode, these must not use light-mode colors.
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundNavIconContainer = false;
      for (final c in containers) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          // surfaceVariant = #F1F5F9 (light gray) — should not appear in dark mode
          if (deco.color == AppColors.surfaceVariant) {
            fail('SettingsScreen nav icon container still uses hardcoded '
                'AppColors.surfaceVariant in dark mode.');
          }
          if (deco.color != null) {
            foundNavIconContainer = true;
          }
        }
      }
      expect(foundNavIconContainer, isTrue);
    });

    testWidgets('scroll background is not hardcoded light in dark mode',
        (tester) async {
      await tester.pumpWidget(await wrapSettingsDark());
      await tester.pumpAndSettle();

      // The Scaffold background uses AppColors.background (#F8FAFC).
      // In dark mode, scaffoldBackgroundColor should come from darkTheme.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNot(AppColors.background));
    });
  });

  // ============================================================================
  // 3.7: Dark ColorScheme token completeness
  // ============================================================================
  group('Dark ColorScheme completeness', () {
    test('all required surface tokens are defined in dark ColorScheme', () {
      final cs = AppTheme.darkTheme.colorScheme;

      // These tokens MUST exist — missing ones cause fallback to transparent/black
      expect(cs.surface, isNotNull);
      expect(cs.onSurface, isNotNull);
      expect(cs.primary, isNotNull);
      expect(cs.onPrimary, isNotNull);
      expect(cs.secondary, isNotNull);
      expect(cs.error, isNotNull);
      expect(cs.outline, isNotNull);
      expect(cs.surfaceContainerHighest, isNotNull);

      // Dark mode surface must be actually dark (not light/white)
      final surfaceLuminance = cs.surface.computeLuminance();
      expect(surfaceLuminance, lessThan(0.3),
          reason: 'Dark ColorScheme.surface should be dark (<0.3 luminance), '
              'got luminance $surfaceLuminance');
    });

    test(
        'dark ColorScheme onSurface is different from surface (ensures contrast)',
        () {
      final cs = AppTheme.darkTheme.colorScheme;

      // onSurface must differ from surface — otherwise text is invisible
      expect(cs.onSurface, isNot(equals(cs.surface)),
          reason:
              'onSurface and surface must be different colors for readability');
    });

    test(
        'dark ColorScheme onPrimary is different from primary (ensures contrast)',
        () {
      final cs = AppTheme.darkTheme.colorScheme;

      // onPrimary must differ from primary — otherwise text is invisible on primary
      expect(cs.onPrimary, isNot(equals(cs.primary)),
          reason:
              'onPrimary and primary must be different colors for readability');
    });
  });
}
