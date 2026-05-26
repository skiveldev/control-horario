# Proposal: Panel Navigation & Feature Cleanup

## Intent

The admin and employee panels expose incomplete features that confuse users and create technical debt: a shared `/settings` route mixing "My Account" with "System Config", notification UI with no backend, duplicate settings navigation (sidebar + header gear), hardcoded user data in the mobile drawer, mock-driven dashboards, unregistered routes, and a dark mode toggle that switches mechanically but produces inconsistent visuals across the app due to 1000+ hardcoded `AppColors.` references bypassing `Theme.of(context)`. This change phases the cleanup so each PR is reviewable under 400 lines.

## Scope

### In Scope

- **P1 — Navigation cleanup**: Remove "Configuración" from employee sidebar/drawer; rename `/settings` to "Mi cuenta" semantically; add "Configuración del sistema" nav item for admin only.
- **P2 — Mobile drawer real user + dark mode consistency**: Replace hardcoded `María García López` / `MG` with `currentUserProvider` data. Additionally, audit and fix dark mode visual consistency across admin and employee panels: replace hardcoded `AppColors.` references with `Theme.of(context)` tokens where they break dark mode, covering shared widgets (sidebar, drawer, app bar, cards), settings/profile screens, and admin screens. The current toggle switches `ThemeMode` mechanically but 1000+ hardcoded color refs produce inconsistent dark visuals. Visual consistency is part of acceptance — toggle working is not enough. If full audit exceeds 400 lines, dark mode becomes a separate chained slice (P2a: drawer user, P2b: dark mode fix).
- **P3 — Notification UI triage**: Hide or disable notification bell/badge and notification switches in settings until backend exists.
- **P4 — CalendarEditorScreen route**: Register in GoRouter as `/admin/calendars/:id/edit` or confirm intentional `Navigator.push` and clean TODOs.
- **P5 — Splash session-aware**: Replace fixed 2s delay with `authStateProvider` check; navigate directly to dashboard/admin if session active.
- **P6 — Dashboard mock removal**: Remove or clearly label mock-dependent widgets in admin dashboard metrics and employee quick actions; replace with loading/empty states.

### Out of Scope

- Implementing actual notification backend/service
- Implementing change-password functionality (beyond marking as TODO clearly)
- Implementing language switching
- Implementing "forgot password" flow beyond current SnackBar
- New features (vacation requests, reports, etc.)
- Employee dashboard `MonthlyCalendarCard` / `WeeklySummaryCard` full Firestore wiring

## Capabilities

### New Capabilities

- `account-settings-split`: Separation of "Mi cuenta" (personal) from "Configuración del sistema" (admin global), including route and navigation restructuring.
- `notification-ui-triage`: Policy for hiding/disabling notification UI elements that have no backend support.
- `dark-mode-consistency`: Audit and fix hardcoded color references to ensure visual consistency across light and dark themes; replace `AppColors.` static refs with `Theme.of(context)` tokens where they break dark mode.

### Modified Capabilities

- `navigation`: Employee sidebar/drawer items change (remove Configuración), admin gets new nav item.
- `splash-flow`: Splash screen checks active session instead of always-delay-then-login.

## Approach

Phased delivery as chained PRs. Each phase is a self-contained slice: P1 → P2 → P3 → P4 → P5 → P6. Each PR targets the previous branch, keeping diffs under 400 lines. P1 establishes the navigation structure others depend on; P2-P3 are independent after P1; P4-P6 are fully independent. If P2 (dark mode + drawer) exceeds 400 lines, it splits into P2a (drawer user) and P2b (dark mode fix), each as a separate chained PR.

| Phase | Focus | Est. Lines | Depends On |
|-------|-------|-----------|------------|
| P1 | Navigation split (Mi cuenta / Config del sistema) | ~200 | — |
| P2 | Mobile drawer real user + dark mode consistency | ~300-400 | P1 |
| P3 | Notification UI triage | ~120 | P1 |
| P4 | CalendarEditor routing | ~100 | — |
| P5 | Splash session-aware | ~100 | — |
| P6 | Dashboard mock cleanup | ~250 | — |

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `lib/shared/widgets/navigation/navigation_items.dart` | Modified | Split items by role; remove "Configuración" from employee list |
| `lib/shared/widgets/navigation/mobile_drawer.dart` | Modified | Use currentUserProvider for avatar/name; remove hardcoded user; fix hardcoded colors for dark mode |
| `lib/shared/widgets/navigation/desktop_sidebar.dart` | Modified | Same nav item changes as mobile; fix hardcoded colors for dark mode |
| `lib/features/dashboard/presentation/screens/settings_screen.dart` | Modified | Rename to "Mi cuenta"; remove notification switches; fix hardcoded colors for dark mode |
| `lib/core/router/app_router.dart` | Modified | Add `/admin/settings` route; optionally add calendar editor route |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Modified | Session-aware navigation |
| `lib/features/admin/presentation/screens/calendar_editor_screen.dart` | Modified | Route registration or TODO cleanup |
| `lib/features/dashboard/presentation/screens/dashboard_screen.dart` | Modified | Mock triage in quick actions |
| `lib/features/admin/presentation/screens/admin_dashboard_screen.dart` | Modified | Mock metric triage |
| `lib/shared/widgets/layouts/admin_layout.dart` | Modified | Notification bell triage; fix hardcoded colors for dark mode |
| `lib/shared/widgets/layouts/responsive_navigation.dart` | Modified | Header gear icon alignment; fix hardcoded colors for dark mode |
| `lib/core/theme/app_colors.dart` | Modified | Audit which tokens are light-only vs theme-aware |
| `lib/core/theme/app_colors_dark.dart` | Modified | Verify dark tokens cover all used surfaces/text |
| `lib/core/theme/app_theme.dart` | Modified | Ensure ColorScheme maps all tokens consumed by widgets |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Removing employee "Configuración" confuses users who expect it in sidebar | Low | Header gear icon already navigates to settings; add tooltip |
| Admin "Configuración del sistema" screen is empty placeholder | Med | Show "coming soon" state; don't create shell until P1 is stable |
| CalendarEditor as GoRoute sub-route breaks `Navigator.push` callers | Low | CalendarManagementScreen opens it; update call site to `context.go` |
| Splash session check introduces flash if auth state is slow | Med | Show loading indicator during auth check; minimal flicker |
| Dark mode audit scope exceeds 400 lines per PR | High | Split P2 into P2a (drawer user ~80 lines) + P2b (dark mode fix ~300 lines); prioritize high-traffic surfaces first (sidebar, cards, app bar) |

## Rollback Plan

Each phase is a separate PR. Revert the specific PR if issues arise. Navigation changes (P1) are the most impactful — revert rolls back all dependent phases. P4-P6 are independent and revert cleanly.

## Dependencies

- `currentUserProvider` already exists in `auth_provider.dart` with `displayName` and `canSuperviseTeam` on `UserModel`.
- GoRouter redirect logic in `app_router.dart` already handles auth state; splash just needs to use it.
- `AppTheme.lightTheme` and `AppTheme.darkTheme` exist in `app_theme.dart` with `ColorScheme` mappings — but widgets bypass them via hardcoded `AppColors.`. The dark mode fix depends on `ColorScheme` having all necessary tokens first.

## Success Criteria

- [ ] Employee sidebar/drawer has NO "Configuración" item; header gear still works.
- [ ] Admin sidebar has "Configuración del sistema" + "Mi cuenta" as separate items.
- [ ] Mobile drawer shows real user name/initials from `currentUserProvider`.
- [ ] Dark mode is visually consistent across admin and employee panels — no light-mode colors leaking on dark background in shared widgets, sidebar, drawer, cards, settings, or profile screens. Toggle working mechanically is not sufficient.
- [ ] Notification bell/badge hidden or disabled where no backend exists.
- [ ] CalendarEditorScreen has clear routing strategy (GoRoute or confirmed modal).
- [ ] Splash navigates directly to dashboard/admin on active session without 2s delay.
- [ ] Dashboard mock widgets replaced with loading/empty/placeholder states.
