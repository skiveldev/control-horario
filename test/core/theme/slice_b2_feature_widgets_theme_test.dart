import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/add_edit_record_modal.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/blocked_record_modal.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/category_tab_selector.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/day_record_card.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/future_month_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Slice B2: Remaining dashboard feature widgets root theming migration tests.
///
/// Verifies the remaining Tier 2 dashboard feature widgets use
/// Theme.of(context).colorScheme tokens instead of hardcoded AppColors
/// surface/text/border in dark mode.
///
/// Key issue: AppColors.textPrimary (#0F172A near-black) is invisible on
/// dark backgrounds; AppColors.surface (#FFFFFF white) creates white boxes
/// that are jarring in dark mode.

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

TimeRecordModel _testRecord({
  String id = 'REC-001',
  String startTime = '08:00',
  String endTime = '14:00',
  RecordCategory category = RecordCategory.work,
  RecordStatus recordStatus = RecordStatus.completed,
  ValidationStatus validationStatus = ValidationStatus.editable,
  bool isActive = false,
}) {
  return TimeRecordModel(
    id: id,
    userId: 'USER-001',
    date: '2026-05-25',
    category: category,
    startTime: startTime,
    endTime: isActive ? startTime : endTime,
    location: 'Oficina Central',
    durationMinutes: 360,
    createdAt: DateTime(2026, 5, 25),
    updatedAt: DateTime(2026, 5, 25),
    createdBy: 'USER-001',
    isManual: false,
    recordStatus: recordStatus,
    validationStatus: validationStatus,
  );
}

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  // ===========================================================================
  // 1. DayRecordCard — day record expandable card
  // ===========================================================================
  group('DayRecordCard', () {
    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(DayRecordCard(
        date: DateTime(2026, 5, 25),
        records: [
          _testRecord(),
        ],
      )));

      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('no AppColors.textTertiary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(DayRecordCard(
        date: DateTime(2026, 5, 25),
        records: [
          _testRecord(),
        ],
      )));

      expect(_textColors(tester), everyElement(isNot(AppColors.textTertiary)));
    });

    testWidgets('renders day number in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(DayRecordCard(
        date: DateTime(2026, 5, 25),
        records: [
          _testRecord(),
        ],
      )));

      // Real behavioral assertion: day text is visible
      expect(find.textContaining('25'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 2. AddEditRecordModal — add/edit record dialog
  // ===========================================================================
  group('AddEditRecordModal', () {
    testWidgets('no AppColors.textPrimary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(AddEditRecordModal(
        date: DateTime(2026, 5, 25),
        availableLocations: ['Oficina', 'Remoto'],
        onSave: (_) async {},
      )));
      await tester.pumpAndSettle();

      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(AddEditRecordModal(
        date: DateTime(2026, 5, 25),
        availableLocations: ['Oficina', 'Remoto'],
        onSave: (_) async {},
      )));
      await tester.pumpAndSettle();

      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('no AppColors.textTertiary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(AddEditRecordModal(
        date: DateTime(2026, 5, 25),
        availableLocations: ['Oficina', 'Remoto'],
        onSave: (_) async {},
      )));
      await tester.pumpAndSettle();

      expect(_textColors(tester), everyElement(isNot(AppColors.textTertiary)));
    });

    testWidgets('renders title in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(AddEditRecordModal(
        date: DateTime(2026, 5, 25),
        availableLocations: ['Oficina', 'Remoto'],
        onSave: (_) async {},
      )));
      await tester.pumpAndSettle();

      // Real behavioral assertion: title is visible
      expect(find.text('Añadir Registro'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 3. BlockedRecordModal — blocked record info dialog
  // ===========================================================================
  group('BlockedRecordModal', () {
    Future<void> setupBlockedModalViewport(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('no AppColors.surface in dark mode', (tester) async {
      await setupBlockedModalViewport(tester);
      await tester.pumpWidget(_darkModeWrap(BlockedRecordModal(
        record: _testRecord(validationStatus: ValidationStatus.blocked),
        blockedByName: 'Admin User',
      )));

      expect(_hasContainerWithColor(tester, AppColors.surface), isFalse,
          reason: 'White surface on dark bg');
    });

    testWidgets('no AppColors.surfaceVariant in dark mode', (tester) async {
      await setupBlockedModalViewport(tester);
      await tester.pumpWidget(_darkModeWrap(BlockedRecordModal(
        record: _testRecord(validationStatus: ValidationStatus.blocked),
        blockedByName: 'Admin User',
      )));

      expect(_hasContainerWithColor(tester, AppColors.surfaceVariant), isFalse,
          reason: 'surfaceVariant on dark bg');
    });

    testWidgets('no AppColors.textPrimary in dark mode', (tester) async {
      await setupBlockedModalViewport(tester);
      await tester.pumpWidget(_darkModeWrap(BlockedRecordModal(
        record: _testRecord(validationStatus: ValidationStatus.blocked),
        blockedByName: 'Admin User',
      )));

      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await setupBlockedModalViewport(tester);
      await tester.pumpWidget(_darkModeWrap(BlockedRecordModal(
        record: _testRecord(validationStatus: ValidationStatus.blocked),
        blockedByName: 'Admin User',
      )));

      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('renders title in dark mode', (tester) async {
      await setupBlockedModalViewport(tester);
      await tester.pumpWidget(_darkModeWrap(BlockedRecordModal(
        record: _testRecord(validationStatus: ValidationStatus.blocked),
        blockedByName: 'Admin User',
      )));

      // Real behavioral assertion: title is visible
      expect(find.text('Registro Bloqueado'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 4. CategoryTabSelector — work/break tab selector
  // ===========================================================================
  group('CategoryTabSelector', () {
    testWidgets('no AppColors.surface in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CategoryTabSelector(
        selectedCategory: RecordCategory.work,
        onCategoryChanged: (_) {},
      )));

      expect(_hasContainerWithColor(tester, AppColors.surface), isFalse,
          reason: 'White surface on dark bg');
    });

    testWidgets('no AppColors.surfaceVariant in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CategoryTabSelector(
        selectedCategory: RecordCategory.work,
        onCategoryChanged: (_) {},
      )));

      expect(_hasContainerWithColor(tester, AppColors.surfaceVariant), isFalse,
          reason: 'surfaceVariant on dark bg');
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CategoryTabSelector(
        selectedCategory: RecordCategory.work,
        onCategoryChanged: (_) {},
      )));

      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('renders tab labels in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(CategoryTabSelector(
        selectedCategory: RecordCategory.work,
        onCategoryChanged: (_) {},
      )));

      // Real behavioral assertion: both tabs are visible in dark mode
      expect(find.text('Trabajo'), findsOneWidget);
      expect(find.text('Pausa'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 5. FutureMonthEmptyState — future month empty state
  // ===========================================================================
  group('FutureMonthEmptyState', () {
    testWidgets('no AppColors.surfaceVariant in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(FutureMonthEmptyState(
        month: DateTime(2026, 8),
        onGoToCurrentMonth: () {},
      )));

      expect(_hasContainerWithColor(tester, AppColors.surfaceVariant), isFalse,
          reason: 'surfaceVariant on dark bg');
    });

    testWidgets('no AppColors.textPrimary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(FutureMonthEmptyState(
        month: DateTime(2026, 8),
        onGoToCurrentMonth: () {},
      )));

      expect(_textColors(tester), everyElement(isNot(AppColors.textPrimary)));
    });

    testWidgets('no AppColors.textSecondary in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(FutureMonthEmptyState(
        month: DateTime(2026, 8),
        onGoToCurrentMonth: () {},
      )));

      expect(_textColors(tester), everyElement(isNot(AppColors.textSecondary)));
    });

    testWidgets('renders title in dark mode', (tester) async {
      await tester.pumpWidget(_darkModeWrap(FutureMonthEmptyState(
        month: DateTime(2026, 8),
        onGoToCurrentMonth: () {},
      )));

      // Real behavioral assertion: title is visible in dark mode
      expect(find.text('Mes no disponible'), findsOneWidget);
    });
  });
}
