# Design: Panel Navigation & Feature Cleanup

## Technical Approach

Six chained PR slices, each under 400 lines. P1 establishes the navigation split that P2-P3 depend on; P4-P6 are independent. Existing theme bridge (`AppColorsHelper`) is kept; high-traffic hardcoded `AppColors.` references are migrated to `Theme.of(context).colorScheme` tokens in P2b (dark mode). Mock data is replaced with honest empty/loading states rather than wholesale removal.

## Architecture Decisions

| Decision | Option A | Option B | Choice | Rationale |
|----------|----------|----------|--------|-----------|
| `/admin/settings` route | GoRoute sub-route under `/admin` | Standalone `/admin-settings` route | **GoRoute sub-route** | Matches existing admin route hierarchy; GoRouter redirect guard already protects `/admin*` for admin-only access |
| `CalendarEditorScreen` routing | Register as GoRoute `/admin/calendars/:id/edit` | Keep as `Navigator.push` modal with documented TODO | **GoRoute registration** | Formal route enables deep-linking, back-button consistency, and eliminates undocumented behavior. The 1093-line screen is a full-screen experience, not a transient modal. |
| Navigation role split | Duplicate `NavigationItems` for admin/employee | Single `NavigationItems.items(canSuperviseTeam:)` with role logic | **Single method with role logic** | Already has `canSuperviseTeam` parameter; extends naturally. Admin sidebar gets separate "Mi cuenta" + "Configuración del sistema" items in `AdminSidebar`. |
| Dark mode color strategy | Full `ColorScheme` migration everywhere | AppColorsHelper bridge + targeted fixes for high-traffic surfaces | **Targeted fixes per P2b** | `AppColorsHelper` already bridges light/dark. Full migration exceeds 400-line budget. Fix sidebar, drawer, cards, settings, app bars first. Leave low-traffic admin screens for future. |
| Notification triage | Remove all notification UI | Disable visually with "Coming soon" tooltip | **Disable visually** | Removal risks layout gaps. Disabled bell (grey, no badge, tooltip) + switch removal in settings is ~120 lines and honest. |
| Mock data in dashboards | Delete all mock widgets | Replace with loading/empty states, hide mock-dependent widgets | **Loading/empty states** | Preserves widget structure for future Firestore wiring. `RecentRequestsList`, `ControlAlertsPanel` display empty states; mock metric cards show "—" or shimmer. |

## Data Flow

```
currentUserProvider (Riverpod Stream<UserModel?>)
  ├─→ EmployeeHeader (real name, dept)     [already wired]
  ├─→ MobileDrawer header (avatar, name)    [P2a: wire real data]
  └─→ AdminLayout header (avatar, name)     [P2a: wire real data]

themeNotifierProvider (Riverpod ThemeMode)
  ├─→ MaterialApp.router themeMode          [already wired]
  └─→ SettingsScreen dark mode toggle       [already wired]

authStateProvider (Riverpod Stream<User?>)
  └─→ SplashScreen session check            [P5: replace 2s delay]

NavigationItems.items(canSuperviseTeam:)
  ├─→ DesktopSidebar nav items              [P1: remove Configuración for employee]
  └─→ MobileDrawer nav items                [P1: remove Configuración for employee]

AdminSidebar (hardcoded items)
  └─→ "Mi cuenta" + "Configuración del sistema" [P1: split items]
```

## File Changes

| File | Action | Slice | Description |
|------|--------|-------|-------------|
| `navigation_items.dart` | Modify | P1 | Remove "Configuración" from employee list; keep conditional on `canSuperviseTeam` |
| `admin_sidebar.dart` | Modify | P1 | Split "Configuración" into "Mi cuenta" → `/settings` + "Configuración del sistema" → `/admin/settings` |
| `app_router.dart` | Modify | P1 | Add `/admin/settings` route constant + GoRoute registration with placeholder screen |
| `mobile_drawer.dart` | Modify | P2a/P2b | P2a: Use `currentUserProvider` for name/initials (~30 lines). P2b: Replace hardcoded `AppColors.` with `Theme.of(context).colorScheme` |
| `desktop_sidebar.dart` | Modify | P2b | Replace hardcoded `AppColorsDark.` text/icon refs with theme tokens where inconsistent |
| `settings_screen.dart` | Modify | P1/P3 | P1: Change title to "Mi cuenta". P3: Remove notification switches section, disable bell refs |
| `admin_layout.dart` | Modify | P2a/P3/P2b | P2a: Wire real admin name from `currentUserProvider`. P3: Disable notification bell (grey, no badge, tooltip). P2b: Fix hardcoded colors |
| `responsive_navigation.dart` | Modify | P2b | Fix gear icon color to use `Theme.of(context).colorScheme` |
| `admin_dashboard_screen.dart` | Modify | P6 | Replace `MockData.adminStats` metric cards with loading/empty states |
| `recent_requests_list.dart` | Modify | P6 | Display empty state instead of `MockData.recentRequests` |
| `control_alerts_panel.dart` | Modify | P6 | Display empty/placeholder state instead of `MockData.controlAlerts` |
| `quick_actions_card.dart` | Modify | P6 | Disable unimplemented actions with "Próximamente" badges; keep Edit Record as mock dialog |
| `weekly_activity_chart.dart` | Modify | P6 | Show placeholder "Sin datos" when no real data |
| `splash_screen.dart` | Modify | P5 | Replace `Future.delayed(2s)` with `authStateProvider.future` check; navigate based on session |
| `calendar_management_screen.dart` | Modify | P4 | Replace `Navigator.push` with `context.go(AppRouter.adminCalendarEditor, extra: calendar)` |
| `app_router.dart` | Modify | P4 | Add `/admin/calendars/:id/edit` GoRoute with `CalendarEditorScreen` |
| `app_colors.dart` | Modify | P2b | Document which tokens are theme-safe vs intentional branded constants |
| `app_theme.dart` | Modify | P2b | Ensure `ColorScheme.dark()` surface/onSurface tokens match expected widget consumption |

## Interfaces / Contracts

No new API contracts. Existing Riverpod providers reused:

- `currentUserProvider` (Stream<UserModel?>) — used by P2a for drawer/header real user data
- `themeNotifierProvider` (ThemeMode) — used by P3 dark mode toggle; already wired
- `authStateProvider` (Stream<User?>) — used by P5 splash session check
- `employeesCountProvider` — already wired in admin dashboard; P6 preserves it

New route contract: `/admin/settings` → placeholder `AdminSettingsScreen` (P1). `/admin/calendars/:id/edit` → `CalendarEditorScreen` with `extra: WorkCalendarModel?` (P4).

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Widget | `NavigationItems.items()` role-based list | Unit: assert employee items exclude "Configuración", admin items include it |
| Widget | `MobileDrawer` real name rendering | Widget test with `ProviderScope` override for `currentUserProvider` |
| Widget | `SettingsScreen` notification section hidden | Widget test verifying no SwitchListTile for notifications |
| Router | `/admin/settings` redirect guard | Test `GoRouter.redirect` denies non-admin, allows admin |
| Router | Splash session-aware navigation | Test `SplashScreen` navigates to dashboard when `authStateProvider` emits non-null |
| Provider | `themeNotifierProvider` toggle persists | Unit: verify `SharedPreferences.setBool` called on toggle |

## Migration / Rollout

Each PR is self-contained and revertible. P1 (navigation) is the only slice with downstream dependencies — reverting P1 reverts P2-P3 naturally via Git. P4-P6 are fully independent. No data migration required. No feature flags needed — changes are direct UI/routing fixes.

## PR Slicing

| PR | Focus | Est. Lines | Depends On | Risk |
|----|-------|-----------|------------|------|
| PR#1 | Navigation split (P1) | ~200 | — | Medium |
| PR#2 | Drawer real user (P2a) | ~80 | PR#1 | Low |
| PR#3 | Dark mode fix (P2b) | ~300 | PR#2 | Medium |
| PR#4 | Notification triage (P3) | ~120 | PR#2 | Low |
| PR#5 | CalendarEditor route (P4) | ~100 | — | Low |
| PR#6 | Splash session-aware (P5) | ~100 | — | Low |
| PR#7 | Dashboard mock cleanup (P6) | ~250 | — | Low |

Chain: PR#1 → PR#2 → PR#3 (force-chained). PR#4 targets PR#2. PR#5, PR#6, PR#7 are independent and can run in parallel after PR#1.

## Open Questions

- [ ] Should `/admin/settings` route to existing `SettingsScreen` with admin-only sections or a new `AdminSettingsScreen` placeholder? (Recommend: placeholder with "Coming soon" for P1)
- [ ] Should `WeeklyActivityChart` be completely hidden or show a placeholder "No data" message? (Recommend: placeholder)
- [ ] Is the `CalendarEditorScreen` ready for GoRoute (expects `existingCalendar` as constructor param) — yes, pass via `extra`.
