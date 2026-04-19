import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/team_member_month_card.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/team_month_summary_card.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/team_pending_breakdown_card.dart';
import 'package:control_horario/features/dashboard/presentation/widgets/team_screen_header.dart';
import 'package:control_horario/features/dashboard/providers/team_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeamMonthSummaryCard', () {
    testWidgets('muestra métricas agregadas del equipo y del estado mensual',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: TeamMonthSummaryCard(
            overview: TeamMonthlyOverview(
              memberSummaries: [
                TeamMemberMonthlySummary(
                  member: _employee('ana', 'Ana', 'Bravo'),
                  totalRecords: 3,
                  validatedRecords: 2,
                  pendingRecords: 1,
                  monthlyRecords: const [],
                  pendingRecordItems: const [],
                ),
                TeamMemberMonthlySummary(
                  member: _employee('bea', 'Bea', 'Campos'),
                  totalRecords: 0,
                  validatedRecords: 0,
                  pendingRecords: 0,
                  monthlyRecords: const [],
                  pendingRecordItems: const [],
                ),
              ],
            ),
            isClosed: false,
          ),
        ),
      );

      expect(find.text('Resumen del equipo'), findsOneWidget);
      expect(find.text('Miembros'), findsOneWidget);
      expect(find.text('Registros del mes'), findsOneWidget);
      expect(find.text('Validados'), findsOneWidget);
      expect(find.text('Pendientes'), findsOneWidget);
      expect(find.text('Miembros con pendientes'), findsOneWidget);
      expect(find.text('Sin registros'), findsOneWidget);
      expect(find.text('Mes abierto'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('TeamPendingBreakdownCard', () {
    testWidgets('resume cuántos empleados siguen bloqueando el cierre',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: TeamPendingBreakdownCard(
            items: [
              TeamPendingBreakdownItem(
                member: _employee('ana', 'Ana', 'Bravo'),
                pendingRecords: 3,
              ),
              TeamPendingBreakdownItem(
                member: _employee('bea', 'Bea', 'Campos'),
                pendingRecords: 1,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Pendientes antes de cerrar mes'), findsOneWidget);
      expect(find.text('2 empleado(s) con pendientes'), findsOneWidget);
      expect(find.text('Ana Bravo'), findsOneWidget);
      expect(find.text('3 pendiente(s)'), findsOneWidget);
      expect(find.text('Bea Campos'), findsOneWidget);
      expect(find.text('1 pendiente(s)'), findsOneWidget);
    });
  });

  group('TeamMemberMonthCard', () {
    testWidgets(
        'muestra la acción Validar y explica cuando un registro está bloqueado',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: TeamMemberMonthCard(
            summary: TeamMemberMonthlySummary(
              member: _employee('ana', 'Ana', 'Bravo'),
              totalRecords: 2,
              validatedRecords: 0,
              pendingRecords: 2,
              monthlyRecords: const [],
              pendingRecordItems: [
                _record(
                  id: 'editable',
                  userId: 'ana',
                  date: '2026-04-02',
                  startTime: '09:00',
                  endTime: '13:00',
                ),
                _record(
                  id: 'blocked',
                  userId: 'ana',
                  date: '2026-04-03',
                  startTime: '10:00',
                  endTime: '14:00',
                  validationStatus: ValidationStatus.blocked,
                ),
              ],
            ),
            isMonthClosed: false,
            validatingRecordKeys: const <String>{},
            onValidateRecord: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.text('Validar'), findsOneWidget);
      expect(find.text('Bloqueado'), findsOneWidget);
      expect(
        find.text('Este registro está bloqueado por administración.'),
        findsOneWidget,
      );
    });
  });

  group('TeamScreenHeader', () {
    testWidgets('muestra pendientes en la acción de cierre', (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: TeamScreenHeader(
            isMobile: false,
            selectedMonth: DateTime(2026, 4, 1),
            isClosed: false,
            pendingCount: 3,
            onCloseMonth: () {},
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      );

      expect(find.text('Equipo'), findsOneWidget);
      expect(find.text('Cerrar mes (3 pendientes)'), findsOneWidget);
    });

    testWidgets('muestra estado cerrado cuando el mes ya no admite cambios',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: TeamScreenHeader(
            isMobile: true,
            selectedMonth: DateTime(2026, 4, 1),
            isClosed: true,
            pendingCount: 0,
            onCloseMonth: () {},
            onPreviousMonth: () {},
            onNextMonth: () {},
          ),
        ),
      );

      expect(find.text('Cerrado'), findsOneWidget);
    });
  });
}

Widget _wrap({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

UserModel _employee(String userId, String nombre, String apellido1) {
  return UserModel(
    userId: userId,
    employeeId: 'EMP-$userId',
    email: '$userId@example.com',
    displayName: '$nombre $apellido1',
    role: UserRole.employee,
    weeklyHours: 40,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    nombre: nombre,
    apellido1: apellido1,
  );
}

TimeRecordModel _record({
  required String id,
  required String userId,
  required String date,
  required String startTime,
  required String endTime,
  ValidationStatus validationStatus = ValidationStatus.editable,
}) {
  return TimeRecordModel(
    id: id,
    userId: userId,
    date: date,
    category: RecordCategory.work,
    startTime: startTime,
    endTime: endTime,
    location: 'Centro',
    durationMinutes: 240,
    createdAt: DateTime(2026, 4, 1, 8),
    updatedAt: DateTime(2026, 4, 1, 8),
    createdBy: userId,
    isManual: true,
    recordStatus: RecordStatus.completed,
    validationStatus: validationStatus,
  );
}
