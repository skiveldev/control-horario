import 'package:flutter_test/flutter_test.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/providers/team_provider.dart';

void main() {
  group('buildTeamRecordQueryBatches', () {
    test('divide los userIds en lotes de 10 para reducir consultas', () {
      final userIds = List<String>.generate(23, (index) => 'user-$index');

      final batches = buildTeamRecordQueryBatches(userIds);

      expect(batches, hasLength(3));
      expect(batches[0], hasLength(10));
      expect(batches[1], hasLength(10));
      expect(batches[2], hasLength(3));
      expect(batches.expand((batch) => batch), orderedEquals(userIds));
    });

    test('ignora ids vacíos y duplicados antes de generar los lotes', () {
      final batches = buildTeamRecordQueryBatches([
        'ana',
        '',
        'ana',
        'bea',
        '  ',
        'carlos',
      ]);

      expect(
          batches,
          equals([
            ['ana', 'bea', 'carlos'],
          ]));
    });
  });

  group('buildTeamMonthlyOverviewFromRecords', () {
    test('agrega totales, pendientes y ordena el desglose por empleado', () {
      final ana = _employee(
        userId: 'ana',
        displayName: 'Ana',
        nombre: 'Ana',
        apellido1: 'Bravo',
      );
      final bea = _employee(
        userId: 'bea',
        displayName: 'Bea',
        nombre: 'Bea',
        apellido1: 'Campos',
      );
      final carlos = _employee(
        userId: 'carlos',
        displayName: 'Carlos',
        nombre: 'Carlos',
        apellido1: 'Díaz',
      );

      final overview = buildTeamMonthlyOverviewFromRecords(
        members: [carlos, ana, bea],
        monthlyRecords: [
          _record(
            id: 'r1',
            userId: 'ana',
            date: '2026-04-03',
            startTime: '09:00',
            endTime: '13:00',
            validationStatus: ValidationStatus.validated,
          ),
          _record(
            id: 'r2',
            userId: 'ana',
            date: '2026-04-04',
            startTime: '09:00',
            endTime: '13:00',
          ),
          _record(
            id: 'r3',
            userId: 'bea',
            date: '2026-04-02',
            startTime: '08:00',
            endTime: '12:00',
          ),
          _record(
            id: 'r4',
            userId: 'bea',
            date: '2026-04-01',
            startTime: '08:00',
            endTime: '12:00',
            validationStatus: ValidationStatus.blocked,
          ),
        ],
      );

      expect(
        overview.memberSummaries.map((item) => item.member.fullName),
        orderedEquals([
          'Ana Bravo',
          'Bea Campos',
          'Carlos Díaz',
        ]),
      );
      expect(overview.membersCount, 3);
      expect(overview.totalRecords, 4);
      expect(overview.validatedRecords, 1);
      expect(overview.pendingRecords, 3);
      expect(overview.membersWithPending, 2);
      expect(overview.membersWithoutRecords, 1);
      expect(
        overview.pendingBreakdown
            .map((item) => '${item.member.fullName}:${item.pendingRecords}'),
        orderedEquals([
          'Bea Campos:2',
          'Ana Bravo:1',
        ]),
      );
    });

    test(
        'ordena los registros pendientes por fecha y hora dentro de cada miembro',
        () {
      final ana = _employee(
        userId: 'ana',
        displayName: 'Ana',
        nombre: 'Ana',
        apellido1: 'Bravo',
      );

      final overview = buildTeamMonthlyOverviewFromRecords(
        members: [ana],
        monthlyRecords: [
          _record(
            id: 'late',
            userId: 'ana',
            date: '2026-04-10',
            startTime: '12:00',
            endTime: '14:00',
          ),
          _record(
            id: 'early',
            userId: 'ana',
            date: '2026-04-01',
            startTime: '08:00',
            endTime: '10:00',
          ),
          _record(
            id: 'middle',
            userId: 'ana',
            date: '2026-04-10',
            startTime: '09:00',
            endTime: '11:00',
          ),
        ],
      );

      expect(
        overview.memberSummaries.single.pendingRecordItems
            .map((item) => item.id),
        orderedEquals(['early', 'middle', 'late']),
      );
    });
  });
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
