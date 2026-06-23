import 'dart:async';

import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/admin/presentation/screens/anomalies_screen.dart';
import 'package:control_horario/features/admin/presentation/screens/overtime_review_screen.dart';
import 'package:control_horario/features/admin/presentation/screens/reports_screen.dart';
import 'package:control_horario/features/admin/providers/admin_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/presentation/widgets/login_footer.dart';
import 'package:control_horario/features/dashboard/services/anomaly_service.dart';
import 'package:control_horario/features/dashboard/services/overtime_service.dart';
import 'package:control_horario/features/dashboard/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Slice C: Tier 3+4 screens + navigation root theming migration tests.
///
/// Verifies the remaining Tier 3/4 screens and widgets use
/// Theme.of(context).colorScheme tokens instead of hardcoded AppColors
/// surface/text/border in dark mode.

/// Wraps a widget in dark-mode MaterialApp + Scaffold.
Widget _darkModeWrap(Widget child) {
  return MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: AppTheme.darkTheme,
    theme: AppTheme.lightTheme,
    home: Scaffold(body: child),
  );
}

/// Wraps in dark-mode MaterialApp + Scaffold + ProviderScope.
Widget _darkModeProviderWrap(Widget child,
    {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    ),
  );
}

/// Collects style colors from all [Text] widgets in the tree.
List<Color> _textColors(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.style?.color)
      .whereType<Color>()
      .toList();
}

Set<Color> _getForbiddenColors() {
  // Use LinkedHashSet explicitly to avoid equal_elements_in_set warning
  // while still documenting all 8 forbidden tokens.
  final s = <Color>{};
  s.add(AppColors.background);
  s.add(AppColors.surface);
  s.add(AppColors.surfaceVariant);
  s.add(AppColors.textPrimary);
  s.add(AppColors.textSecondary);
  s.add(AppColors.textTertiary);
  s.add(AppColors.border);
  s.add(AppColors.borderLight);
  return s;
}

void main() {
  // =========================================================================
  // LoginFooter
  // =========================================================================
  group('LoginFooter dark mode', () {
    testWidgets('no hardcoded AppColors textTertiary in dark mode',
        (tester) async {
      await tester.pumpWidget(_darkModeWrap(const LoginFooter()));
      await tester.pumpAndSettle();

      final textColors = _textColors(tester);
      for (final c in _getForbiddenColors()) {
        expect(textColors, isNot(contains(c)),
            reason: 'LoginFooter text must not use hardcoded $c');
      }
    });

    testWidgets('legal text is visible in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(const LoginFooter()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Al continuar'), findsOneWidget);
    });
  });

  // =========================================================================
  // AnomaliesScreen
  // =========================================================================
  group('AnomaliesScreen dark mode', () {
    testWidgets(
        'empty state text does not use hardcoded AppColors.textSecondary',
        (tester) async {
      await tester.pumpWidget(_darkModeProviderWrap(
        const AnomaliesScreen(),
        overrides: [
          anomaliesScreenProvider.overrideWith(
            (ref) => AnomaliesScreenNotifier(
              // No-op service — never called in empty state
              NoopAnomalyService(),
              const AnomaliesScreenState(anomalies: [], isDetecting: false),
            ),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      final textColors = _textColors(tester);
      expect(textColors, isNot(contains(AppColors.textSecondary)),
          reason:
              'Empty state text must not use hardcoded AppColors.textSecondary');
      expect(textColors, isNot(contains(AppColors.textTertiary)),
          reason:
              'Empty state description must not use hardcoded AppColors.textTertiary');
    });

    testWidgets('empty state text is visible in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeProviderWrap(
        const AnomaliesScreen(),
        overrides: [
          anomaliesScreenProvider.overrideWith(
            (ref) => AnomaliesScreenNotifier(
              NoopAnomalyService(),
              const AnomaliesScreenState(anomalies: [], isDetecting: false),
            ),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No se encontraron anomalías'), findsOneWidget);
    });
  });

  // =========================================================================
  // OvertimeReviewScreen
  // =========================================================================
  group('OvertimeReviewScreen dark mode', () {
    testWidgets(
        'empty state text does not use hardcoded AppColors.textSecondary',
        (tester) async {
      await tester.pumpWidget(_darkModeProviderWrap(
        const OvertimeReviewScreen(),
        overrides: [
          overtimeReviewScreenProvider.overrideWith(
            (ref) => OvertimeReviewNotifier(
              NoopOvertimeService(),
              const OvertimeReviewScreenState(
                  pendingRequests: [], isProcessing: false),
            ),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      final textColors = _textColors(tester);
      expect(textColors, isNot(contains(AppColors.textSecondary)),
          reason:
              'Empty state title must not use hardcoded AppColors.textSecondary');
    });

    testWidgets('empty state text is visible in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeProviderWrap(
        const OvertimeReviewScreen(),
        overrides: [
          overtimeReviewScreenProvider.overrideWith(
            (ref) => OvertimeReviewNotifier(
              NoopOvertimeService(),
              const OvertimeReviewScreenState(
                  pendingRequests: [], isProcessing: false),
            ),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('No hay solicitudes pendientes'), findsOneWidget);
    });
  });

  // =========================================================================
  // ReportsScreen
  // =========================================================================
  group('ReportsScreen dark mode', () {
    testWidgets('label text does not use hardcoded AppColors.textSecondary',
        (tester) async {
      await tester.pumpWidget(_darkModeProviderWrap(
        const ReportsScreen(),
        overrides: [
          allEmployeesProvider.overrideWith(
            (ref) => Stream.value(<UserModel>[]),
          ),
          reportsScreenProvider.overrideWith(
            (ref) => ReportsScreenNotifier(
              NoopReportService(),
            ),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      final textColors = _textColors(tester);
      expect(textColors, isNot(contains(AppColors.textSecondary)),
          reason:
              'Período label must not use hardcoded AppColors.textSecondary');
    });

    testWidgets('período label is visible in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeProviderWrap(
        const ReportsScreen(),
        overrides: [
          allEmployeesProvider.overrideWith(
            (ref) => Stream.value(<UserModel>[]),
          ),
          reportsScreenProvider.overrideWith(
            (ref) => ReportsScreenNotifier(
              NoopReportService(),
            ),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Período'), findsOneWidget);
    });
  });
}

// =============================================================================
// Fake services for testing (no real backend calls)
// =============================================================================

class NoopAnomalyService extends AnomalyService {
  const NoopAnomalyService() : super();
}

class NoopOvertimeService extends OvertimeService {
  NoopOvertimeService() : super.test();
}

class NoopReportService extends ReportService {
  const NoopReportService() : super();
}
