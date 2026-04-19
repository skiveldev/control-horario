import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/features/dashboard/presentation/screens/team_screen.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/team_member_month_card.dart';
import 'package:control_horario/features/dashboard/providers/team_month_closure_provider.dart';
import 'package:control_horario/features/dashboard/providers/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeamScreen', () {
    testWidgets('el supervisor consulta solo a los miembros de su equipo',
        (tester) async {
      final selectedMonth = _currentMonth();
      final supervisor = _employee(
        userId: 'supervisor-a',
        displayName: 'Supervisor A',
        nombre: 'Supervisor',
        apellido1: 'A',
        isSupervisor: true,
      );
      final ana = _employee(
        userId: 'ana',
        displayName: 'Ana Bravo',
        nombre: 'Ana',
        apellido1: 'Bravo',
      );
      final bea = _employee(
        userId: 'bea',
        displayName: 'Bea Campos',
        nombre: 'Bea',
        apellido1: 'Campos',
      );

      await tester.pumpWidget(
        _buildTeamScreen(
          selectedMonth: selectedMonth,
          currentUser: supervisor,
          members: [ana, bea],
          overview: TeamMonthlyOverview(
            memberSummaries: [
              TeamMemberMonthlySummary(
                member: ana,
                totalRecords: 1,
                validatedRecords: 1,
                pendingRecords: 0,
                monthlyRecords: const [],
                pendingRecordItems: const [],
              ),
              TeamMemberMonthlySummary(
                member: bea,
                totalRecords: 2,
                validatedRecords: 1,
                pendingRecords: 1,
                monthlyRecords: const [],
                pendingRecordItems: const [],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Equipo'), findsOneWidget);
      expect(
        find.byType(TeamMemberMonthCard, skipOffstage: false),
        findsNWidgets(2),
      );
      expect(
        find.text('Ana Bravo', findRichText: true, skipOffstage: false),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text('Bea Campos', findRichText: true, skipOffstage: false),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text('Carlos Díaz', findRichText: true, skipOffstage: false),
        findsNothing,
      );
      expect(find.text('Resumen del equipo'), findsOneWidget);
    });

    testWidgets(
        'muestra estado vacío cuando el supervisor no tiene equipo asignado',
        (tester) async {
      final selectedMonth = _currentMonth();
      final supervisor = _employee(
        userId: 'supervisor-a',
        displayName: 'Supervisor A',
        nombre: 'Supervisor',
        apellido1: 'A',
        isSupervisor: true,
      );

      await tester.pumpWidget(
        _buildTeamScreen(
          selectedMonth: selectedMonth,
          currentUser: supervisor,
          members: const [],
          overview: const TeamMonthlyOverview(memberSummaries: []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Equipo'), findsOneWidget);
      expect(
        find.text('No tienes empleados asignados en tu equipo.'),
        findsOneWidget,
      );
      expect(find.text('Resumen del equipo'), findsNothing);
    });
  });
}

Widget _buildTeamScreen({
  required DateTime selectedMonth,
  required UserModel currentUser,
  required List<UserModel> members,
  required TeamMonthlyOverview overview,
}) {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(currentUser)),
      supervisedTeamMembersProvider
          .overrideWith((ref) => Stream.value(members)),
      teamMonthClosureProvider(selectedMonth).overrideWith((ref) async => null),
      teamMonthlyOverviewProvider(selectedMonth)
          .overrideWith((ref) async => overview),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(800, 1000)),
        child: const SizedBox(
          width: 800,
          height: 1000,
          child: TeamScreen(),
        ),
      ),
    ),
  );
}

DateTime _currentMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}

UserModel _employee({
  required String userId,
  required String displayName,
  required String nombre,
  required String apellido1,
  bool isSupervisor = false,
}) {
  return UserModel(
    userId: userId,
    employeeId: 'EMP-$userId',
    email: '$userId@example.com',
    displayName: displayName,
    role: UserRole.employee,
    isSupervisor: isSupervisor,
    weeklyHours: 40,
    isActive: true,
    createdAt: DateTime(2026, 4, 1),
    nombre: nombre,
    apellido1: apellido1,
  );
}
