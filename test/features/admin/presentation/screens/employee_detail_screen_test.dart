import 'dart:async';
import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/features/admin/presentation/screens/employee_detail_screen.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/features/dashboard/providers/employee_schedule_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// =============================================================================
// FAKE DATA
// =============================================================================

const _testEmployeeId = 'EMP-DET-001';

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

final _fakeEmployee = UserModel(
  userId: _testEmployeeId,
  employeeId: _testEmployeeId,
  email: 'emp@test.com',
  displayName: 'Test Employee',
  role: UserRole.employee,
  weeklyHours: 40,
  createdAt: DateTime(2026, 1, 1),
  department: 'Tecnología',
  position: 'Developer',
);

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

/// Builds the EmployeeDetailScreen with overridden providers.
///
/// When [streamError] is non-null the [userByIdProvider] returns an error
/// stream, simulating a Firebase fetch failure (error-state branch).
/// When [employee] is null and [streamError] is null the provider returns
/// null, simulating a not-found employee.
Widget _wrapEmployeeDetailScreen({
  required String employeeId,
  UserModel? employee,
  Object? streamError,
}) {
  final router = GoRouter(
    initialLocation: AppRouter.adminEmployeeDetail.replaceFirst(
      ':id',
      employeeId,
    ),
    routes: [
      GoRoute(
        path: AppRouter.adminEmployees,
        builder: (context, state) => const Placeholder(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return EmployeeDetailScreen(employeeId: id);
            },
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      // Admin user for AdminLayout header
      currentUserProvider.overrideWith(
        (ref) => Stream.value(_fakeAdminUser),
      ),
      // Employee data
      userByIdProvider(employeeId).overrideWith(
        (ref) => streamError != null
            ? Stream<UserModel?>.error(streamError)
            : Stream.value(employee),
      ),
      // Schedule viewer — no schedule assigned
      employeeFullScheduleProvider(employeeId).overrideWith(
        (ref) => Future<EmployeeScheduleData?>.value(null),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  group('Back navigation affordance', () {
    testWidgets('back button is present when employee exists', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeeDetailScreen(
          employeeId: _testEmployeeId,
          employee: _fakeEmployee,
        ),
      );
      await tester.pumpAndSettle();

      // Back arrow icon is visible
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      // Back label text is visible
      expect(find.text('Volver a empleados'), findsOneWidget);
    });

    testWidgets('back button is present when employee not found', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeeDetailScreen(
          employeeId: 'non-existent',
          employee: null, // userById returns null → not found
        ),
      );
      await tester.pumpAndSettle();

      // Back button still visible in not-found state
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Volver a empleados'), findsOneWidget);
    });

    testWidgets('back button is present in error state', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeeDetailScreen(
          employeeId: _testEmployeeId,
          streamError: Exception('Simulated Firebase error'),
        ),
      );
      await tester.pumpAndSettle();

      // Error screen renders with back button
      expect(find.text('Error al cargar empleado'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Volver a empleados'), findsOneWidget);
    });

    testWidgets('tapping back button pops to employees list', (
      tester,
    ) async {
      _setDesktopViewport(tester);

      final router = GoRouter(
        initialLocation: AppRouter.adminEmployees,
        routes: [
          GoRoute(
            path: AppRouter.adminEmployees,
            builder: (context, state) => const Placeholder(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return EmployeeDetailScreen(employeeId: id);
                },
              ),
            ],
          ),
        ],
      );

      // Navigate to the detail screen (pushed onto parent route)
      router.go(
        AppRouter.adminEmployeeDetail.replaceFirst(':id', _testEmployeeId),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(_fakeAdminUser),
            ),
            userByIdProvider(_testEmployeeId).overrideWith(
              (ref) => Stream.value(_fakeEmployee),
            ),
            employeeFullScheduleProvider(_testEmployeeId).overrideWith(
              (ref) => Future<EmployeeScheduleData?>.value(null),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // We are on the detail screen
      expect(find.text('Test Employee'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap the back affordance
      await tester.tap(find.text('Volver a empleados'));
      await tester.pumpAndSettle();

      // Router location is back to the employees list
      final location =
          router.routerDelegate.currentConfiguration.uri.toString();
      expect(location, AppRouter.adminEmployees);
    });

    testWidgets('back uses go() when cannot pop (deep-link scenario)', (
      tester,
    ) async {
      _setDesktopViewport(tester);

      // Flat routes — no parent-child nesting, so canPop() returns false
      // when starting directly on the detail screen.
      final router = GoRouter(
        initialLocation:
            AppRouter.adminEmployeeDetail.replaceFirst(':id', _testEmployeeId),
        routes: [
          GoRoute(
            path: AppRouter.adminEmployees,
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: AppRouter.adminEmployeeDetail,
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return EmployeeDetailScreen(employeeId: id);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(_fakeAdminUser),
            ),
            userByIdProvider(_testEmployeeId).overrideWith(
              (ref) => Stream.value(_fakeEmployee),
            ),
            employeeFullScheduleProvider(_testEmployeeId).overrideWith(
              (ref) => Future<EmployeeScheduleData?>.value(null),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // We are on the detail screen
      expect(find.text('Test Employee'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Tap the back affordance
      await tester.tap(find.text('Volver a empleados'));
      await tester.pumpAndSettle();

      // Since canPop() was false, the button called context.go()
      // and the router location is now the employees list.
      final location =
          router.routerDelegate.currentConfiguration.uri.toString();
      expect(location, AppRouter.adminEmployees);
    });

    testWidgets('not-found message is shown for non-existent employee', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeeDetailScreen(
          employeeId: 'non-existent',
          employee: null,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Empleado no encontrado'), findsOneWidget);
    });
  });

  group('Employee detail content renders', () {
    testWidgets('employee name is visible', (tester) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeeDetailScreen(
          employeeId: _testEmployeeId,
          employee: _fakeEmployee,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Employee'), findsOneWidget);
    });

    testWidgets('hero card contains employee initials avatar', (
      tester,
    ) async {
      _setDesktopViewport(tester);
      await tester.pumpWidget(
        _wrapEmployeeDetailScreen(
          employeeId: _testEmployeeId,
          employee: _fakeEmployee,
        ),
      );
      await tester.pumpAndSettle();

      // "TE" = initials from "Test Employee"
      expect(find.text('TE'), findsOneWidget);
    });
  });
}
