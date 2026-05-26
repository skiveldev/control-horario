import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/shared/widgets/buttons/custom_button.dart';
import 'package:control_horario/shared/widgets/cards/info_card.dart';
import 'package:control_horario/shared/widgets/cards/metric_card.dart';
import 'package:control_horario/shared/widgets/cards/schedule_card.dart';
import 'package:control_horario/shared/widgets/cards/stat_card.dart';
import 'package:control_horario/shared/widgets/editors/week_schedule_editor.dart';
import 'package:control_horario/shared/widgets/empty_state.dart';
import 'package:control_horario/shared/widgets/error_state.dart';
import 'package:control_horario/shared/widgets/inputs/custom_password_field.dart';
import 'package:control_horario/shared/widgets/inputs/custom_text_field.dart';
import 'package:control_horario/shared/widgets/inputs/time_picker_field.dart';
import 'package:control_horario/shared/widgets/layouts/custom_app_bar.dart';
import 'package:control_horario/shared/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Slice A: Shared widgets root theming migration tests.
///
/// Verifies Tier 1 shared widgets use Theme.of(context).colorScheme tokens
/// instead of hardcoded AppColors surface/text/border in dark mode.
///
/// Key issue: AppColors.textPrimary (#0F172A near-black) is invisible on
/// dark backgrounds; AppColors.surface (#FFFFFF white) creates white boxes.

/// Wraps a widget in dark-mode MaterialApp + Scaffold.
Widget _darkModeWrap(Widget child) {
  return MaterialApp(
    themeMode: ThemeMode.dark,
    darkTheme: AppTheme.darkTheme,
    theme: AppTheme.lightTheme,
    home: Scaffold(body: child),
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

/// Collects BoxDecoration background colors from [Container] widgets.
List<Color> _containerColors(WidgetTester tester) {
  return tester
      .widgetList<Container>(find.byType(Container))
      .map((c) => (c.decoration as BoxDecoration?)?.color)
      .whereType<Color>()
      .toList();
}

/// Finds a specific Container by its BoxDecoration color.
bool _hasContainerWithColor(WidgetTester tester, Color target) {
  return _containerColors(tester).contains(target);
}

/// Finds LinearProgressIndicator backgrounds.
List<Color?> _progressBgColors(WidgetTester tester) {
  return tester
      .widgetList<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
      .map((p) => p.backgroundColor)
      .toList();
}

void main() {
  // =========================================================================
  // 1. MetricCard — surface, border, textPrimary, textSecondary
  // =========================================================================
  group('MetricCard', () {
    testWidgets('no AppColors.surface in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(const MetricCard(
        icon: Icons.people,
        label: 'Employees',
        value: '500',
        color: Colors.blue,
      )));
      expect(_hasContainerWithColor(tester, AppColors.surface), isFalse,
          reason: 'White surface on dark bg');
    });

    testWidgets('no AppColors.textPrimary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(const MetricCard(
        icon: Icons.people,
        label: 'Employees',
        value: '500',
        color: Colors.blue,
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(const MetricCard(
        icon: Icons.people,
        label: 'Employees',
        value: '500',
        color: Colors.blue,
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('no AppColors.border in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(const MetricCard(
        icon: Icons.people,
        label: 'Employees',
        value: '500',
        color: Colors.blue,
      )));
      for (final c in tester.widgetList<Container>(find.byType(Container))) {
        final deco = c.decoration as BoxDecoration?;
        if (deco != null && deco.border != null) {
          final b = deco.border as Border;
          expect(b.top.color, isNot(AppColors.border));
          expect(b.left.color, isNot(AppColors.border));
        }
      }
    });
  });

  // =========================================================================
  // 2. ScheduleCard — surface, border, textSecondary, textTertiary
  // =========================================================================
  group('ScheduleCard', () {
    Future<void> pumpCard(WidgetTester tester) =>
        tester.pumpWidget(_darkModeWrap(ScheduleCard(
          name: 'Full Time',
          description: 'Mon-Fri 9-17',
          weeklyHours: 40,
          usedByCount: 280,
          createdBy: 'Admin',
        )));

    testWidgets('no AppColors.surface in dark mode', (tester) async {
      await pumpCard(tester);
      expect(_hasContainerWithColor(tester, AppColors.surface), isFalse);
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await pumpCard(tester);
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('no AppColors.textTertiary in dark mode', (tester) async {
      await pumpCard(tester);
      expect(_textColors(tester), everyElement(isNot(AppColors.textTertiary)));
    });
  });

  // =========================================================================
  // 3. EmptyState — background, textPrimary, textSecondary, textTertiary
  // =========================================================================
  group('EmptyState', () {
    testWidgets('no AppColors.background in fullScreen dark mode',
        (tester) async {
      // fullScreen wraps in its own Scaffold; check that scaffold's bg
      await tester.pumpWidget(MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        theme: AppTheme.lightTheme,
        home: EmptyState(
          icon: Icons.inbox,
          title: 'No records',
          message: 'No data yet.',
          fullScreen: true,
        ),
      ));
      // The EmptyState creates a Scaffold; find it
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsOneWidget);
      final scaffold = tester.widget<Scaffold>(scaffolds);
      expect(scaffold.backgroundColor, isNot(AppColors.background));
    });

    testWidgets('no AppColors.textPrimary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(EmptyState(
        icon: Icons.inbox,
        title: 'No records',
        message: 'No data yet.',
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(EmptyState(
        icon: Icons.inbox,
        title: 'No records',
        message: 'No data yet.',
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });
  });

  // =========================================================================
  // 4. ErrorState — background, textPrimary, textSecondary
  // =========================================================================
  group('ErrorState', () {
    testWidgets('no AppColors.background in fullScreen dark mode',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        theme: AppTheme.lightTheme,
        home: ErrorState(
          message: 'Could not load data',
          fullScreen: true,
        ),
      ));
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsOneWidget);
      final scaffold = tester.widget<Scaffold>(scaffolds);
      expect(scaffold.backgroundColor, isNot(AppColors.background));
    });

    testWidgets('no AppColors.textPrimary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(ErrorState(
        message: 'Error loading data',
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(ErrorState(
        message: 'Error loading data',
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });
  });

  // =========================================================================
  // 5. LoadingSpinner — background, textSecondary
  // =========================================================================
  group('LoadingSpinner', () {
    testWidgets('no AppColors.background in fullScreen dark mode',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        theme: AppTheme.lightTheme,
        home: const LoadingSpinner(fullScreen: true, message: 'Loading...'),
      ));
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsOneWidget);
      final scaffold = tester.widget<Scaffold>(scaffolds);
      expect(scaffold.backgroundColor, isNot(AppColors.background));
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(const LoadingSpinner(
        message: 'Loading data...',
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });
  });

  // =========================================================================
  // 6. CustomButton — text colors (ElevatedButton internals not Containers)
  // =========================================================================
  group('CustomButton', () {
    testWidgets('secondary no AppColors.textPrimary', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CustomButton(
        text: 'Secondary',
        variant: ButtonVariant.secondary,
        onPressed: () {},
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('secondary outline no AppColors.textPrimary', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CustomButton(
        text: 'Outline',
        variant: ButtonVariant.secondary,
        outline: true,
        onPressed: () {},
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('disabled outline no AppColors.textTertiary', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CustomButton(
        text: 'Disabled',
        variant: ButtonVariant.secondary,
        outline: true,
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textTertiary)));
    });
  });

  // =========================================================================
  // 7. InfoCard — textSecondary, textTertiary, borderLight
  // =========================================================================
  group('InfoCard', () {
    Future<void> pumpCard(WidgetTester tester) =>
        tester.pumpWidget(_darkModeWrap(InfoCard(
          title: 'Total Hours',
          value: '5.5h',
          icon: Icons.schedule,
          type: InfoCardType.info,
          subtitle: 'of 8h worked',
          progress: 0.69,
          showArrow: true,
        )));

    testWidgets('no AppColors.textSecondary', (tester) async {
      await pumpCard(tester);
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('no AppColors.textTertiary', (tester) async {
      await pumpCard(tester);
      expect(_textColors(tester), everyElement(isNot(AppColors.textTertiary)));
    });

    testWidgets('progress bar no AppColors.borderLight', (tester) async {
      await pumpCard(tester);
      for (final c in _progressBgColors(tester)) {
        expect(c, isNot(AppColors.borderLight));
      }
    });
  });

  // =========================================================================
  // 8. StatCard — textSecondary
  // =========================================================================
  group('StatCard', () {
    testWidgets('no AppColors.textSecondary', (tester) async {
      await tester.pumpWidget(_darkModeWrap(StatCard(
        icon: Icons.people,
        label: 'Employees',
        value: '500',
        color: Colors.blue,
        trend: '+5%',
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });
  });

  // =========================================================================
  // 9. TimePickerField — surface, surfaceVariant, all text tokens, borders
  // =========================================================================
  group('TimePickerField', () {
    testWidgets('no AppColors.surface in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(TimePickerField(
        label: 'Start time',
        value: const TimeOfDay(hour: 9, minute: 0),
      )));
      expect(_hasContainerWithColor(tester, AppColors.surface), isFalse);
    });

    testWidgets('no AppColors.surfaceVariant in disabled dark mode',
        (tester) async {
      await tester.pumpWidget(_darkModeWrap(TimePickerField(
        label: 'Start time',
        enabled: false,
      )));
      expect(_hasContainerWithColor(tester, AppColors.surfaceVariant), isFalse);
    });

    testWidgets('no AppColors.textPrimary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(TimePickerField(
        label: 'Start time',
        value: const TimeOfDay(hour: 9, minute: 0),
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(TimePickerField(
        label: 'Start time',
        value: const TimeOfDay(hour: 9, minute: 0),
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('no AppColors.textTertiary in disabled dark mode',
        (tester) async {
      await tester.pumpWidget(_darkModeWrap(TimePickerField(
        label: 'Start time',
        enabled: false,
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textTertiary)));
    });
  });

  // =========================================================================
  // 10. CustomAppBar — surfaceVariant (search bar fill)
  // =========================================================================
  group('CustomAppBar', () {
    testWidgets('search bar no AppColors.surfaceVariant', (tester) async {
      await tester.pumpWidget(_darkModeWrap(Scaffold(
        appBar: CustomAppBar(title: 'Test', showSearch: true),
        body: Container(),
      )));
      expect(_hasContainerWithColor(tester, AppColors.surfaceVariant), isFalse);
    });
  });

  // =========================================================================
  // 11. CustomTextField — textSecondary
  // =========================================================================
  group('CustomTextField', () {
    testWidgets('no AppColors.textSecondary', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CustomTextField(
        label: 'Email',
        hintText: 'you@company.com',
        prefixIcon: Icons.email,
        required: true,
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });
  });

  // =========================================================================
  // 12. CustomPasswordField — textSecondary, borderLight
  // =========================================================================
  group('CustomPasswordField', () {
    testWidgets('no AppColors.textSecondary', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CustomPasswordField(
        label: 'Password',
        required: true,
      )));
      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('strength bar no AppColors.borderLight', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CustomPasswordField(
        label: 'Password',
        showStrengthIndicator: true,
      )));
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'Test123!');
      await tester.pump();
      for (final c in _progressBgColors(tester)) {
        expect(c, isNot(AppColors.borderLight));
      }
    });
  });

  // =========================================================================
  // 13. WeekScheduleEditor — surface, surfaceVariant in time picker theme
  // =========================================================================
  group('WeekScheduleEditor', () {
    testWidgets('no AppColors.surface in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(WeekScheduleEditor(
        initialSchedule: const {},
        onChanged: (_) {},
      )));
      expect(_hasContainerWithColor(tester, AppColors.surface), isFalse);
    });

    testWidgets('no AppColors.surfaceVariant in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(WeekScheduleEditor(
        initialSchedule: const {},
        onChanged: (_) {},
      )));
      expect(_hasContainerWithColor(tester, AppColors.surfaceVariant), isFalse);
    });
  });
}
