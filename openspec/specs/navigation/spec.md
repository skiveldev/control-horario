# Delta Specs: Panel Navigation & Feature Cleanup

## ADDED Requirements

### Requirement: Account Settings Split — Route Separation

The system SHALL maintain two distinct navigation destinations: `/settings` for personal account preferences (Mi cuenta) and `/admin/settings` for system configuration visible only to admin role.

- GIVEN an authenticated employee user with `canSuperviseTeam: false`
- WHEN the employee navigates
- THEN `NavigationItems.items` SHALL NOT include a "Configuración" item
- AND the employee sidebar/drawer SHALL display only role-appropriate items

- GIVEN an authenticated admin user with `canSuperviseTeam: true`
- WHEN the admin sidebar builds its navigation
- THEN `NavigationItems.items` SHALL include both "Mi cuenta" (personal) and "Configuración del sistema" (admin system) as separate nav items
- AND "Configuración del sistema" nav item SHALL route to `/admin/settings`

- GIVEN any authenticated user
- WHEN the user taps the header gear icon
- THEN the navigation SHALL route to `/settings` (personal account preferences)

---

### Requirement: Session-Aware Splash Navigation

The splash screen SHALL check for an existing authenticated session before navigating and SHALL NOT introduce a fixed artificial delay when a valid session exists.

- GIVEN a user who already has an active Firebase Auth session
- WHEN the splash screen initializes
- THEN the system SHALL resolve the auth state within a minimal loading period (loading indicator visible)
- AND SHALL navigate directly to the appropriate dashboard without displaying the login screen
- AND SHALL NOT wait a fixed 2-second delay

- GIVEN a user with no active session
- WHEN the splash screen resolves
- THEN the system SHALL navigate to `/login`

- GIVEN a user whose auth state is still loading (Firebase async pending)
- WHEN the splash screen initializes
- THEN a loading indicator SHALL be displayed
- AND navigation SHALL be deferred until the auth state is confirmed

---

### Requirement: Notification UI Triage — Disabled State

The system SHALL NOT display notification UI elements (bells, badges, switches) that have no corresponding service implementation. Such elements SHALL be disabled or hidden until a backend is implemented.

- GIVEN the admin layout header notification bell
- WHEN no notification service/backend exists
- THEN the notification bell SHALL either be removed entirely OR replaced with a clearly disabled icon (greyed out, no badge, tap shows "Coming soon" snackbar/tooltip)

- GIVEN the settings screen notification toggles
- WHEN no notification service/backend exists
- THEN the notification switches (email notifications, push notifications, clocking reminders) SHALL be removed from the UI or visually disabled with a "Not implemented" label
- AND the user SHALL NOT be able to toggle them

---

### Requirement: Navigation-Routing-Cleanup — CalendarEditorScreen Registration

The `CalendarEditorScreen` SHALL be formally registered in GoRouter OR intentionally maintained as a modal via `Navigator.push`, with no undocumented routing behavior.

- GIVEN an admin user on the Calendar Management screen
- WHEN the user taps to edit a calendar
- THEN the navigation decision SHALL be explicit: EITHER `context.go('/admin/calendars/:id/edit')` via GoRouter with a registered route, OR `Navigator.push` with a clear TODO comment documenting it as an intentional modal

- GIVEN any code calling `CalendarEditorScreen`
- WHEN the screen is navigated to
- THEN there SHALL be no ambiguity about whether it is a route or a modal

---

### Requirement: Dashboard Mock Data Triage — Honest States

The system SHALL NOT display mock data in visible production-facing surfaces. All dashboard metrics and widgets SHALL display real data, loading states, or honest empty/placeholder states.

- GIVEN the admin dashboard metric cards (Fichados Hoy, Ausencias, Solicitudes)
- WHEN the real data is not yet available (not yet wired to Firestore)
- THEN the card SHALL display a loading shimmer/spinner OR an empty state with explicit "Coming soon" label
- AND SHALL NOT display hardcoded mock values like `stats['clockedInToday']`

- GIVEN the admin dashboard bottom row (RecentRequestsList, ControlAlertsPanel)
- WHEN real data is not available
- THEN the widgets SHALL display honest empty states or be hidden
- AND SHALL NOT render `MockData.recentRequests` or `MockData.controlAlerts`

- GIVEN the employee dashboard (MonthlyCalendarCard, WeeklySummaryCard, QuickActionsCard)
- WHEN real data is not available
- THEN the widgets SHALL display loading states OR honest placeholder content
- AND SHALL NOT present mock data as real

---

### Requirement: Employee Quick Actions — Honest Routing or Removal

The employee dashboard QuickActionsCard actions SHALL either route to real implemented flows, display honest disabled states, or be removed entirely.

- GIVEN the QuickActionsCard on the employee dashboard
- WHEN an action is not yet implemented (request vacation, view reports, edit record)
- THEN the UI SHALL visually indicate the action is unavailable (disabled button with tooltip "Coming soon" or similar)
- OR the action SHALL be removed from the card entirely until implemented
- AND the user SHALL NOT encounter a dead-end or crash when tapping

---

### Requirement: Dark Mode Consistency — Theme Token Compliance

The system SHALL ensure all visual surfaces respond correctly to dark mode. Hardcoded color references that bypass `Theme.of(context)` SHALL be replaced with theme-aware tokens where they cause visual inconsistencies.

- GIVEN the `MobileDrawer` header (drawer header background gradient, avatar initials)
- WHEN dark mode is active
- THEN colors SHALL derive from `Theme.of(context).colorScheme` or explicitly dark-mode-aware tokens
- AND the user SHALL see consistent dark-mode visuals (no white/light backgrounds leaking through)

- GIVEN the admin layout header (search field background, notification bell area)
- WHEN dark mode is active
- THEN `AppColors.background` references that produce incorrect contrast SHALL be replaced with `Theme.of(context).colorScheme.surfaceContainerHighest` or equivalent theme token

- GIVEN the settings screen sections (section title icons, card backgrounds, divider colors)
- WHEN dark mode is active
- THEN hardcoded `AppColors.primary`, `AppColors.surface`, `AppColors.border` references that bypass theme SHALL be reviewed and replaced with `Theme.of(context).colorScheme.primary`, `.surface`, `.outline` respectively where they cause inconsistency

- GIVEN the desktop sidebar (nav item icons, selected item background)
- WHEN dark mode is active
- THEN hardcoded `AppColorsDark.textPrimary`, `AppColorsDark.navItemSelectedIcon` references that were added for dark mode SHALL be verified for visual consistency
- AND existing theme-aware tokens in the sidebar SHALL NOT be replaced with hardcoded dark-mode-only values

- GIVEN the app-wide `AppColors` static references
- WHEN a widget uses a hardcoded `AppColors.X` reference for a surface, text, or background color
- THEN the widget SHOULD use `Theme.of(context).colorScheme` or the appropriate `ColorScheme` token instead
- AND if a hardcoded token is intentional for a specific branded element (e.g., gradients, primary brand color), it SHALL be documented in the component

---

### Requirement: Mobile Drawer — Real User Data

The mobile drawer SHALL display the authenticated user's actual name and initials from `currentUserProvider`, not hardcoded placeholder values.

- GIVEN an authenticated user with `fullName: "Juan Pérez López"`
- WHEN the mobile drawer renders
- THEN the drawer header SHALL display "Juan Pérez López" from `currentUserProvider`
- AND the avatar SHALL display initials "JP" derived from the user's name
- AND there SHALL be no hardcoded name like "María García López"

- GIVEN an unauthenticated or null user state
- WHEN the mobile drawer renders
- THEN the drawer SHALL handle the null case gracefully (show "Usuario" as placeholder, no crash)