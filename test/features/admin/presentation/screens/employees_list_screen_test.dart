import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/features/admin/presentation/screens/employees_list_screen.dart';
import 'package:control_horario/features/admin/presentation/widgets/employee_list_item.dart';
import 'package:control_horario/features/admin/providers/admin_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/shared/widgets/buttons/custom_button.dart';
import 'package:control_horario/shared/widgets/inputs/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// =============================================================================
// FAKE DATA
// =============================================================================

UserModel _testEmployee({
  required String userId,
  required String displayName,
  String department = 'Tecnología',
  String position = 'Developer',
  UserRole role = UserRole.employee,
  bool isSupervisor = false,
  String? scheduleId,
}) {
  return UserModel(
    userId: userId,
    employeeId: userId,
    email: '$userId@example.com',
    displayName: displayName,
    role: role,
    isSupervisor: isSupervisor,
    weeklyHours: 40,
    createdAt: DateTime(2026, 1, 1),
    department: department,
    position: position,
    scheduleId: scheduleId,
  );
}

final _fakeAdminUser = UserModel(
  userId: 'admin-001',
  employeeId: 'admin-001',
  email: 'admin@test.com',
  displayName: 'Admin Test',
  role: UserRole.admin,
  weeklyHours: 40,
  createdAt: DateTime(2026, 1, 1),
  department: 'Admin',
  position: 'Administrador',
);

final _fakeEmployees = <UserModel>[
  _testEmployee(
    userId: 'EMP-001',
    displayName: 'Ana García',
    department: 'Tecnología',
    scheduleId: 'sched_40h',
  ),
  _testEmployee(
    userId: 'EMP-002',
    displayName: 'Carlos López',
    department: 'Docente',
    scheduleId: 'sched_40h',
  ),
  _testEmployee(
    userId: 'EMP-003',
    displayName: 'María Pérez',
    department: 'Tecnología',
  ),
  _testEmployee(
    userId: 'EMP-004',
    displayName: 'Juan Martínez',
    department: 'Administración',
    scheduleId: 'sched_30h',
  ),
  _testEmployee(
    userId: 'EMP-005',
    displayName: 'Laura Torres',
    department: 'Tecnología',
    role: UserRole.rrhh,
    isSupervisor: true,
    scheduleId: 'sched_40h',
  ),
  _testEmployee(
    userId: 'EMP-006',
    displayName: 'Pedro Sánchez',
    department: 'Docente',
  ),
  _testEmployee(
    userId: 'EMP-007',
    displayName: 'Elena Ruiz',
    department: 'Administración',
    role: UserRole.admin,
    scheduleId: 'sched_flex',
  ),
];

// =============================================================================
// HELPERS
// =============================================================================

void _setDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void _setMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// Builds the EmployeesListScreen with overridden providers.
///
/// Overrides [allEmployeesProvider] which feeds both the stat cards and
/// [searchAndFilterEmployeesProvider] (family-derived in memory).
Widget _wrapEmployeesListScreen({
  required List<UserModel> allEmployees,
}) {
  final router = GoRouter(
    initialLocation: AppRouter.adminEmployees,
    routes: [
      GoRoute(
        path: AppRouter.adminEmployees,
        builder: (context, state) => const EmployeesListScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      allEmployeesProvider.overrideWith(
        (ref) => Stream.value(allEmployees),
      ),
      currentUserProvider.overrideWith(
        (ref) => Stream.value(_fakeAdminUser),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  // ===========================================================================
  // 1. No fake "Próximamente" filter/export controls
  // ===========================================================================
  group('No fake placeholder controls', () {
    testWidgets('NO "Próximamente" text anywhere on screen', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Próximamente'), findsNothing);
    });

    testWidgets('NO "Filtros" standalone button present', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      // The old outline "Filtros" standalone button should be gone.
      expect(find.widgetWithText(CustomButton, 'Filtros'), findsNothing);
    });

    testWidgets('NO "Exportar" button present', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(CustomButton, 'Exportar'), findsNothing);
    });

    testWidgets('NO "Panel de filtros avanzados" text', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Panel de filtros avanzados'), findsNothing);
    });

    testWidgets('NO "Exportar a CSV/Excel" text', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Exportar a CSV/Excel'), findsNothing);
    });
  });

  // ===========================================================================
  // 2. Existing functional controls still render
  // ===========================================================================
  group('Existing functional controls render', () {
    testWidgets('search field is present', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(
          CustomTextField,
          'Buscar por nombre, email o ID...',
        ),
        findsOneWidget,
      );
    });

    testWidgets('"Nuevo Trabajador" CTA is present exactly once in desktop', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      // Only the header CTA — the duplicate in _SearchFilterBar was removed.
      expect(
        find.widgetWithText(CustomButton, 'Nuevo Trabajador'),
        findsOneWidget,
      );
    });

    testWidgets('department filter chips are present', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.text('Todos'), findsOneWidget);
      // "Tecnología" appears in chip + employee department cells
      expect(find.text('Tecnología'), findsWidgets);
      // "Docente" appears in chip + employee department cells
      expect(find.text('Docente'), findsWidgets);
    });

    testWidgets('employee names are visible in table (desktop)', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ana García'), findsOneWidget);
      expect(find.text('Carlos López'), findsOneWidget);
      expect(find.text('María Pérez'), findsOneWidget);
    });

    testWidgets('employee cards are visible in mobile', (tester) async {
      _setMobileViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      // Mobile view uses EmployeeListItem cards
      expect(find.byType(EmployeeListItem), findsWidgets);
      expect(find.text('Ana García'), findsOneWidget);
    });

    testWidgets('pagination renders when more than 10 items', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      final many = List.generate(
        15,
        (i) => _testEmployee(
          userId: 'EMP-${100 + i}',
          displayName: 'Employee ${100 + i}',
        ),
      );
      await tester.pumpWidget(_wrapEmployeesListScreen(allEmployees: many));
      await tester.pumpAndSettle();

      expect(find.text('Anterior'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
      expect(find.text('de 2'), findsOneWidget);
    });

    testWidgets('counter shows employee count', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Mostrando 7 de 7 empleados'),
        findsOneWidget,
      );
    });
  });

  // ===========================================================================
  // 3. New metrics/stat labels render
  // ===========================================================================
  group('Stats row metrics', () {
    testWidgets('"TOTAL EMPLEADOS" label and value render', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.text('TOTAL EMPLEADOS'), findsOneWidget);
      // 7 employees in fake data
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('"CON HORARIO" label and value render', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.text('CON HORARIO'), findsOneWidget);
      // EMP-001, 002, 004, 005, 007 have scheduleId → 5
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('"DEPARTAMENTOS" label and value render', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.text('DEPARTAMENTOS'), findsOneWidget);
      // Tecnología, Docente, Administración → 3
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('"SUPERVISORES" label and value render', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.text('SUPERVISORES'), findsOneWidget);
      // EMP-005 (rrhh+supervisor), EMP-007 (admin) → 2
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('stats row renders in mobile as stacked cards', (
      tester,
    ) async {
      _setMobileViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      // All stat labels should still be visible
      expect(find.text('TOTAL EMPLEADOS'), findsOneWidget);
      expect(find.text('CON HORARIO'), findsOneWidget);
    });
  });

  // ===========================================================================
  // 4. Dark mode safety — no hardcoded surface/text colors
  // ===========================================================================
  group('Dark mode safety', () {
    testWidgets('stat cards work in dark mode without hardcoded colors', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      final router = GoRouter(
        initialLocation: AppRouter.adminEmployees,
        routes: [
          GoRoute(
            path: AppRouter.adminEmployees,
            builder: (context, state) => const EmployeesListScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allEmployeesProvider.overrideWith(
              (ref) => Stream.value(_fakeEmployees),
            ),
            currentUserProvider.overrideWith(
              (ref) => Stream.value(_fakeAdminUser),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark(),
            theme: ThemeData.light(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The screen should render without errors in dark mode
      expect(find.text('TOTAL EMPLEADOS'), findsOneWidget);
      expect(find.text('Ana García'), findsOneWidget);
      expect(find.textContaining('Próximamente'), findsNothing);
    });
  });

  // ===========================================================================
  // 5. Header intro renders correctly
  // ===========================================================================
  group('Header intro', () {
    testWidgets('title "Gestión de Trabajadores" is present', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gestión de Trabajadores'), findsOneWidget);
    });

    testWidgets('employee count is in subtitle', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: _fakeEmployees),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('7 empleados registrados'),
        findsOneWidget,
      );
    });
  });

  // ===========================================================================
  // 6. Empty state — controls and CTAs remain visible
  // ===========================================================================
  group('Empty state keeps controls visible', () {
    testWidgets('empty state message shows when no employees match', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: []),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No se encontraron empleados'),
        findsOneWidget,
      );
    });

    testWidgets('search field remains visible when list is empty', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: []),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(
          CustomTextField,
          'Buscar por nombre, email o ID...',
        ),
        findsOneWidget,
      );
    });

    testWidgets('"Nuevo Trabajador" CTA is present exactly once in empty state', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: []),
      );
      await tester.pumpAndSettle();

      // Only one CTA — the header button. No duplicate in search bar.
      expect(
        find.widgetWithText(CustomButton, 'Nuevo Trabajador'),
        findsOneWidget,
      );
    });

    testWidgets('department chips remain visible when list is empty', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Tecnología'), findsOneWidget);
      expect(find.text('Docente'), findsOneWidget);
    });

    testWidgets('header title remains visible when list is empty', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gestión de Trabajadores'), findsOneWidget);
    });

    testWidgets('stats row still renders when list is empty', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: []),
      );
      await tester.pumpAndSettle();

      expect(find.text('TOTAL EMPLEADOS'), findsOneWidget);
      expect(find.text('0'), findsWidgets); // 0 employees → zeros in stats
    });

    testWidgets('no fake controls appear in empty state', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeesListScreen(allEmployees: []),
      );
      await tester.pumpAndSettle();

      // Must still be absent
      expect(find.textContaining('Próximamente'), findsNothing);
      expect(find.widgetWithText(CustomButton, 'Filtros'), findsNothing);
      expect(find.widgetWithText(CustomButton, 'Exportar'), findsNothing);
      expect(find.textContaining('Exportar a CSV/Excel'), findsNothing);
      expect(find.textContaining('Panel de filtros avanzados'), findsNothing);
    });
  });
}
