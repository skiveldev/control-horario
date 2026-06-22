import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:control_horario/features/admin/providers/admin_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Helper: build an admin dashboard test widget with provider overrides.
Future<void> pumpAdminDashboard(
  WidgetTester tester, {
  required String userId,
  required String displayName,
  int employeeCount = 8,
}) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final testUser = UserModel(
    userId: userId,
    employeeId: 'EMP-$userId',
    email: '$userId@example.com',
    displayName: displayName,
    role: UserRole.admin,
    weeklyHours: 40,
    createdAt: DateTime(2026, 1, 1),
  );

  final router = GoRouter(
    initialLocation: AppRouter.admin,
    routes: [
      GoRoute(
        path: AppRouter.admin,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRouter.adminSettings,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Admin Settings')),
        ),
      ),
      GoRoute(
        path: AppRouter.settings,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings')),
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
        employeesCountProvider.overrideWith(
          (ref) => Stream.value(employeeCount),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AdminDashboardScreen mock data cleanup', () {
    testWidgets('NO muestra valores mock en tarjetas de métricas', (
      tester,
    ) async {
      await pumpAdminDashboard(tester, userId: 'admin-1', displayName: 'Admin');

      // Mock values should NOT appear
      expect(find.text('485'), findsNothing);
      expect(find.text('3'), findsNothing);
      expect(find.text('12'), findsNothing);
      expect(find.text('97%'), findsNothing);
      expect(find.text('+4'), findsNothing);
      // Badge "+12" en Total Empleados también es fake — debe eliminarse
      expect(find.text('+12'), findsNothing);
    });

    testWidgets('Total Empleados NO muestra badge fake', (tester) async {
      await pumpAdminDashboard(
        tester,
        userId: 'admin-badge',
        displayName: 'Admin',
        employeeCount: 8,
      );

      // "Total Empleados" muestra dato real (8) pero SIN badge "+12"
      expect(find.text('8'), findsOneWidget);
      expect(find.text('+12'), findsNothing);
    });

    testWidgets('Muestra "—" en métricas no disponibles', (tester) async {
      await pumpAdminDashboard(
        tester,
        userId: 'admin-2',
        displayName: 'Admin',
        employeeCount: 8,
      );

      // "Total Empleados" muestra dato real (8)
      expect(find.text('8'), findsOneWidget);
      // Las métricas mock deben mostrar placeholder "—"
      expect(find.text('—'), findsAtLeastNWidgets(3));
    });

    testWidgets('WeeklyActivityChart muestra placeholder "Sin datos"', (
      tester,
    ) async {
      await pumpAdminDashboard(tester, userId: 'admin-3', displayName: 'Admin');

      expect(find.text('Sin datos'), findsOneWidget);
      // Valores mock no deben aparecer
      expect(find.text('420'), findsNothing);
      expect(find.text('490'), findsNothing);
    });

    testWidgets('Bottom row muestra estados vacíos', (tester) async {
      await pumpAdminDashboard(tester, userId: 'admin-4', displayName: 'Admin');

      expect(find.text('No hay solicitudes pendientes'), findsOneWidget);
      expect(find.text('Sin alertas activas'), findsOneWidget);
      expect(find.text('Usuario 1'), findsNothing);
      expect(find.text('Fichajes Incompletos'), findsNothing);
    });

    testWidgets('NO muestra campo de búsqueda activo', (tester) async {
      await pumpAdminDashboard(tester, userId: 'admin-5', displayName: 'Admin');

      // El hint text del campo de búsqueda no debe aparecer
      expect(find.text('Buscar reportes, empleados...'), findsNothing);
    });

    testWidgets('Muestra aviso de búsqueda global en construcción', (
      tester,
    ) async {
      await pumpAdminDashboard(tester, userId: 'admin-6', displayName: 'Admin');

      // Debe mostrar el aviso no interactivo
      expect(
        find.text('Búsqueda global — Más adelante'),
        findsOneWidget,
      );
    });

    testWidgets('WeeklyActivityChart no muestra dropdown activo cuando vacío', (
      tester,
    ) async {
      await pumpAdminDashboard(tester, userId: 'admin-7', displayName: 'Admin');

      // Las opciones del dropdown NO deben aparecer
      expect(find.text('Esta semana'), findsNothing);
      expect(find.text('Última semana'), findsNothing);
      expect(find.text('Últimos 30 días'), findsNothing);

      // El badge "Más adelante" debe estar visible
      expect(find.text('Más adelante'), findsOneWidget);
    });
  });
}
