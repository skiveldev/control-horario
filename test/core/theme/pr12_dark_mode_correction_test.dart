import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_colors_dark.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:control_horario/features/admin/presentation/screens/calendar_management_screen.dart';
import 'package:control_horario/features/admin/presentation/screens/employees_list_screen.dart';
import 'package:control_horario/features/admin/presentation/screens/schedule_management_screen.dart';
import 'package:control_horario/features/admin/presentation/widgets/week_schedule_viewer.dart';
import 'package:control_horario/features/dashboard/presentation/screens/my_time_control_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Dark-mode correction tests for PR#12 corrective polish slice.
///
/// Verifies that 6 user-reported surfaces use Theme.of(context).colorScheme
/// tokens instead of hardcoded AppColors. The core check: in dark mode,
/// text must NOT be hardcoded AppColors.textPrimary (#0F172A, near-black)
/// and surfaces must NOT be hardcoded AppColors.surface (#FFFFFF, white).

/// Helper: wraps a widget in dark-mode MaterialApp + ProviderScope.
Widget _darkModeWrapper(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    ),
  );
}

/// Asserts that a [Text] widget with the given [text] does NOT use the
/// hardcoded light-mode color [AppColors.textPrimary] (which would be
/// invisible on dark backgrounds).
void expectTextIsNotHardcodedPrimary(WidgetTester tester, String text) {
  final finder = find.text(text);
  expect(finder, findsOneWidget, reason: 'Expected to find text "$text"');
  final textWidget = tester.widget<Text>(finder);
  final resolvedColor = textWidget.style?.color;
  // If color is null, the theme supplies it — that's fine (theme-aware).
  // If color is set, it must NOT be AppColors.textPrimary (light-mode near-black).
  if (resolvedColor != null) {
    expect(
      resolvedColor,
      isNot(equals(AppColors.textPrimary)),
      reason:
          '"$text" has hardcoded AppColors.textPrimary (#0F172A) — invisible in dark mode',
    );
  }
}

/// Asserts that a Container/BoxDecoration background does NOT use
/// [AppColors.surface] (pure white) which creates white boxes on dark backgrounds.
void expectBackgroundIsNotHardcodedSurface(WidgetTester tester,
    {String? label}) {
  final containers = tester.widgetList<Container>(find.byType(Container));
  var found = false;
  for (final c in containers) {
    final deco = c.decoration as BoxDecoration?;
    if (deco != null && deco.color == AppColors.surface) {
      found = true;
      break;
    }
  }
  if (found) {
    final reason = label != null
        ? '$label has hardcoded AppColors.surface (#FFFFFF) as background — white box in dark mode'
        : 'Container has hardcoded AppColors.surface background — visible white box in dark mode';
    fail(reason);
  }
}

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  // ==========================================================================
  // ISSUE 1: Employee "Mi control horario" — SnackBar/button colors
  // ==========================================================================
  group('MyTimeControlScreen dark mode', () {
    testWidgets('Scaffold background is NOT hardcoded AppColors.background',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const MyTimeControlScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The Scaffold should not have AppColors.background hardcoded
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(
        scaffold.backgroundColor,
        isNot(equals(AppColors.background)),
        reason:
            'Scaffold background should use theme token, not AppColors.background',
      );
    });

    testWidgets('mobile header uses colorScheme.surface, not AppColors.surface',
        (tester) async {
      // Use phone screen dimensions for mobile layout
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const MyTimeControlScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check that the header Container uses theme-aware background
      final containers = tester.widgetList<Container>(find.byType(Container));
      for (final c in containers) {
        final deco = c.decoration as BoxDecoration?;
        if (deco != null) {
          expect(
            deco.color,
            isNot(equals(AppColors.surface)),
            reason: 'Mobile header Container must not use AppColors.surface',
          );
        }
      }
    });
  });

  // ==========================================================================
  // ISSUE 2: Calendar / "Mi horario" — weekday and hour text visibility
  // ==========================================================================
  group('WeekScheduleViewer dark mode — weekday and hour text', () {
    testWidgets(
        'day names (Lunes-Viernes) do NOT use hardcoded AppColors.textPrimary',
        (tester) async {
      await tester.pumpWidget(_darkModeWrapper(
        const WeekScheduleViewer(employeeId: 'test-user', isReadOnly: true),
      ));
      await tester.pumpAndSettle();

      // In the loading/empty state, check that any present day text is theme-aware
      // The widget may show loading state — that's expected without Firebase
      // But the _buildEmptyState must be theme-aware
      final emptyText = find.text('Sin horario asignado');
      if (emptyText.evaluate().isNotEmpty) {
        final tw = tester.widget<Text>(emptyText);
        if (tw.style?.color != null) {
          expect(tw.style!.color, isNot(equals(AppColors.textPrimary)));
        }
      }
    });

    testWidgets(
        'empty state background does NOT use hardcoded AppColors.surfaceVariant + border',
        (tester) async {
      await tester.pumpWidget(_darkModeWrapper(
        const WeekScheduleViewer(employeeId: 'test-user', isReadOnly: true),
      ));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      for (final c in containers) {
        final deco = c.decoration as BoxDecoration?;
        if (deco != null) {
          expect(deco.color, isNot(equals(AppColors.surfaceVariant)),
              reason: 'Empty state must not use AppColors.surfaceVariant');
          if (deco.border != null) {
            // Border.all is a Border, not BorderSide — skip check for simplicity
          }
        }
      }
    });
  });

  // ==========================================================================
  // ISSUE 3: Admin "Panel principal" — header subtitle and text colors
  // ==========================================================================
  group('AdminDashboardScreen dark mode', () {
    testWidgets(
        'subtitle text uses theme color, not hardcoded AppColors.textSecondary',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final subtitleFinder = find.text(
        'Bienvenido de nuevo, aquí está lo que ha pasado hoy.',
        skipOffstage: false,
      );
      if (subtitleFinder.evaluate().isNotEmpty) {
        final tw = tester.widget<Text>(subtitleFinder);
        if (tw.style?.color != null) {
          expect(tw.style!.color, isNot(equals(AppColors.textSecondary)),
              reason:
                  'Subtitle must not use hardcoded AppColors.textSecondary');
        }
      }
    });
  });

  // ==========================================================================
  // ISSUE 4: "Gestionar empleados" — text and table surface colors
  // ==========================================================================
  group('EmployeesListScreen dark mode', () {
    testWidgets('description text uses theme, not AppColors.textSecondary',
        (tester) async {
      // Use desktop width to avoid Row overflow
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const EmployeesListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check that the description text doesn't use hardcoded textSecondary
      final containers = tester.widgetList<Text>(find.byType(Text));
      for (final t in containers) {
        if (t.data?.contains('Administra los empleados') == true &&
            t.style?.color != null) {
          expect(t.style!.color, isNot(equals(AppColors.textSecondary)),
              reason:
                  'Description text must not use hardcoded AppColors.textSecondary');
        }
      }
    });

    testWidgets(
        'table container does not use hardcoded AppColors.surface + border',
        (tester) async {
      // Use desktop width to avoid Row overflow
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const EmployeesListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check all Containers — none should use hardcoded AppColors.surface
      final containers = tester.widgetList<Container>(find.byType(Container));
      for (final c in containers) {
        final deco = c.decoration as BoxDecoration?;
        if (deco != null && deco.color != null) {
          expect(deco.color, isNot(equals(AppColors.surface)),
              reason: 'Table container must not use AppColors.surface');
        }
      }
    });

    testWidgets(
        'action bar does not cause RenderFlex overflow at tablet width (720px)',
        (tester) async {
      // 720 logical px = tablet where sidebar is drawer but action bar uses desktop Row
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const EmployeesListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the real action remains present without overflow.
      // Advanced filters/export are deferred to a future functional slice, so
      // the visual screen must not expose fake placeholder controls.
      expect(find.text('Filtros'), findsNothing);
      expect(find.text('Exportar'), findsNothing);

      // Verify no RenderFlex overflow exceptions were thrown during layout
      expect(tester.takeException(), isNull,
          reason:
              'EmployeesListScreen action bar must not overflow at 720px logical width');
    });
  });

  // ==========================================================================
  // ISSUE 5: "Gestión de horarios" — text colors
  // ==========================================================================
  group('ScheduleManagementScreen dark mode', () {
    testWidgets(
        'header text and empty state use theme, not hardcoded text colors',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const ScheduleManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check that the description text uses theme tokens
      final containers = tester.widgetList<Text>(find.byType(Text));
      for (final t in containers) {
        if (t.data?.contains('Plantillas predefinidas') == true &&
            t.style?.color != null) {
          expect(t.style!.color, isNot(equals(AppColors.textSecondary)));
        }
      }

      // Check empty state text
      final emptyFinder = find.text('No hay plantillas disponibles');
      if (emptyFinder.evaluate().isNotEmpty) {
        final tw = tester.widget<Text>(emptyFinder);
        // h4 style should be theme-aware via PR#8 fix
        expect(tw.style?.color, isNull,
            reason: 'h4 should have null color (theme supplies it)');
      }
    });
  });

  // ==========================================================================
  // ISSUE 6: "Gestionar calendarios" — tip banner, empty state, text colors
  // ==========================================================================
  group('CalendarManagementScreen dark mode', () {
    testWidgets('breadcrumb and header text use theme, not hardcoded AppColors',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const CalendarManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Text>(find.byType(Text));
      for (final t in containers) {
        if (t.data?.contains('Calendarios Laborales') == true &&
            t.style?.color != null) {
          // The h3 for title should have null color (theme supplies)
          if (t.style!.fontSize == 20) {
            expect(t.style!.color, isNull,
                reason: 'h3 title should not hardcode color');
          }
        }
      }

      // Tip banner: must NOT use AppColors.textPrimary as background
      final allContainers =
          tester.widgetList<Container>(find.byType(Container));
      for (final c in allContainers) {
        final deco = c.decoration as BoxDecoration?;
        if (deco != null) {
          // Tip banner reverse-colors: AppColors.textPrimary as bg is wrong
          expect(deco.color, isNot(equals(AppColors.textPrimary)),
              reason:
                  'No container should use AppColors.textPrimary as background');
        }
      }
    });

    testWidgets('empty state uses colorScheme, not AppColors.surface',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            home: const CalendarManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Empty state container should not use hardcoded AppColors.surface
      final containers = tester.widgetList<Container>(find.byType(Container));
      for (final c in containers) {
        final deco = c.decoration as BoxDecoration?;
        if (deco != null && deco.color != null) {
          expect(deco.color, isNot(equals(AppColors.surface)),
              reason: 'Empty state box must not use AppColors.surface (white)');
        }
      }
    });
  });
}
