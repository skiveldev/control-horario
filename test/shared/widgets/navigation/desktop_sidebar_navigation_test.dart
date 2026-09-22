import 'package:control_horario/core/router/app_router.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/shared/widgets/navigation/desktop_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DesktopSidebar navegación de equipo', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(const {'sidebarExpanded': true});
    });

    testWidgets('el supervisor ve el acceso a Equipo', (tester) async {
      await tester.pumpWidget(
        _buildAppWithUser(
          _employee(
            'supervisor-1',
            isSupervisor: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('desktop-nav-/team')), findsOneWidget);
      expect(find.text('Equipo'), findsOneWidget);
    });

    testWidgets('shows the canonical app brand in the expanded header',
        (tester) async {
      await tester.pumpWidget(_buildAppWithUser(_employee('employee-1')));
      await tester.pumpAndSettle();

      expect(find.text('controlhorario-rega'), findsOneWidget);
      expect(find.text('Control Horario'), findsNothing);
    });

    testWidgets('el empleado no supervisor no ve el acceso a Equipo',
        (tester) async {
      await tester.pumpWidget(
        _buildAppWithUser(
          _employee('employee-1'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('desktop-nav-/team')), findsNothing);
      expect(find.text('Equipo'), findsNothing);
    });
  });
}

Widget _buildAppWithUser(UserModel user) {
  final router = GoRouter(
    initialLocation: AppRouter.dashboard,
    routes: [
      GoRoute(
        path: AppRouter.dashboard,
        builder: (context, state) => const Scaffold(
          body: DesktopSidebar(),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(user)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

UserModel _employee(
  String userId, {
  bool isSupervisor = false,
}) =>
    UserModel(
      userId: userId,
      employeeId: 'EMP-$userId',
      email: '$userId@example.com',
      displayName: userId,
      role: UserRole.employee,
      isSupervisor: isSupervisor,
      weeklyHours: 40,
      isActive: true,
      createdAt: DateTime(2026, 4, 1),
      nombre: isSupervisor ? 'Supervisor' : 'Empleado',
      apellido1: userId,
    );
