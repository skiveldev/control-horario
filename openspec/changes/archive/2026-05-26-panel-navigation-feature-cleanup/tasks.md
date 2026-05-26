# Tasks: Panel Navigation & Feature Cleanup

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~1150 total across 7 PRs (each PR <400) |
| 400-line budget risk | Low (each slice individually under 400) |
| Chained PRs recommended | Yes |
| Suggested split | PR#1 → PR#2 → PR#3 chain; PR#4 targets PR#2; PR#5/PR#6/PR#7 independent |
| Delivery strategy | force-chained |
| Chain strategy | feature-branch-chain |

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: feature-branch-chain
400-line budget risk: Low

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Navigation split: Mi cuenta / Config del sistema | PR#1 | Base = feature/tracker; navigation foundation |
| 2 | Mobile drawer + admin header real user data | PR#2 | Base = PR#1 branch; depends on nav split |
| 3 | Dark mode consistency: high-traffic surfaces | PR#3 | Base = PR#2 branch; largest slice ~300 lines |
| 4 | Notification UI triage: disable bells/switches | PR#4 | Base = PR#2 branch; independent of dark mode |
| 5 | CalendarEditorScreen GoRoute registration | PR#5 | Base = feature/tracker; fully independent |
| 6 | Splash session-aware navigation | PR#6 | Base = feature/tracker; fully independent |
| 7 | Dashboard mock data → honest empty/loading states | PR#7 | Base = feature/tracker; fully independent |

## Phase 1: Foundation — Navigation Split (PR#1, ~200 lines)

- [x] 1.1 Modify `lib/shared/widgets/navigation/navigation_items.dart`: remove "Configuración" from employee items when `canSuperviseTeam: false`; keep conditional logic.
- [x] 1.2 Add route constant `adminSettings = '/admin/settings'` to `lib/core/router/app_router.dart`.
- [x] 1.3 Register GoRoute `/admin/settings` as sub-route under `/admin` in `app_router.dart` with placeholder `AdminSettingsScreen` (simple Scaffold with "Coming soon").
- [x] 1.4 Modify `lib/features/admin/presentation/widgets/admin_sidebar.dart`: split single "Configuración" into two items — "Mi cuenta" → `AppRouter.settings` + "Configuración del sistema" → `AppRouter.adminSettings`.
- [x] 1.5 Modify `lib/features/dashboard/presentation/screens/settings_screen.dart`: change page title to "Mi cuenta".
- [x] 1.6 Test: unit test `NavigationItems.items()` — assert employee list excludes "Configuración", admin list includes it. File: `test/shared/widgets/navigation/navigation_items_test.dart`.
- [x] 1.7 Test: widget test verifying `/admin/settings` route renders placeholder. File: `test/core/router/admin_settings_route_test.dart`.

**Rollback boundary**: Revert PR#1 → employee sees old "Configuración" item, admin route removed. No downstream breakage.

## Phase 2: Real User Data — Drawer & Header (PR#2, ~80 lines)

- [x] 2.1 Modify `lib/shared/widgets/navigation/mobile_drawer.dart`: replace hardcoded "María García López" with `ref.watch(currentUserProvider)` for display name; derive initials from name; handle null user with "Usuario" fallback.
- [x] 2.2 Modify `lib/shared/widgets/layouts/admin_layout.dart`: wire admin header avatar/name from `currentUserProvider` instead of any hardcoded value.
- [x] 2.3 Test: widget test for `MobileDrawer` with `ProviderScope` override of `currentUserProvider` — verify real name and initials render. File: `test/shared/widgets/navigation/mobile_drawer_test.dart`.
- [x] 2.4 Test: widget test for `AdminLayout` header with real user data. File: `test/shared/widgets/layouts/admin_layout_test.dart`.

**Rollback boundary**: Revert PR#2 → drawer/header show hardcoded placeholder again. No nav structure change.

## Phase 3: Dark Mode Consistency (PR#3, ~300 lines)

- [x] 3.1 Modify `lib/shared/widgets/navigation/mobile_drawer.dart`: replace hardcoded `AppColors.` refs with `Theme.of(context).colorScheme` tokens for background, text, avatar, divider colors.
- [x] 3.2 Modify `lib/features/admin/presentation/widgets/admin_sidebar.dart`: replace hardcoded `AppColorsDark.` text/icon refs with `Theme.of(context).colorScheme` tokens; verify existing theme-aware tokens preserved.
- [x] 3.3 Modify `lib/shared/widgets/layouts/admin_layout.dart`: fix hardcoded colors (search field background, header area) to use theme tokens.
- [x] 3.4 Modify `lib/shared/widgets/layouts/responsive_navigation.dart`: fix gear icon color to use `Theme.of(context).colorScheme`. → No hardcoded colors found; widget is structural only. Gear icon rendered via DesktopSidebar/NavigationItems.
- [x] 3.5 Modify `lib/features/dashboard/presentation/screens/settings_screen.dart`: replace hardcoded `AppColors.primary`, `AppColors.surface`, `AppColors.border` with `Theme.of(context).colorScheme.primary`, `.surface`, `.outline` where they cause dark mode inconsistency.
- [x] 3.6 Modify `lib/core/theme/app_colors.dart`: add documentation comments marking which tokens are theme-safe vs intentional branded constants.
- [x] 3.7 Modify `lib/core/theme/app_theme.dart`: verify `ColorScheme.dark()` surface/onSurface tokens match expected widget consumption; add missing mappings if needed. → Verified via tests; tokens correct.
- [x] 3.8 Test: widget test verifying dark mode renders consistently in sidebar, drawer, and settings screen. File: `test/core/theme/dark_mode_consistency_test.dart`.

**Rollback boundary**: Revert PR#3 → dark mode returns to previous inconsistent state. No functional breakage, only visual.

## Phase 4: Notification UI Triage (PR#4, ~120 lines)

- [x] 4.1 Modify `lib/shared/widgets/layouts/admin_layout.dart`: disable notification bell — grey icon, no badge, tap shows "Coming soon" SnackBar.
- [x] 4.2 Modify `lib/features/dashboard/presentation/screens/settings_screen.dart`: remove notification toggle switches (email, push, clocking reminders) or visually disable with "Not implemented" label.
- [x] 4.3 Test: widget test verifying notification switches are absent/disabled in settings screen. File: `test/features/dashboard/presentation/screens/settings_screen_notification_test.dart`.
- [x] 4.4 Test: widget test verifying notification bell shows "Coming soon" on tap. File: `test/shared/widgets/layouts/admin_layout_notification_test.dart`.

**Rollback boundary**: Revert PR#4 → notification UI returns to previous state. No data loss.

## Phase 5: CalendarEditor Route Registration (PR#5, ~100 lines)

- [x] 5.1 Add route constant `adminCalendarEditor = '/admin/calendars/:id/edit'` to `lib/core/router/app_router.dart`.
- [x] 5.2 Register GoRoute `/admin/calendars/:id/edit` under `/admin/calendars` in `app_router.dart` with `CalendarEditorScreen`, passing `extra: WorkCalendarModel?`.
- [x] 5.3 Add import for `CalendarEditorScreen` in `app_router.dart`.
- [x] 5.4 Modify `lib/features/admin/presentation/screens/calendar_management_screen.dart`: replace `Navigator.push` call with `context.go(AppRouter.adminCalendarEditor, extra: calendar)`.
- [x] 5.5 Test: router test verifying `/admin/calendars/:id/edit` renders `CalendarEditorScreen` with correct extra param. File: `test/core/router/calendar_editor_route_test.dart`.

**Rollback boundary**: Revert PR#5 → CalendarEditor returns to `Navigator.push` modal behavior. No breakage.

## Phase 6: Splash Session-Aware Navigation (PR#6, ~100 lines)

- [x] 6.1 Modify `lib/features/auth/presentation/screens/splash_screen.dart`: replace `Future.delayed(Duration(seconds: 2))` with `ref.watch(authStateProvider.future)` check; show loading indicator while auth state resolves.
- [x] 6.2 Navigate to `/admin` if admin session active, `/dashboard` if employee session active, `/login` if no session.
- [x] 6.3 Test: widget test for `SplashScreen` — verify navigation to dashboard when `authStateProvider` emits non-null employee. File: `test/features/auth/presentation/screens/splash_screen_test.dart`.
- [x] 6.4 Test: widget test for `SplashScreen` — verify navigation to login when `authStateProvider` emits null.

**Rollback boundary**: Revert PR#6 → splash returns to fixed 2s delay. No functional breakage.

## Phase 7: Dashboard Mock Data Cleanup (PR#7, ~250 lines)

- [x] 7.1 Modify `lib/features/admin/presentation/screens/admin_dashboard_screen.dart`: replace `MockData.adminStats` metric cards with loading shimmer or "—" placeholder; preserve widget structure for future Firestore wiring.
- [x] 7.2 Modify `lib/features/admin/presentation/widgets/recent_requests_list.dart`: display empty state instead of `MockData.recentRequests`.
- [x] 7.3 Modify `lib/features/admin/presentation/widgets/control_alerts_panel.dart`: display empty/placeholder state instead of `MockData.controlAlerts`.
- [x] 7.4 Modify `lib/features/dashboard/presentation/widgets/quick_actions_card.dart`: disable unimplemented actions with "Próximamente" badges; keep Edit Record as mock dialog.
- [x] 7.5 Modify `lib/features/admin/presentation/widgets/weekly_activity_chart.dart`: show placeholder "Sin datos" when no real data available.
- [x] 7.6 Modify `lib/features/dashboard/presentation/widgets/monthly_calendar_card.dart` (if exists) or `weekly_summary_card.dart`: replace mock data with loading/empty states.
- [x] 7.7 Test: widget test verifying admin dashboard shows empty/loading states, not mock data. File: `test/features/admin/presentation/screens/admin_dashboard_mock_test.dart`.
- [x] 7.8 Test: widget test verifying employee quick actions show disabled state for unimplemented actions. File: `test/features/dashboard/presentation/widgets/quick_actions_card_test.dart`.

### Verification Fixes (post-PR#7 apply, pre-archive)

- [x] VF1 Add missing tests for MonthlyCalendarCard empty state (no mock special days). File: `test/features/dashboard/presentation/widgets/monthly_calendar_card_test.dart` (2 tests).
- [x] VF2 Add missing tests for WeeklySummaryCard empty state (no mock bar chart values). File: `test/features/dashboard/presentation/widgets/weekly_summary_card_test.dart` (3 tests).
- [x] VF3 Remove hardcoded fake badge `+12` from "Total Empleados" metric card in `admin_dashboard_screen.dart`. Replace with `null`. Test added in `admin_dashboard_mock_test.dart`.
- [x] VF4 Disable "Editar registro" quick action (was mock dialog with hardcoded TimeOfDay). Remove `edit_entrance_dialog.dart` import and `_handleEditEntrance` method. Update `quick_actions_card_test.dart` to verify all 3 actions disabled (3 "Próximo" badges, no dialog, no SnackBar).
- [x] VF5 Replace `MockData.getLastClockIn()` in `employee_table_row.dart` with honest "—" placeholder. Remove `mock_data.dart` import. Test: `test/features/admin/presentation/widgets/employee_table_row_test.dart` (3 tests).

**Rollback boundary**: Revert PR#7 → mock data returns. No data loss, only visual regression.

## Phase 8: Corrective Polish — Dark Mode & Navigation Regression Fixes (PR#8, ~310 lines)

> Based on `explore-regressions.md` audit. User reported dark-mode and navigation issues after reviewing PR#1-PR#7 screenshots.

- [x] 8.1 Modify `lib/shared/widgets/navigation/navigation_items.dart`: remove "Configuración" from ALL employee/supervisor sidebar items (header gear suffices). Update test: `test/shared/widgets/navigation/navigation_items_test.dart`.
- [x] 8.2 Modify `lib/core/theme/app_text_styles.dart`: remove hardcoded `color:` from all static styles (h1–h6, body*, label*, display*, button, caption, overline, link*). Let ThemeData.textTheme supply color per brightness.
- [x] 8.3 Modify `lib/core/theme/app_theme.dart`: add explicit `copyWith(color: ...)` to light theme's TextTheme entries so light mode colors are preserved after 8.2.
- [x] 8.4 Modify `lib/shared/widgets/layouts/custom_app_bar.dart`: default background uses `Theme.of(context).colorScheme.surface` instead of hardcoded `AppColors.surface`.
- [x] 8.5 Modify `lib/shared/widgets/buttons/icon_button_custom.dart`: make default icon colors and backgrounds theme-aware via BuildContext. Replace hardcoded `AppColors.textPrimary`, `AppColors.surfaceVariant`, etc.
- [x] 8.6 Modify `lib/features/dashboard/presentation/widgets/employee_header.dart`: replace `disabledColor` with `colorScheme.onSurfaceVariant.withValues(alpha: 0.5)` for notification bell in both compact and normal variants.
- [x] 8.7 Modify `lib/features/dashboard/presentation/screens/calendar_screen.dart`: app bar icon and title use `Theme.of(context).colorScheme.primary` instead of `AppColors.primary`.
- [x] 8.8 Modify `lib/features/dashboard/presentation/screens/my_time_control_screen.dart`: mobile header uses `Theme.of(context).colorScheme.surface` and `outlineVariant` instead of hardcoded `AppColors.surface`/`AppColors.borderLight`.
- [x] 8.9 Modify `lib/features/dashboard/presentation/screens/profile_screen.dart`: scaffold background uses `Theme.of(context).colorScheme.surface` instead of `AppColors.background`.
- [x] 8.10 Modify `lib/features/admin/presentation/screens/admin_profile_screen.dart`: scaffold background uses `Theme.of(context).colorScheme.surface` instead of `AppColors.background`.
- [x] 8.11 Test: `test/core/theme/app_text_styles_test.dart` (17 tests) — verify all base styles have null color, light/dark themes fill colors.
- [x] 8.12 Test: `test/core/theme/pr8_dark_mode_fixes_test.dart` (10 tests) — verify CustomAppBar, IconButtonCustom, EmployeeHeader, CalendarScreen, MyTimeControlScreen, SettingsScreen, ProfileScreen, AdminProfileScreen dark mode fixes.

**Rollback boundary**: Revert PR#8 → dark mode returns to previous inconsistent visual state. Navigation returns to showing Configuración for supervisors. No functional breakage, only visual.

## Phase 9: Corrective Polish #2 — Dark Mode, Profile & Sidebar Regression Fixes (PR#10, ~250 lines)

> Based on user-reported issues after PR#8/PR#9 review. Six regression categories fixed.

- [x] 9.1 Modify `lib/features/admin/presentation/widgets/admin_sidebar.dart`: remove "Configuración del sistema" from lateral sidebar (header gear suffices). Update test: `test/features/admin/presentation/widgets/admin_sidebar_test.dart`.
- [x] 9.2 Modify `lib/features/admin/presentation/screens/admin_profile_screen.dart`: replace hardcoded `AppColors.primary` and `AppColors.error` with `Theme.of(context).colorScheme` tokens.
- [x] 9.3 Modify `lib/features/auth/presentation/widgets/change_password_dialog.dart`: replace hardcoded `AppColors.primary`/`AppColors.info` with theme-aware colors.
- [x] 9.4 Modify `lib/features/dashboard/presentation/widgets/day_record_card.dart`: replace all hardcoded `AppColors.surface`, `AppColors.borderLight`, `AppColors.textSecondary`, `AppColors.textTertiary`, `AppColors.shadow`, `AppColors.primary` with `Theme.of(context).colorScheme` tokens.
- [x] 9.5 Modify `lib/features/dashboard/presentation/widgets/add_edit_record_modal.dart`: replace `backgroundColor: AppColors.surface` with `Theme.of(context).colorScheme.surface`.
- [x] 9.6 Modify `lib/features/dashboard/presentation/screens/my_time_control_screen.dart`: fix mobile header title to use `Theme.of(scaffoldContext).textTheme.titleMedium` instead of uncolored `const TextStyle()`.
- [x] 9.7 Modify `lib/features/dashboard/presentation/screens/profile_screen.dart`: replace hardcoded `AppColors.primary` in avatar, role badge, and info section icons with `Theme.of(context).colorScheme.primary`.
- [x] 9.8 Test: `test/core/theme/pr10_corrective_polish_test.dart` (7 tests) — verify AdminSidebar, AdminProfileScreen, ChangePasswordDialog, DayRecordCard, AddEditRecordModal, MyTimeControlScreen, ProfileScreen dark mode fixes.

**Rollback boundary**: Revert PR#10 → dark mode returns to previous inconsistent state on DayRecordCard and dialogs. Sidebar shows Configuración del sistema again. No functional breakage.

## Phase 11: Corrective Polish #3 — Sidebar Swap & Dark Mode Fixes (PR#11, ~200 lines)

> Based on user-reported issues after PR#10 review. PR#10 removed the wrong sidebar item. Additionally, several screens still have dark-mode issues: AdminSettingsScreen, NewEmployeeDrawer (49 hardcoded colors), MyTimeControlScreen error icon.

- [x] 11.1 Modify `lib/features/admin/presentation/widgets/admin_sidebar.dart`: swap sidebar items — keep "Configuración del sistema" (`AppRouter.adminSettings`), remove "Mi cuenta" (profile access via header avatar). Update test: `test/features/admin/presentation/widgets/admin_sidebar_test.dart`.
- [x] 11.2 Modify `lib/features/admin/presentation/screens/admin_settings_screen.dart`: replace hardcoded `AppColors.background`, `AppColors.textSecondary` with `Theme.of(context).colorScheme` tokens for dark mode.
- [x] 11.3 Modify `lib/features/admin/presentation/widgets/new_employee_drawer.dart`: replace 49 hardcoded `AppColors.surface`, `AppColors.textPrimary`, `AppColors.textSecondary`, `AppColors.textTertiary`, `AppColors.border`, `AppColors.surfaceVariant` with `Theme.of(context).colorScheme` tokens.
- [x] 11.4 Modify `lib/features/dashboard/presentation/screens/my_time_control_screen.dart`: fix hardcoded `AppColors.error` icon in error state to use `Theme.of(context).colorScheme.error`.
- [x] 11.5 Test: `test/core/theme/pr11_corrective_polish_test.dart` (3 tests) — verify AdminSettingsScreen dark mode, DayRecordCard dark mode text visibility.
- [x] 11.6 Test: update `test/features/admin/presentation/widgets/admin_sidebar_test.dart` (3 tests) — verify "Configuración del sistema" is present, "Mi cuenta" is absent, navigation routes to admin settings.

**Rollback boundary**: Revert PR#11 → sidebar shows "Mi cuenta" again, "Configuración del sistema" disappears. Dark mode breaks on AdminSettingsScreen and NewEmployeeDrawer. No functional breakage.

## Phase 12: Corrective Polish #4 — Dark Mode Contrast Regression Fixes (PR#12, ~200 lines)

> Based on user-reported remaining dark-mode issues after PR#11 review. Six surfaces still hardcode AppColors instead of using Theme.of(context).colorScheme tokens.

- [x] 12.1 Modify `lib/features/admin/presentation/screens/admin_dashboard_screen.dart`: replace `AppColors.textSecondary` subtitle with `Theme.of(context).colorScheme.onSurfaceVariant`.
- [x] 12.2 Modify `lib/features/admin/presentation/screens/employees_list_screen.dart`: replace hardcoded `AppColors.textSecondary`, `AppColors.textTertiary`, `AppColors.surface`, `AppColors.border`, `AppColors.primary` in descriptions, filter chips, table container, pagination with `Theme.of(context).colorScheme` tokens.
- [x] 12.3 Modify `lib/features/admin/presentation/screens/schedule_management_screen.dart`: replace `AppColors.textSecondary`, `AppColors.textTertiary` in descriptions, empty state, error text with theme tokens.
- [x] 12.4 Modify `lib/features/admin/presentation/screens/calendar_management_screen.dart`: fix tip banner (reversed AppColors.textPrimary/surface), breadcrumbs, empty state colors → theme tokens. Pass `BuildContext` to `_buildTipBanner`.
- [x] 12.5 Modify `lib/features/admin/presentation/widgets/week_schedule_viewer.dart`: replace ALL hardcoded `AppColors.textPrimary`, `AppColors.textSecondary`, `AppColors.textTertiary`, `AppColors.surfaceVariant`, `AppColors.border`, `AppColors.borderLight`, `AppColors.primary`, `AppColors.secondary` in day names, hour text, schedule table, empty state with `Theme.of(context).colorScheme` tokens. Pass `BuildContext` to helper methods.
- [x] 12.6 Modify `lib/features/dashboard/presentation/screens/my_time_control_screen.dart`: replace `ElevatedButton.styleFrom(backgroundColor: AppColors.error)` with `Theme.of(context).colorScheme.error`.
- [x] 12.7 Test: `test/core/theme/pr12_dark_mode_correction_test.dart` (10 tests) — verify 6 screens use theme tokens, not hardcoded AppColors in dark mode.

**Rollback boundary**: Revert PR#12 → dark mode returns to hardcoded light-mode AppColors on these 6 surfaces. No functional breakage, only visual.

## Phase 13: Slice A — Shared Widgets Root Theming Migration (PR#13, ~350 lines)

> Based on `exploration.md` root-cause audit. Migrates all Tier 1 shared widgets from light-only AppColors surface/text/border tokens to `Theme.of(context).colorScheme` tokens. This fixes ALL screens that compose these shared widgets in one slice.

- [x] 13.1 Migrate `lib/shared/widgets/cards/metric_card.dart`: `AppColors.surface`→`colorScheme.surface`, `AppColors.border`→`colorScheme.outline`, `AppColors.textPrimary`→`colorScheme.onSurface`, `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`.
- [x] 13.2 Migrate `lib/shared/widgets/cards/schedule_card.dart`: `AppColors.surface`→`colorScheme.surface`, `AppColors.border`→`colorScheme.outline`, `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`, `AppColors.textTertiary`→`colorScheme.outline`.
- [x] 13.3 Migrate `lib/shared/widgets/cards/stat_card.dart`: `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`.
- [x] 13.4 Migrate `lib/shared/widgets/cards/info_card.dart`: `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`, `AppColors.textTertiary`→`colorScheme.outline`, `AppColors.borderLight`→`colorScheme.outlineVariant`.
- [x] 13.5 Migrate `lib/shared/widgets/buttons/custom_button.dart`: `AppColors.surfaceVariant`→`colorScheme.surfaceContainerHighest`, `AppColors.textPrimary`→`colorScheme.onSurface`, `AppColors.textTertiary`→`colorScheme.outline`. Thread BuildContext to variant methods.
- [x] 13.6 Migrate `lib/shared/widgets/empty_state.dart`: `AppColors.background`→`scaffoldBackgroundColor`, `AppColors.textPrimary`→`colorScheme.onSurface`, `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`, `AppColors.textTertiary`→`colorScheme.outline`.
- [x] 13.7 Migrate `lib/shared/widgets/error_state.dart`: `AppColors.background`→`scaffoldBackgroundColor`, `AppColors.textPrimary`→`colorScheme.onSurface`, `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`.
- [x] 13.8 Migrate `lib/shared/widgets/loading_spinner.dart`: `AppColors.background`→`scaffoldBackgroundColor`, `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`, `AppColors.surface`→`colorScheme.surface`.
- [x] 13.9 Migrate `lib/shared/widgets/inputs/time_picker_field.dart`: all surface/text/border tokens + TimePickerThemeData colors.
- [x] 13.10 Migrate `lib/shared/widgets/inputs/custom_text_field.dart`: 3 occurrences of `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`.
- [x] 13.11 Migrate `lib/shared/widgets/inputs/custom_password_field.dart`: `AppColors.textSecondary`, `AppColors.borderLight`→`colorScheme.outlineVariant` + `_getStrengthData` default case.
- [x] 13.12 Migrate `lib/shared/widgets/editors/week_schedule_editor.dart`: `AppColors.textPrimary`→`colorScheme.onSurface`, `AppColors.textSecondary`→`colorScheme.onSurfaceVariant`, time picker theme surface tokens.
- [x] 13.13 Migrate `lib/shared/widgets/layouts/custom_app_bar.dart`: `AppColors.surfaceVariant`→`colorScheme.surfaceContainerHighest` in search bar fill.
- [x] 13.14 Test: `test/core/theme/slice_a_shared_widgets_theme_test.dart` (33 tests) — verify all 13 widgets use theme tokens, not hardcoded AppColors in dark mode.

**Rollback boundary**: Revert PR#13 → shared widgets return to light-only colors. No functional breakage, only visual.

## Phase 14: Slice B — Feature Widgets Root Theming Migration (PR#14, ~250 lines)

> Tier 2 high-priority feature widgets from root theming audit. Migrates the 4 most user-visible feature widgets from light-only AppColors surface/text/border tokens to `Theme.of(context).colorScheme` tokens.

- [x] 14.1 Migrate `lib/features/dashboard/presentation/widgets/month_navigation_header.dart`: 13 AppColors violations → colorScheme tokens. Thread `ColorScheme` through `_getDifferenceColor`, `_buildMetricsDesktop`, `_buildMetricsMobile`, `_buildMetricItem`. `AppColors.surface`→`colorScheme.surface`, `surfaceVariant`→`surfaceContainerHighest`, `textPrimary`→`onSurface`, `textSecondary`→`onSurfaceVariant`, `borderLight`→`outlineVariant`.
- [x] 14.2 Migrate `lib/features/admin/presentation/widgets/employee_table_row.dart`: 11 AppColors violations → colorScheme tokens. `surface`→`colorScheme.surface`, `border`→`outline`, `textPrimary`→`onSurface`, `textSecondary`→`onSurfaceVariant`, `textTertiary`→`outline`.
- [x] 14.3 Migrate `lib/features/admin/presentation/widgets/weekly_activity_chart.dart`: 11 AppColors violations → colorScheme tokens. `surface`→`colorScheme.surface`, `border`→`outline`, `textPrimary`→`onSurface`, `textSecondary`→`onSurfaceVariant`, `textTertiary`→`outline`. Added `cs` to `_ChartPainter` build method for inner widget.
- [x] 14.4 Migrate `lib/features/admin/presentation/screens/calendar_editor_screen.dart`: 39 AppColors violations → colorScheme tokens (largest file in codebase). `background`→`scaffoldBackgroundColor`, `surface`→`colorScheme.surface`, `border`→`outline`, `textPrimary`→`onSurface`, `textSecondary`→`onSurfaceVariant`, `textTertiary`→`outline`. Passed `ColorScheme` to `_buildPageHeader`. Added `cs` in build method.
- [x] 14.5 Test: `test/core/theme/slice_b_feature_widgets_theme_test.dart` (21 tests) — verify all 4 feature widgets use theme tokens, not hardcoded AppColors in dark mode.

**Rollback boundary**: Revert PR#14 → feature widgets return to light-only colors. No functional breakage, only visual.

## Phase 14B: Slice B2 — Remaining Dashboard Feature Widgets Theming (PR#15)

> Remaining Tier 2 dashboard feature widgets from root theming audit. Migrates 5 feature widgets with 25 remaining AppColors surface/text/border violations to `Theme.of(context).colorScheme` tokens.

- [x] 14B.1 Migrate `lib/features/dashboard/presentation/widgets/day_record_card.dart`: 2 AppColors violations → colorScheme tokens. `textTertiary`→`outline` (delete button disabled state). Threaded `ColorScheme` into `_getDifferenceColor` for `textSecondary`→`onSurfaceVariant`.
- [x] 14B.2 Migrate `lib/features/dashboard/presentation/widgets/add_edit_record_modal.dart`: 12 AppColors violations → colorScheme tokens. `textTertiary`→`outline` (separator dash, duration disabled). `textSecondary`→`onSurfaceVariant` (subtitle, section label, duration label, validated warning body). `textPrimary`→`onSurface` (active record warning). `primary`→`cs.primary` (header icon, button bg, duration icon). `textOnPrimary`→`cs.onPrimary` (button fg, loading indicator). Added `cs` in build(), `_buildHeader`, `_buildValidatedWarning`, `_buildActiveRecordWarning`, `_buildSectionLabel`, `_buildDurationDisplay`. Removed `const` from SizedBox wrapping CircularProgressIndicator.
- [x] 14B.3 Migrate `lib/features/dashboard/presentation/widgets/blocked_record_modal.dart`: 10 AppColors violations → colorScheme tokens. `surface`→`cs.surface` (dialog bg). `surfaceVariant`→`cs.surfaceContainerHighest` (info section bg). `textSecondary`→`cs.onSurfaceVariant` (body, help text, info section title/labels). `textPrimary`→`cs.onSurface` (info values). `primary`→`cs.primary` (button bg). `textOnPrimary`→`cs.onPrimary` (button fg). Passed `ColorScheme` to `_buildInfoSection`. Updated `_InfoItem.build()` with `cs.onSurfaceVariant`/`cs.onSurface`.
- [x] 14B.4 Migrate `lib/features/dashboard/presentation/widgets/category_tab_selector.dart`: 4 AppColors violations → colorScheme tokens. `surfaceVariant`→`cs.surfaceContainerHighest` (container bg). `surface`→`cs.surface` (selected tab bg). `textSecondary`→`cs.onSurfaceVariant` (2 occurrences: icon + label when not selected). Passed `ColorScheme` to `_buildTab`.
- [x] 14B.5 Migrate `lib/features/dashboard/presentation/widgets/future_month_empty_state.dart`: 7 AppColors violations → colorScheme tokens. `surfaceVariant`→`cs.surfaceContainerHighest` (icon container). `textSecondary`→`cs.onSurfaceVariant` (icon + body text). `textPrimary`→`cs.onSurface` (title + info text). `primary`→`cs.primary` (button bg). `textOnPrimary`→`cs.onPrimary` (button fg). Removed `const` from Icon using dynamic color.
- [x] 14B.6 Test: `test/core/theme/slice_b2_feature_widgets_theme_test.dart` (20 tests) — verify all 5 widgets use theme tokens, not hardcoded AppColors in dark mode.

**Rollback boundary**: Revert PR#15 → B2 widgets return to light-only colors. No functional breakage, only visual.

## Phase 15: Slice C — Tier 3+4 Screens/Navigation + Permanent Guard (PR#16)

> Remaining Tier 3+4 files from root theming audit. Migrates login, splash, admin anomaly/OT/report screens, error screen, login footer, desktop sidebar, and app_text_styles extensions to `Theme.of(context).colorScheme` tokens. Adds permanent guard test.

- [x] 15.1 Migrate `lib/features/auth/presentation/widgets/login_footer.dart`: 2 `AppColors.textTertiary` → `Theme.of(context).colorScheme.outline`. Remove unused `app_colors.dart` import.
- [x] 15.2 Migrate `lib/features/admin/presentation/screens/reports_screen.dart`: 1 `AppColors.textSecondary` → `Theme.of(context).colorScheme.onSurfaceVariant` (Período label).
- [x] 15.3 Migrate `lib/features/admin/presentation/screens/overtime_review_screen.dart`: 2 `AppColors.textSecondary` → `colorScheme.onSurfaceVariant`. Thread `ColorScheme` through `_buildEmptyState`, `_buildRequestList`, `_OvertimeRequestCard`.
- [x] 15.4 Migrate `lib/features/admin/presentation/screens/anomalies_screen.dart`: 4 violations → `colorScheme.onSurfaceVariant`/`outline`. Thread `ColorScheme` through `_buildEmptyState`, `_buildAnomalyList`, `_AnomalyCard`.
- [x] 15.5 Migrate `lib/features/auth/presentation/screens/login_screen.dart`: 5 violations → `scaffoldBackgroundColor`, `colorScheme.surface`, `onSurface`, `onSurfaceVariant`.
- [x] 15.6 Migrate `lib/features/auth/presentation/screens/splash_screen.dart`: 2 violations → `scaffoldBackgroundColor`, `colorScheme.onSurfaceVariant`.
- [x] 15.7 Migrate `lib/core/router/app_router.dart`: 1 violation → `colorScheme.onSurfaceVariant` in `_ErrorScreen`.
- [x] 15.8 Migrate `lib/shared/widgets/navigation/desktop_sidebar.dart`: 4 violations in light-mode branches → `Theme.of(context).colorScheme.onSurface`. Remove unused `app_colors.dart` import.
- [x] 15.9 Deprecate `.secondary` and `.tertiary` extensions in `lib/core/theme/app_text_styles.dart`. Add context-aware `onSurfaceVariant(ColorScheme)` and `outline(ColorScheme)` alternatives. Zero callers in production code — safe to deprecate.
- [x] 15.10 Add permanent guard test `test/core/theme/forbidden_appcolors_guard_test.dart` that scans `lib/features/` and `lib/shared/` for forbidden `AppColors.background|surface|surfaceVariant|textPrimary|textSecondary|textTertiary|border|borderLight` tokens. Allowed: semantic tokens (`primary`, `success`, `error`, `warning`, `info`). Exceptions documented via `_allowedExceptions` set.
- [x] 15.11 Test: `test/core/theme/slice_c_tier3_4_theme_test.dart` (8 tests) — widget tests verifying LoginFooter, AnomaliesScreen, OvertimeReviewScreen, ReportsScreen use theme tokens in dark mode.

**Rollback boundary**: Revert PR#16 → Tier 3/4 screens return to light-only colors; guard removed. No functional breakage, only visual.

## Phase 16: Slice D — Remaining lib/features Violations (PR#17)

> Remaining 71 forbidden AppColors violations in 11 admin feature files. Migrates all remaining surface/text/border tokens to `Theme.of(context).colorScheme` so the permanent guard passes fully.

- [x] 16.1 Migrate `lib/features/admin/presentation/screens/employee_detail_screen.dart`: 11 violations → `scaffoldBackgroundColor`, `colorScheme.onSurfaceVariant`, `colorScheme.outline`. Thread `ColorScheme` through `_buildContent`, `_buildNotFound`, `_buildError`, `_buildInfoRow`, `_buildCalendarRow`, `_buildAssignedSupervisorRow`.
- [x] 16.2 Migrate `lib/features/admin/presentation/widgets/calendar_card.dart`: 10 violations → `colorScheme.surface`, `colorScheme.outline`, `colorScheme.onSurfaceVariant`. Thread `ColorScheme` to `_buildHeader`, `_buildStatusBadge`, `_buildActions`.
- [x] 16.3 Migrate `lib/features/admin/presentation/widgets/day_editor_dialog.dart`: 9 violations → `colorScheme.onSurfaceVariant`, `colorScheme.outline`, `colorScheme.surfaceContainerHighest`, `colorScheme.onSurface`. Thread `ColorScheme` to `_buildTypeSelector`, `_buildDateRangePicker`.
- [x] 16.4 Migrate `lib/features/admin/presentation/widgets/employee_schedule_editor_modal.dart`: 9 violations → `colorScheme.onSurfaceVariant`, `colorScheme.outline`. Thread `ColorScheme` to `_buildTemplateSelector`, `_buildCustomScheduleEditor`.
- [x] 16.5 Migrate `lib/features/admin/presentation/widgets/employee_table_header.dart`: 8 violations → `colorScheme.surfaceContainerHighest`, `colorScheme.outline`. Remove unused `app_colors.dart` import.
- [x] 16.6 Migrate `lib/features/admin/presentation/widgets/employee_list_item.dart`: 8 violations → `colorScheme.surface`, `colorScheme.outline`, `colorScheme.onSurfaceVariant`. Thread `ColorScheme` to `_buildStatusBadge`.
- [x] 16.7 Migrate `lib/features/admin/presentation/widgets/recent_requests_list.dart`: 7 violations → `colorScheme.surface`, `colorScheme.outline`, `colorScheme.onSurfaceVariant`. Thread `ColorScheme` to `_RequestItem`, `_getStatusColor`.
- [x] 16.8 Migrate `lib/features/admin/presentation/widgets/control_alerts_panel.dart`: 5 violations → `colorScheme.surface`, `colorScheme.outline`, `colorScheme.onSurface`, `colorScheme.onSurfaceVariant`. Thread `ColorScheme` to `_AlertItem`.
- [x] 16.9 Migrate `lib/features/admin/presentation/widgets/supervisor_assignment_field.dart`: 4 violations → `colorScheme.onSurfaceVariant`, `colorScheme.outline`. Extract `cs` in build().
- [x] 16.10 Migrate `lib/features/admin/presentation/widgets/employee_info_editor_modal.dart`: 3 violations → `colorScheme.outline`, `colorScheme.onSurfaceVariant`. Extract `cs` in build().
- [x] 16.11 Migrate `lib/features/admin/presentation/widgets/schedule_template_modal.dart`: 2 violations → `colorScheme.onSurfaceVariant`, `colorScheme.outline`. Extract `cs` in build().
- [x] 16.12 Test: `test/core/theme/slice_d_feature_widgets_theme_test.dart` (6 tests) — verify EmployeeTableHeader, CalendarCard, ControlAlertsPanel, RecentRequestsList, EmployeeListItem, SupervisorAssignmentField render in dark mode without forbidden AppColors.

**Rollback boundary**: Revert PR#17 → 71 violations return; guard fails for features/. No functional breakage, only visual.

## Phase 17: Overflow Fix — EmployeesListScreen Action Bar (post-Slice-D follow-up)

> Bugfix: 2 RenderFlex overflow failures in `EmployeesListScreen` tests from `pr12_dark_mode_correction_test.dart`. The screen wrapped content in a redundant `SingleChildScrollView(padding: AppSpacing.allXxl)` inside `AdminLayout` which already provides scrolling and responsive padding. The double padding left only 640px for the action bar `Row`, causing button overflow.

- [x] 17.1 Remove redundant `SingleChildScrollView` wrapper and padding from `lib/features/admin/presentation/screens/employees_list_screen.dart` (AdminLayout already provides scroll + padding).
- [x] 17.2 Wrap action bar buttons in `Flexible` to allow them to shrink at narrower viewports, preventing RenderFlex overflow at tablet widths (720-1024px logical).
- [x] 17.3 Fix 4 pre-existing analyzer warnings in test files (`_allBaseStyles`→`allBaseStyles`, `_wrapAdminTest`→`wrapAdminTest`, `_wrapSettingsDark`→`wrapSettingsDark`, remove unused `_contrastRatio`) so `flutter analyze --fatal-infos --fatal-warnings` passes.
- [x] 17.4 Add triangulation test: "action bar does not cause RenderFlex overflow at tablet width (720px)" in `test/core/theme/pr12_dark_mode_correction_test.dart`.
- [x] 17.5 Verify all 159 theme tests pass, forbidden AppColors guard still passes.

**Rollback boundary**: Revert → action bar overflows again at 720px logical width. No functional breakage, only layout fix.

## Phase 18: Post-Slice-D Bugfix — Admin Brand Header Green Gradient Leak (~30 lines)

> User-reported: admin panel logo/"Control Horario" area shows green background block breaking color scheme coherence.

**Root cause**: `admin_sidebar.dart` and `mobile_drawer.dart` `_buildHeader`/`_buildDrawerHeader` construct dark-mode gradient inline using `Theme.of(context).colorScheme.primary` + `.secondary`. In dark mode, `colorScheme.primary` = `#22C55E` (green) — the green action-color leaks into the brand header as a large background block. The `AppColorsDark.primaryGradient` (cyan→purple `#06B6D4→#A855F7`) already exists as the correct dark brand gradient but was unused in these widgets.

- [x] 18.1 Fix `lib/features/admin/presentation/widgets/admin_sidebar.dart`: replace inline dark-mode gradient `LinearGradient(colors: [colorScheme.primary, colorScheme.secondary])` with `AppColorsDark.primaryGradient`. Add `app_colors_dark.dart` import.
- [x] 18.2 Fix `lib/shared/widgets/navigation/mobile_drawer.dart`: same fix — replace dark-mode inline gradient with `AppColorsDark.primaryGradient`.
- [x] 18.3 Test: dark mode gradient test in `test/features/admin/presentation/widgets/admin_sidebar_test.dart` (asserts gradient matches `AppColorsDark.primaryGradient`, not green colorScheme.primary).
- [x] 18.4 Test: dark mode gradient test in `test/shared/widgets/navigation/mobile_drawer_test.dart` (same assertion for DrawerHeader).
- [x] 18.5 Test: light mode triangulation tests in both files (assert gradient matches `AppColors.primaryGradient` in light mode).
- [x] 18.6 Verify: `flutter analyze --fatal-infos --fatal-warnings` clean, `dart format --set-exit-if-changed lib/ test/` clean, forbidden AppColors guard passes, all admin sidebar + mobile drawer tests pass.

**Rollback boundary**: Revert → green gradient returns to admin sidebar header and mobile drawer. No functional breakage, only visual.

## Phase 19: Post-Slice-D Refinement — Admin Brand Header Matches Employee Panel (~20 lines)

> User-requested: admin sidebar brand area (logo + "Control Horario") should use the same color/pattern as the employee panel's equivalent area. The admin sidebar currently renders a gradient (cyan→purple dm / deep blue→violet lm) while the employee `DesktopSidebar._buildHeader` uses a plain background with `colorScheme.primary` text and icon colors.

**Employee pattern found**: `DesktopSidebar._buildHeader` — plain `Container` inheriting sidebar background, bottom border via `dividerColor`, `Icons.access_time` in `colorScheme.primary` (size 28), "Control Horario" in `FontSize 18`/`FontWeight.w700` colored `colorScheme.primary` (light) / `AppColorsDark.textPrimary` (dark).

- [x] 19.1 Modify `lib/features/admin/presentation/widgets/admin_sidebar.dart` `_buildHeader`: remove gradient `BoxDecoration`; replace with plain container matching employee `DesktopSidebar._buildHeader` pattern (bottom border, `colorScheme.primary` icon, themed text).
- [x] 19.2 Test: replace gradient assertion tests in `admin_sidebar_test.dart` with 2 tests asserting NO gradient exists in dark/light mode (employee-panel pattern verification).
- [x] 19.3 Verify: `flutter analyze --fatal-infos --fatal-warnings` clean, `dart format --set-exit-if-changed` clean, forbidden AppColors guard passes, mobile drawer tests unchanged, all admin sidebar tests pass.

**Rollback boundary**: Revert → gradient returns to admin sidebar header. No functional breakage, only visual.

## Phase 20: Post-Slice-D Alignment — Admin Brand Header Divider Aligns with Main Header (~15 lines)

> User-requested: the line separating "Control Horario" from "Panel principal" must align at the same height as the main admin header line so sidebar + header look like one continuous header.

**Root cause**: `AdminSidebar._buildHeader` Container had no fixed height (padding-based, ~53px), while `_AdminHeader` in `admin_layout.dart` uses `height: 64` + `colorScheme.outline` bottom border. The sidebar divider sat ~11px above the main header's divider.

**Fix**: Set `height: 64` on the sidebar brand header and change border color from `dividerColor` to `colorScheme.outline` to match the adjacent main admin header.

- [x] 20.1 Fix `lib/features/admin/presentation/widgets/admin_sidebar.dart` `_buildHeader`: add `height: 64`, change border to `colorScheme.outline`, remove vertical padding (fixed height handles centering).
- [x] 20.2 Test: add widget tests asserting sidebar brand header rendered height = 64px and border uses `colorScheme.outline` (light + dark mode triangulation).
- [x] 20.3 Verify: `flutter analyze --fatal-infos --fatal-warnings` clean, `dart format --set-exit-if-changed` clean, forbidden AppColors guard passes, admin sidebar 7/7, admin layout 3/3.

**Rollback boundary**: Revert → sidebar divider returns ~11px misaligned. No functional breakage, only visual.
