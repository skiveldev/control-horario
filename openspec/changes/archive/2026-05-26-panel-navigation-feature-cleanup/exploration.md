# Exploration: Root-Cause Audit of Persistent Dark-Mode Regressions

> **Phase**: explore (read-only audit, no production code changes)
> **Date**: 2026-05-25
> **Trigger**: User said "dejemos de dar vueltas y busquemos una solucion desde la raiz" after 8+ PR slices still left dark-mode broken

---

## Current State

Despite PR#8 through PR#12 fixing individual files, **262 hardcoded `AppColors.surface/background/text*/border` references** remain across 41 production files. The approach of fixing individual files (whack-a-mole) cannot succeed because:

1. The codebase has **two parallel static color systems** (`AppColors` for light, `AppColorsDark` for dark) with no compile-time or lint enforcement to prefer `Theme.of(context).colorScheme`.
2. **Shared widgets** (custom_button, metric_card, schedule_card, time_picker_field, etc.) still use hardcoded AppColors, so every screen that composes them inherits the bug.
3. **`AppTextStyles` extension methods** (`.secondary`, `.tertiary`, `.success`, `.warning`, `.error`, `.info`) hardcode `AppColors` directly, bypassing ThemeData.
4. **`context.colors` extension** exists in `app_colors_helper.dart` but has **zero usage** in production code.
5. The `AppColorsHelper.of(context)` helper has only **54 uses** vs 262 remaining violations — developers find it too verbose.

### Specific user-reported surfaces still broken

| Surface | File | Violations | Root issue |
|---------|------|-----------|------------|
| Employee "Mi control horario" header | `month_navigation_header.dart` | 13 | `AppColors.surface`, `AppColors.textPrimary`, `AppColors.textSecondary`, `AppColors.textTertiary`, `AppColors.surfaceVariant`, `AppColors.borderLight` all hardcoded |
| Admin "Panel principal" | `admin_dashboard_screen.dart` + shared widgets | Via metric_card (6), weekly_activity_chart (11), recent_requests_list (6), control_alerts_panel (5) | All shared admin widgets use hardcoded AppColors |
| Admin "Gestionar empleados" | `employees_list_screen.dart` + `employee_table_row.dart` (11), `employee_list_item.dart` (7), `employee_table_header.dart` (7) | Via table/row/list widgets | Employee table/row/header all hardcoded |
| Admin "Gestión de horarios" | `schedule_management_screen.dart` + `schedule_card.dart` (7), `schedule_template_modal.dart` (2) | Via schedule_card | schedule_card hardcodes AppColors |
| Admin "Gestionar calendarios" | `calendar_management_screen.dart` + `calendar_card.dart` (9), `calendar_editor_screen.dart` (39) | calendar_card and calendar_editor are the worst offenders | |

---

## Affected Areas (ranked by impact)

### TIER 1: Shared Widgets (affect ALL screens that compose them)

| File | Violations | Used by |
|------|-----------|---------|
| `lib/shared/widgets/inputs/time_picker_field.dart` | 14 | Every time input |
| `lib/shared/widgets/buttons/custom_button.dart` | 10 | Every button |
| `lib/shared/widgets/cards/schedule_card.dart` | 7 | Schedule management |
| `lib/shared/widgets/cards/metric_card.dart` | 6 | Admin dashboard |
| `lib/shared/widgets/inputs/custom_password_field.dart` | 5 | Login/profile |
| `lib/shared/widgets/empty_state.dart` | 5 | Many empty states |
| `lib/shared/widgets/editors/week_schedule_editor.dart` | 5 | Schedule editing |
| `lib/shared/widgets/cards/info_card.dart` | 4 | Various cards |
| `lib/shared/widgets/loading_spinner.dart` | 3 | Global loading |
| `lib/shared/widgets/inputs/custom_text_field.dart` | 3 | Every text input |
| `lib/shared/widgets/error_state.dart` | 3 | Global error |
| `lib/shared/widgets/cards/stat_card.dart` | 1 | Stats |
| `lib/shared/widgets/layouts/custom_app_bar.dart` | 1 | Search bar fill |
| **Subtotal** | **67** | |

### TIER 2: Feature Widgets (affect specific screens)

| File | Violations |
|------|-----------|
| `calendar_editor_screen.dart` | 39 |
| `month_navigation_header.dart` | 13 |
| `employee_table_row.dart` | 11 |
| `employee_detail_screen.dart` | 11 |
| `weekly_activity_chart.dart` | 11 |
| `day_editor_dialog.dart` | 9 |
| `calendar_card.dart` | 9 |
| `employee_schedule_editor_modal.dart` | 8 |
| `blocked_record_modal.dart` | 8 |
| `add_edit_record_modal.dart` | 8 |
| `employee_list_item.dart` | 7 |
| `employee_table_header.dart` | 7 |
| `recent_requests_list.dart` | 6 |
| `control_alerts_panel.dart` | 5 |
| `future_month_empty_state.dart` | 5 |
| `supervisor_assignment_field.dart` | 4 |
| `category_tab_selector.dart` | 4 |
| `employee_info_editor_modal.dart` | 3 |
| `schedule_template_modal.dart` | 2 |
| `day_record_card.dart` | 2 |
| **Subtotal** | **167** |

### TIER 3: Screen-Level Files

| File | Violations |
|------|-----------|
| `login_screen.dart` | 5 |
| `anomalies_screen.dart` | 4 |
| `overtime_review_screen.dart` | 2 |
| `splash_screen.dart` | 2 |
| `login_footer.dart` | 2 |
| `reports_screen.dart` | 1 |
| `app_router.dart` | 1 |
| `app_text_styles.dart` (extensions) | 2 |
| **Subtotal** | **19** |

### TIER 4: Navigation (already partially fixed but still has violations)

| File | Violations |
|------|-----------|
| `desktop_sidebar.dart` | 4 |
| **Subtotal** | **4** |

---

## Approaches

### 1. Continue Whack-a-Mole (PR#13+) — ❌ NOT RECOMMENDED

Continue fixing individual files one PR at a time.

- **Pros**: Familiar workflow, each PR is small
- **Cons**: Will require 10+ more PRs; new code will re-introduce bugs; 262 violations means 262 chances to miss one; root structural problem persists
- **Effort**: High (never-ending)

### 2. Structural Fix: Enforce `context.colors` + Lint Guard — ✅ RECOMMENDED

Fix the root: make `context.colors` the only approved way to access theme-aware colors, and add an `analysis_options.yaml` rule that forbids direct `AppColors.surface/background/text*/border` usage in `lib/features/` and `lib/shared/`.

**Step A — Make `context.colors` complete and concise**:
- Verify `AppColorsHelper` covers ALL surface/text/border tokens (it does)
- Add missing tokens: `borderLight`, `surfaceElevated`, `surfaceHover`, `navItemSelectedIcon`
- Add semantic shortcuts: `context.colors.onSurface`, `context.colors.outline` (aliases to `colorScheme.onSurface`, `colorScheme.outline`)

**Step B — Fix `AppTextStyles` extensions**:
- Replace `AppColors.textSecondary` → accept `BuildContext` parameter or remove color from extension (let theme supply it)
- Options: (a) convert to `context.textStyles.secondary` extension, or (b) remove `.secondary`/`.tertiary` extensions entirely and use `Theme.of(context).textTheme.bodySmall` directly

**Step C — Bulk-migrate all 262 violations**:
- Replace `AppColors.surface` → `context.colors.surface` or `Theme.of(context).colorScheme.surface`
- Replace `AppColors.textPrimary` → `Theme.of(context).colorScheme.onSurface`
- Replace `AppColors.textSecondary` → `Theme.of(context).colorScheme.onSurfaceVariant`
- Replace `AppColors.textTertiary` → `Theme.of(context).colorScheme.outline`
- Replace `AppColors.border` → `Theme.of(context).colorScheme.outline`
- Replace `AppColors.surfaceVariant` → `Theme.of(context).colorScheme.surfaceContainerHighest`
- Replace `AppColors.background` → `Theme.of(context).scaffoldBackgroundColor`
- Use automated find-replace per token (mechanical, low-risk)

**Step D — Add lint guard**:
- Add custom `dart_code_metrics` or `custom_lint` rule that flags `AppColors.(background|surface|textPrimary|textSecondary|textTertiary|border|borderLight|surfaceVariant)` in `lib/features/` and `lib/shared/`
- Alternatively: add a simple CI `grep` check that fails if these patterns appear in feature/shared code

- **Pros**: Fixes root cause once and for all; prevents recurrence; lint catches future violations immediately
- **Cons**: Large initial migration (~262 replacements across 41 files); requires careful testing
- **Effort**: Medium (bulk migration is mechanical, ~1 focused session per tier)

### 3. Hybrid: Tier-Based Migration + Lint — ✅ ALSO RECOMMENDED (pragmatic variant of #2)

Same as Approach 2 but executed in 3 focused slices by tier:

- **Slice A**: Fix Tier 1 (shared widgets, 67 violations, ~14 files) → This alone fixes ALL screens that compose these widgets
- **Slice B**: Fix Tier 2 (feature widgets, 167 violations, ~20 files) → Fixes all remaining screen-specific widgets
- **Slice C**: Fix Tier 3+4 + add lint guard (23 violations + lint rule, ~8 files) → Closes the gap and prevents recurrence

Each slice is mechanical find-replace with a test guard.

- **Pros**: Each slice has clear start/finish; Tier 1 alone gives massive ROI (all screens benefit); incremental testing
- **Cons**: Still 3 slices but each is self-contained and predictable
- **Effort**: Medium

---

## Recommendation

**Approach 3 (Tier-Based Migration + Lint)**. Here's why:

1. **Tier 1 alone (67 violations in shared widgets) will fix the majority of user-visible regressions**. Every admin screen uses metric_card, custom_button, etc. Fix those once and all screens improve.

2. **The lint guard in Slice C prevents the problem from ever recurring**. No more whack-a-mole.

3. **The migration is mechanical** — each `AppColors.X` → `Theme.of(context).colorScheme.Y` replacement is a 1:1 mapping with no logic change. Risk is low, testability is high.

4. **`AppTextStyles` extensions must also be fixed** — they are a hidden source of dark-mode breakage because developers write `style: AppTextStyles.bodyMedium.secondary` thinking it's theme-aware, but `.secondary` hardcodes `AppColors.textSecondary`.

### Token Mapping Reference

| Hardcoded (breaks dark) | Theme-aware replacement |
|--------------------------|------------------------|
| `AppColors.background` | `Theme.of(context).scaffoldBackgroundColor` |
| `AppColors.surface` | `Theme.of(context).colorScheme.surface` |
| `AppColors.surfaceVariant` | `Theme.of(context).colorScheme.surfaceContainerHighest` |
| `AppColors.textPrimary` | `Theme.of(context).colorScheme.onSurface` |
| `AppColors.textSecondary` | `Theme.of(context).colorScheme.onSurfaceVariant` |
| `AppColors.textTertiary` | `Theme.of(context).colorScheme.outline` |
| `AppColors.border` | `Theme.of(context).colorScheme.outline` |
| `AppColors.borderLight` | `Theme.of(context).colorScheme.outlineVariant` |
| `AppColors.surfaceDark` | `Theme.of(context).colorScheme.shadow` (rare usage) |

### AppTextStyles Extension Fix

Replace:
```dart
TextStyle get secondary => copyWith(color: AppColors.textSecondary);
TextStyle get tertiary => copyWith(color: AppColors.textTertiary);
```

With BuildContext-dependent extensions:
```dart
// On BuildContext:
TextStyle get bodySecondary => Theme.of(this).textTheme.bodyMedium!;
// Or: remove .secondary/.tertiary entirely, use Theme.of(context).textTheme directly
```

---

## Risks

1. **Migration scope**: 262 replacements across 41 files — a large diff. Must be split into reviewable slices (per tier, each <400 lines).
2. **Missing AppColorsHelper tokens**: Some `AppColorsDark`-only tokens (sidebarBackground, navItemSelectedIcon, clockingCompleteBackground, etc.) are not in `AppColorsHelper` and may not have ColorScheme equivalents. These need to be added to the ColorScheme extension or AppColorsHelper.
3. **AppTextStyles.secondary/tertiary callers**: Any code using `.secondary` or `.tertiary` extensions will need a BuildContext. This affects call sites across features.
4. **Calendar editor**: 39 violations in one file — the largest single file migration. Needs careful review.
5. **Test coverage**: Existing widget tests may not render in dark mode. Need golden/screenshot tests or at minimum `pumpWidget` with dark theme.

---

## Ready for Proposal

**Yes.** The root cause is clear, the solution is structural, and the migration plan is mechanical and testable. The orchestrator should tell the user:

> "Encontramos la raíz del problema: 262 referencias hardcodeadas a AppColors en 41 archivos que nunca se adaptan al tema oscuro. Los PR anteriores arreglaron algunos archivos pero no la estructura. La solución es: (1) migrar todos los shared widgets primero (67 violaciones, impacta TODAS las pantallas), (2) migrar los widgets de features (167 violaciones), (3) agregar un lint que prohíba AppColors directo en features/shared. Esto es mecánico y testable — no hay más vueltas."
