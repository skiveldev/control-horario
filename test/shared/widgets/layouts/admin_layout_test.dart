import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/shared/widgets/layouts/admin_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AdminLayout header', () {
    testWidgets('shows real admin name and initials from provider',
        (tester) async {
      // Use a large enough viewport for desktop layout
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testUser = UserModel(
        userId: 'admin-1',
        employeeId: 'EMP-admin-1',
        email: 'admin@example.com',
        displayName: 'Carlos Admin',
        role: UserRole.admin,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'Carlos',
        apellido1: 'Admin',
      );

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminLayout(
              child: Text('Dashboard'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Verify real admin name is displayed in the header
      expect(find.text('Carlos Admin'), findsOneWidget);

      // Verify initials are displayed
      expect(find.text('CA'), findsOneWidget);

      // Verify hardcoded admin name is gone
      expect(find.text('Administrador'), findsNothing);
      // Hardcoded subtitle should still show or be replaced — but
      // "Gestión de RRHH" is replaced by user department/role if available
    });

    testWidgets('null user shows fallback in admin header', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminLayout(
              child: Text('Dashboard'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => const Stream<UserModel?>.empty(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Fallback should show "Usuario" and "U"
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
    });

    testWidgets('admin user with three names shows correct initials',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final testUser = UserModel(
        userId: 'admin-2',
        employeeId: 'EMP-admin-2',
        email: 'ana@example.com',
        displayName: 'Ana María Ruiz',
        role: UserRole.admin,
        weeklyHours: 40,
        createdAt: DateTime(2026, 1, 1),
        nombre: 'Ana',
        apellido1: 'Ruiz',
        apellido2: 'García',
      );

      final router = GoRouter(
        initialLocation: '/admin',
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminLayout(
              child: Text('Dashboard'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Three-name user: fullName = "Ana Ruiz García", initials "AR"
      expect(find.text('Ana Ruiz García'), findsOneWidget);
      expect(find.text('AR'), findsOneWidget);
    });
  });
}
