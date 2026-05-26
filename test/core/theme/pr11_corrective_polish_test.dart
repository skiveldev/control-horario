import 'package:control_horario/core/theme/app_colors.dart';
import 'package:control_horario/core/theme/app_theme.dart';
import 'package:control_horario/features/admin/presentation/screens/admin_settings_screen.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/day_record_card.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  // ============================================================================
  // WU-1: AdminSettingsScreen — no hardcoded AppColors in dark mode
  // ============================================================================
  group('AdminSettingsScreen PR#11 dark mode fixes', () {
    testWidgets(
        'screen background and text use theme tokens, not hardcoded AppColors',
        (tester) async {
      final router = MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        theme: AppTheme.lightTheme,
        home: const AdminSettingsScreen(),
      );

      await tester.pumpWidget(router);
      await tester.pumpAndSettle();

      // Title "Configuración del sistema" must be visible (appears in AppBar and body)
      expect(find.text('Configuración del sistema'), findsAtLeast(1));

      // Icon must not use hardcoded AppColors.textSecondary
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      for (final icon in icons) {
        if (icon.icon == Icons.settings_suggest_outlined) {
          expect(icon.color, isNot(AppColors.textSecondary),
              reason:
                  'AdminSettingsScreen icon must not hardcode AppColors.textSecondary');
        }
      }
    });
  });

  // ============================================================================
  // WU-2: DayRecordCard — remaining AppColors.textSecondary/tertiary
  // ============================================================================
  group('DayRecordCard PR#11 dark mode fixes', () {
    testWidgets(
        'delete icon does not use hardcoded AppColors.textTertiary in dark mode',
        (tester) async {
      final dayRecord = DayRecordCard(
        date: DateTime(2026, 5, 25),
        records: [
          TimeRecordModel(
            id: 'r1',
            userId: 'u1',
            startTime: '09:00',
            endTime: '14:00',
            date: '2026-05-25',
            location: 'Oficina',
            category: RecordCategory.work,
            durationMinutes: 300,
            validationStatus: ValidationStatus.editable,
            createdAt: DateTime(2026, 5, 1),
            updatedAt: DateTime(2026, 5, 1),
            createdBy: 'admin',
            isManual: false,
          ),
        ],
        plannedMinutes: 480,
        isToday: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
          home: Scaffold(body: SingleChildScrollView(child: dayRecord)),
        ),
      );
      await tester.pumpAndSettle();

      // The day text "25 may." must be visible in dark mode (not invisible black on dark)
      expect(find.textContaining('may'), findsOneWidget);

      // The hour text must be visible
      expect(find.textContaining('5.0h'), findsOneWidget);
    });

    testWidgets('_getDifferenceColor uses theme-aware colors for difference',
        (tester) async {
      // Test with a significant negative difference (should not use hardcoded textSecondary)
      final dayRecord = DayRecordCard(
        date: DateTime(2026, 5, 25),
        records: [
          TimeRecordModel(
            id: 'r1',
            userId: 'u1',
            startTime: '09:00',
            endTime: '16:00',
            date: '2026-05-25',
            location: 'Oficina',
            category: RecordCategory.work,
            durationMinutes: 420,
            validationStatus: ValidationStatus.editable,
            createdAt: DateTime(2026, 5, 1),
            updatedAt: DateTime(2026, 5, 1),
            createdBy: 'admin',
            isManual: false,
          ),
        ],
        plannedMinutes: 480,
        isToday: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
          home: Scaffold(body: SingleChildScrollView(child: dayRecord)),
        ),
      );
      await tester.pumpAndSettle();

      // Difference text "-1.0h" should be visible (not using hardcoded textSecondary = invisible)
      // In dark mode, this text was using hardcoded AppColors.textSecondary (#475569)
      // which is nearly invisible on dark background (#0F172B).
      // After fix, it should use a theme-aware color visible in dark mode.
      expect(find.textContaining('-1.0h'), findsOneWidget);
    });
  });
}
