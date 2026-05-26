# Audit: User-Reported Regressions after panel-navigation-feature-cleanup

> **Phase**: explore (read-only audit)
> **Date**: 2026-05-25
> **Target**: PR#8 polish/fixes scope

---

## 1. Issue-by-Issue Confirmation

### 1.1 — Employee panel has duplicate settings options
**CONFIRMED** from code.
- `navigation_items.dart:66-71`: "Configuración" appears in sidebar/drawer when `canSuperviseTeam == true` (routes to `/settings`).
- `employee_header.dart:372-381` + `dashboard_screen.dart:183`: Settings gear in header always visible, routes to `/settings`.
- For supervisors: both shown. For regular employees: only header gear (sidebar item gated by `canSuperviseTeam`).

### 1.2 — Dark mode: texts don't change color, disappear
**CONFIRMED — systemic.** Multiple root causes:
- **`app_text_styles.dart`**: All styles (`h1`–`h6`, `bodyLarge`–`bodySmall`, `label*`) hardcode `color: AppColors.textPrimary` (#0F172A near-black). When dark mode is active, background is #000414/#0F172B → black text on dark bg = invisible.
- **`calendar_screen.dart:146-153`**: `color: AppColors.primary` and `color: AppColors.textPrimary` in appbar.
- **`my_time_control_screen.dart:83-111`**: `AppColors.surface`, `AppColors.borderLight`, title without explicit color.
- **`profile_screen.dart:28,350-352`**: `backgroundColor: AppColors.background` + `AppTextStyles.h2` (black text).
- **`day_record_card.dart`:62,65-67,157**: `AppColors.surface`, border, text colors.

`AppTheme.darkTheme` *does* correctly override `textTheme` with `AppColorsDark.textPrimary`. But widgets using `AppTextStyles.xxx` directly bypass `Theme.of(context).textTheme`.

### 1.3 — Back arrow not visible in dark mode
**CONFIRMED.** Root cause chain:
- `custom_app_bar.dart:109`: `backgroundColor: backgroundColor ?? AppColors.surface` → hardcodes **white** (#FFFFFF).
- `app_theme.dart:512-515`: dark theme `AppBarTheme.iconTheme` sets `color: AppColorsDark.textPrimary` (white).
- Result: white back arrow icon on white background → invisible.

### 1.4 — "Mi calendario", "Control horario", "Cuenta" don't switch well to dark mode
**CONFIRMED.** Same root cause as 1.2 (hardcoded AppColors in these screens):
| Screen | File | Issue |
|--------|------|-------|
| Calendario | `calendar_screen.dart:106-161` | `_buildAppBar` uses `AppColors.primary`, `AppColors.textPrimary` |
| Control Horario | `my_time_control_screen.dart:80-116` | `_buildMobileHeader` uses `AppColors.surface`, `AppColors.borderLight` |
| Cuenta | `settings_screen.dart:33` | `backgroundColor: Theme.of(context).colorScheme.surface` IS theme-aware, but sub-elements use `AppTextStyles.xxx` with hardcoded color |

### 1.5 — Notification icon disappears in dark mode
**CONFIRMED.** Root cause:
- `employee_header.dart:353` and `employee_header.dart:394`: `color: Theme.of(context).disabledColor` used for notification bell.
- `app_theme.dart` dark theme does NOT explicitly configure `disabledColor`. Material 3 dark default ≈ `onSurface.withOpacity(0.38)` (semi-transparent white), low contrast on dark `surface` (#0F172B).
- `icon_button_custom.dart:186`: `tonal` variant hardcodes `backgroundColor: AppColors.surfaceVariant` (#F1F5F9 light gray) even in dark mode.

### 1.6 — "Editar" has errors
**PARTIALLY CONFIRMED (dark mode) / NEEDS RUNTIME CLARIFICATION.**
Flows audited:
- **QuickActionsCard "Editar registro"**: `onTap: null` (honest disabled — no error expected).
- **DayRecordCard edit button**: `color: AppColors.textSecondary` hardcoded → low contrast in dark.
- **AddEditRecordModal**: `backgroundColor: AppColors.surface`, `AppColors.primary` hardcoded → dialog appears light-on-dark, may look broken.
- **ProfileEditDialog**: Uses `AppColorsHelper` → theme-aware. OK.
- **ProfileScreen "Editar Perfil"**: `CustomButton` → uses theme. OK.

### 1.7 — Admin panel: sidebar "Mi cuenta" and header seem to have same function
**CONFIRMED (duplication).**
- `admin_sidebar.dart:110-117`: "Mi cuenta" → `AppRouter.settings` (`/settings`) → `SettingsScreen`.
- `admin_layout.dart:243`: Header avatar → `AppRouter.adminProfile` (`/admin/profile`) → `AdminProfileScreen`.
- Both screens share: dark mode toggle, language selector, "Mi perfil" link, "Contraseña y Seguridad", logout button (~80% overlap).
- "Admin Sistema" string not found in code — header fallback is `'Admin'` (line 287).

---

## 2. Root Causes Summary

| ID | Description | Key files |
|----|-------------|-----------|
| RC1 | `CustomAppBar` hardcodes `AppColors.surface` (white) as default bg | `custom_app_bar.dart:109` |
| RC2 | `AppTextStyles` define static `color: AppColors.textPrimary` (#0F172A) | `app_text_styles.dart` (all styles) |
| RC3 | Widgets use `AppColors.xxx` directly instead of `Theme.of(context).colorScheme.xxx` | `calendar_screen.dart`, `my_time_control_screen.dart`, `profile_screen.dart`, `day_record_card.dart`, `add_edit_record_modal.dart`, `admin_profile_screen.dart` |
| RC4 | `IconButtonCustom` hardcodes `AppColors.textPrimary`, `AppColors.surfaceVariant` as defaults | `icon_button_custom.dart:259-262` |
| RC5 | Notification bell uses `disabledColor` without dark theme override | `employee_header.dart:353,394`, missing from `app_theme.dart` |
| RC6 | Sidebar "Configuración" visible for supervisors + header gear always visible | `navigation_items.dart:66-71`, `employee_header.dart:372` |
| RC7 | `AdminProfileScreen` and `SettingsScreen` share ~80% functionality | `admin_profile_screen.dart`, `settings_screen.dart` |

---

## 3. Recommended PR#8 Scope (~370 lines)

| Task | Files | Est. lines | Description |
|------|-------|-----------|-------------|
| 8.1 | `custom_app_bar.dart:109` | 3 | `AppColors.surface` → `Theme.of(context).colorScheme.surface` |
| 8.2 | `icon_button_custom.dart:259-262` | 8 | Default colors → theme-aware |
| 8.3 | `employee_header.dart:349-354,391-403` | 10 | Replace `disabledColor` with `onSurfaceVariant` at explicit opacity |
| 8.4 | `app_text_styles.dart` | 80 | Remove hardcoded `color:` from all styles; let ThemeData.textTheme supply color |
| 8.5 | `calendar_screen.dart:106-161` | 20 | `_buildAppBar` → theme-aware tokens |
| 8.6 | `my_time_control_screen.dart:80-116` | 15 | `_buildMobileHeader` → theme-aware tokens |
| 8.7 | `navigation_items.dart:60-71` | 5 | Remove "Configuración" from all roles (header gear suffices) |
| 8.8 | Tests: `app_text_styles_test.dart` | 40 | Verify styles have no fixed color |
| 8.9 | Tests: `custom_app_bar_test.dart` | 35 | Verify back arrow visible in dark mode |
| 8.10 | Tests: screen widget tests | 50 | CalendarScreen, MyTimeControlScreen, SettingsScreen dark mode |
| 8.11 | Tests: `navigation_items_test.dart` | 20 | Verify Configuración absent |

**Split not needed.** If implementation exceeds 400 lines, natural split: PR#8a (theme: 8.1–8.6) + PR#8b (navigation+tests: 8.7–8.11).

---

## 4. Test Strategy

| Issue | Test | Assertion |
|-------|------|-----------|
| P2, P4 | `settings_screen_test.dart` | All text finders visible in dark theme |
| P2, P4 | `calendar_screen_test.dart` | "Calendario" title visible in dark theme |
| P2, P4 | `my_time_control_screen_test.dart` | "Mi Control Horario" visible in dark theme |
| P3 | `custom_app_bar_test.dart` | Back arrow contrast > 3:1 in dark mode |
| P5 | `employee_header_test.dart` | Notification icon opacity ≥ 0.6 in dark mode |
| P1 | `navigation_items_test.dart` | `items(canSuperviseTeam: true)` excludes "Configuración" |
| P6 | `add_edit_record_modal_test.dart` | Dialog legible in dark theme |
| P7 | `admin_sidebar_test.dart` | Sidebar "Mi cuenta" routes to `/settings`, not `/admin/profile` |
| RC2 | `app_text_styles_test.dart` | `h1`–`h6`, `body*`, `label*` have null color |

---

## 5. Clarifications Needed from User

1. **Issue 1.6 ("Editar tiene errores")**: Are these visual errors (can't read text in dark mode) or runtime errors (crashes, null errors)? The only flow with hardcoded light-mode colors is `AddEditRecordModal` (dark mode rendering issue). If there are runtime errors, need stacktrace.

2. **Issue 1.7 ("Admin Sistema")**: The string is not in codebase — header fallback is `'Admin'`. If you see "Admin Sistema" at runtime, it may be coming from Firestore user document. Please confirm exact text shown.
