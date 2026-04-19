import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/features/dashboard/providers/team_month_closure_provider.dart';
import 'package:control_horario/features/dashboard/providers/team_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildClosedMonthPayload', () {
    test('incluye auditoría mínima del cierre mensual', () {
      final closedAt = Object();
      final updatedAt = Object();

      final payload = buildClosedMonthPayload(
        const TeamMonthClosureWriteRequest(
          closureId: 'supervisor-1_2026-04',
          supervisorId: 'supervisor-1',
          month: '2026-04',
          closedBy: 'supervisor-1',
          teamMembers: 2,
          totalRecords: 8,
          pendingRecords: 0,
        ),
        closedAt: closedAt,
        updatedAt: updatedAt,
      );

      expect(payload['supervisorId'], 'supervisor-1');
      expect(payload['month'], '2026-04');
      expect(payload['status'], 'closed');
      expect(payload['closedAt'], same(closedAt));
      expect(payload['closedBy'], 'supervisor-1');
      expect(payload['updatedAt'], same(updatedAt));
    });

    test('preserva el snapshot agregado del equipo al cerrar el mes', () {
      final payload = buildClosedMonthPayload(
        const TeamMonthClosureWriteRequest(
          closureId: 'supervisor-1_2026-05',
          supervisorId: 'supervisor-1',
          month: '2026-05',
          closedBy: 'supervisor-1',
          teamMembers: 3,
          totalRecords: 12,
          pendingRecords: 0,
        ),
        closedAt: Object(),
        updatedAt: Object(),
      );

      expect(payload['teamSnapshot'], {
        'teamMembers': 3,
        'totalRecords': 12,
        'pendingRecords': 0,
      });
    });
  });

  group('TeamMonthClosureController.closeMonth', () {
    final month = DateTime(2026, 4, 1);

    test('crea el cierre mensual cuando no quedan pendientes', () async {
      final fakeWriter = _FakeTeamMonthClosureWriter();
      final supervisor = _supervisor();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(supervisor)),
          teamMonthClosureProvider.overrideWith(
            (ref, arg) async => null,
          ),
          teamMonthlyOverviewProvider.overrideWith(
            (ref, arg) async => TeamMonthlyOverview(
              memberSummaries: [
                TeamMemberMonthlySummary(
                  member: _member('employee-a'),
                  totalRecords: 2,
                  validatedRecords: 2,
                  pendingRecords: 0,
                  monthlyRecords: const [],
                  pendingRecordItems: const [],
                ),
              ],
            ),
          ),
          teamMonthClosureWriterProvider.overrideWith((ref) => fakeWriter),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProvider.future);

      await container
          .read(teamMonthClosureControllerProvider)
          .closeMonth(month);

      expect(
        fakeWriter.savedRequests,
        [
          _SavedClosureRequest(
            closureId: 'supervisor-1_2026-04',
            supervisorId: 'supervisor-1',
            month: '2026-04',
            closedBy: 'supervisor-1',
            teamMembers: 1,
            totalRecords: 2,
            pendingRecords: 0,
          ),
        ],
      );
    });

    test('bloquea el cierre mensual cuando hay registros pendientes', () async {
      final fakeWriter = _FakeTeamMonthClosureWriter();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider
              .overrideWith((ref) => Stream.value(_supervisor())),
          teamMonthClosureProvider.overrideWith(
            (ref, arg) async => null,
          ),
          teamMonthlyOverviewProvider.overrideWith(
            (ref, arg) async => TeamMonthlyOverview(
              memberSummaries: [
                TeamMemberMonthlySummary(
                  member: _member('employee-a'),
                  totalRecords: 3,
                  validatedRecords: 2,
                  pendingRecords: 1,
                  monthlyRecords: const [],
                  pendingRecordItems: const [],
                ),
              ],
            ),
          ),
          teamMonthClosureWriterProvider.overrideWith((ref) => fakeWriter),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProvider.future);

      await expectLater(
        container.read(teamMonthClosureControllerProvider).closeMonth(month),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('1 registros pendientes'),
          ),
        ),
      );
      expect(fakeWriter.savedRequests, isEmpty);
    });

    test('bloquea un segundo cierre cuando el mes ya está cerrado', () async {
      final fakeWriter = _FakeTeamMonthClosureWriter();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider
              .overrideWith((ref) => Stream.value(_supervisor())),
          teamMonthClosureProvider.overrideWith(
            (ref, arg) async => const TeamMonthClosure(
              id: 'supervisor-1_2026-04',
              supervisorId: 'supervisor-1',
              month: '2026-04',
              status: 'closed',
              closedAt: null,
              closedBy: 'supervisor-1',
              teamMembers: 1,
              totalRecords: 2,
            ),
          ),
          teamMonthlyOverviewProvider.overrideWith(
            (ref, arg) async => TeamMonthlyOverview(
              memberSummaries: [
                TeamMemberMonthlySummary(
                  member: _member('employee-a'),
                  totalRecords: 2,
                  validatedRecords: 2,
                  pendingRecords: 0,
                  monthlyRecords: const [],
                  pendingRecordItems: const [],
                ),
              ],
            ),
          ),
          teamMonthClosureWriterProvider.overrideWith((ref) => fakeWriter),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProvider.future);

      await expectLater(
        container.read(teamMonthClosureControllerProvider).closeMonth(month),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('ya está cerrado'),
          ),
        ),
      );
      expect(fakeWriter.savedRequests, isEmpty);
    });

    test('rechaza a un supervisor inactivo antes de intentar cerrar el mes',
        () async {
      final fakeWriter = _FakeTeamMonthClosureWriter();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => Stream.value(_supervisor(isActive: false)),
          ),
          teamMonthClosureWriterProvider.overrideWith((ref) => fakeWriter),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProvider.future);

      await expectLater(
        container.read(teamMonthClosureControllerProvider).closeMonth(month),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Sin permisos'),
          ),
        ),
      );
      expect(fakeWriter.savedRequests, isEmpty);
    });
  });
}

class _FakeTeamMonthClosureWriter extends TeamMonthClosureWriter {
  final List<_SavedClosureRequest> savedRequests = <_SavedClosureRequest>[];

  @override
  Future<void> saveClosedMonth(TeamMonthClosureWriteRequest request) async {
    savedRequests.add(
      _SavedClosureRequest(
        closureId: request.closureId,
        supervisorId: request.supervisorId,
        month: request.month,
        closedBy: request.closedBy,
        teamMembers: request.teamMembers,
        totalRecords: request.totalRecords,
        pendingRecords: request.pendingRecords,
      ),
    );
  }
}

class _SavedClosureRequest {
  final String closureId;
  final String supervisorId;
  final String month;
  final String closedBy;
  final int teamMembers;
  final int totalRecords;
  final int pendingRecords;

  const _SavedClosureRequest({
    required this.closureId,
    required this.supervisorId,
    required this.month,
    required this.closedBy,
    required this.teamMembers,
    required this.totalRecords,
    required this.pendingRecords,
  });

  @override
  bool operator ==(Object other) {
    return other is _SavedClosureRequest &&
        other.closureId == closureId &&
        other.supervisorId == supervisorId &&
        other.month == month &&
        other.closedBy == closedBy &&
        other.teamMembers == teamMembers &&
        other.totalRecords == totalRecords &&
        other.pendingRecords == pendingRecords;
  }

  @override
  int get hashCode => Object.hash(
        closureId,
        supervisorId,
        month,
        closedBy,
        teamMembers,
        totalRecords,
        pendingRecords,
      );
}

UserModel _supervisor({bool isActive = true}) => UserModel(
      userId: 'supervisor-1',
      employeeId: 'EMP-supervisor-1',
      email: 'supervisor@example.com',
      displayName: 'Supervisor Uno',
      role: UserRole.employee,
      isSupervisor: true,
      weeklyHours: 40,
      isActive: isActive,
      createdAt: DateTime(2026, 4, 1),
      nombre: 'Supervisor',
      apellido1: 'Uno',
    );

UserModel _member(String userId) => UserModel(
      userId: userId,
      employeeId: 'EMP-$userId',
      email: '$userId@example.com',
      displayName: userId,
      role: UserRole.employee,
      supervisorId: 'supervisor-1',
      weeklyHours: 40,
      isActive: true,
      createdAt: DateTime(2026, 4, 1),
      nombre: 'Empleado',
      apellido1: userId,
    );
