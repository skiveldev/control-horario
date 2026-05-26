import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Helper: build an employee UserModel stub.
UserModel _employeeUser() => UserModel(
      userId: 'emp-1',
      employeeId: 'EMP-001',
      email: 'emp@example.com',
      displayName: 'Test Employee',
      role: UserRole.employee,
      weeklyHours: 40,
      createdAt: DateTime(2026, 1, 1),
    );

/// Helper: build an admin UserModel stub.
UserModel _adminUser() => UserModel(
      userId: 'admin-1',
      employeeId: 'ADM-001',
      email: 'admin@example.com',
      displayName: 'Test Admin',
      role: UserRole.admin,
      weeklyHours: 40,
      createdAt: DateTime(2026, 1, 1),
    );

/// Build a minimal GoRouter with splash and target routes identified
/// by unique text labels so we can verify the final location.
GoRouter _testRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const Text('LOGIN_PAGE'),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const Text('DASHBOARD_PAGE'),
        ),
        GoRoute(
          path: '/admin',
          builder: (_, __) => const Text('ADMIN_PAGE'),
        ),
      ],
    );

void main() {
  group('SplashScreen session-aware navigation', () {
    // ── RED: These tests describe the NEW behavior and MUST fail against
    //    the current splash screen (fixed 2 s delay → always login).

    testWidgets('navigates to login when no authenticated session', (
      tester,
    ) async {
      final router = _testRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream<UserModel?>.value(null),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Advance past the old 2-second delay (current code).
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await tester.pump();

      // THEN: we land on login
      expect(find.text('LOGIN_PAGE'), findsOneWidget);
      expect(find.text('DASHBOARD_PAGE'), findsNothing);
    });

    testWidgets('navigates to dashboard when authenticated employee', (
      tester,
    ) async {
      final router = _testRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(_employeeUser()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // Only pump a few frames — we must NOT wait 2 s.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // THEN: we land on dashboard (RED: old code always goes to login)
      expect(find.text('DASHBOARD_PAGE'), findsOneWidget);
      expect(find.text('LOGIN_PAGE'), findsNothing);
    });

    testWidgets('navigates to dashboard when authenticated supervisor', (
      tester,
    ) async {
      // Supervisor (canSuperviseTeam: true but role != admin) → dashboard
      final router = _testRouter();
      final supervisor = UserModel(
        userId: 'sup-1',
        employeeId: 'SUP-001',
        email: 'sup@example.com',
        displayName: 'Test Supervisor',
        role: UserRole.employee,
        isSupervisor: true,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(supervisor),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Supervisor is NOT admin → dashboard
      expect(find.text('DASHBOARD_PAGE'), findsOneWidget);
      expect(find.text('ADMIN_PAGE'), findsNothing);
    });

    testWidgets('navigates to admin when authenticated admin', (
      tester,
    ) async {
      final router = _testRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(_adminUser()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // THEN: we land on admin (RED: old code always goes to login)
      expect(find.text('ADMIN_PAGE'), findsOneWidget);
      expect(find.text('LOGIN_PAGE'), findsNothing);
    });
  });
}
