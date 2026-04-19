import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/features/dashboard/providers/time_records_provider.dart';
import 'package:control_horario/features/dashboard/services/time_records_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeRecordsNotifier.validateRecord', () {
    test('permite a un admin validar cualquier registro', () async {
      final fakeService = _FakeTimeRecordsService();
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(_admin())),
          timeRecordsServiceProvider.overrideWith((ref) => fakeService),
          timeRecordValidationTargetLookupProvider.overrideWith(
            (ref) => (String userId) async => _employee(userId),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProvider.future);

      await container
          .read(timeRecordsNotifierProvider.notifier)
          .validateRecord('employee-a', 'record-1', 'admin-1');

      expect(fakeService.validations, [
        const _ValidationCall(
          userId: 'employee-a',
          recordId: 'record-1',
          validatedBy: 'admin-1',
        ),
      ]);
    });

    test('permite a un supervisor validar un miembro de su equipo', () async {
      final fakeService = _FakeTimeRecordsService();
      final supervisor = _employee(
        'supervisor-1',
        isSupervisor: true,
      );
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(supervisor)),
          timeRecordsServiceProvider.overrideWith((ref) => fakeService),
          timeRecordValidationTargetLookupProvider.overrideWith(
            (ref) => (String userId) async => _employee(
                  userId,
                  supervisorId: supervisor.userId,
                ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProvider.future);

      await container
          .read(timeRecordsNotifierProvider.notifier)
          .validateRecord('employee-a', 'record-2', supervisor.userId);

      expect(fakeService.validations, [
        _ValidationCall(
          userId: 'employee-a',
          recordId: 'record-2',
          validatedBy: supervisor.userId,
        ),
      ]);
    });

    test('rechaza a un supervisor que intenta validar fuera de su equipo',
        () async {
      final fakeService = _FakeTimeRecordsService();
      final supervisor = _employee(
        'supervisor-1',
        isSupervisor: true,
      );
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(supervisor)),
          timeRecordsServiceProvider.overrideWith((ref) => fakeService),
          timeRecordValidationTargetLookupProvider.overrideWith(
            (ref) => (String userId) async => _employee(
                  userId,
                  supervisorId: 'other-supervisor',
                ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProvider.future);

      await expectLater(
        container
            .read(timeRecordsNotifierProvider.notifier)
            .validateRecord('employee-b', 'record-3', supervisor.userId),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('propio equipo'),
          ),
        ),
      );
      expect(fakeService.validations, isEmpty);
    });

    test('rechaza a un supervisor inactivo aunque tenga la marca isSupervisor',
        () async {
      final fakeService = _FakeTimeRecordsService();
      final supervisor = _employee(
        'supervisor-1',
        isSupervisor: true,
        isActive: false,
      );
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Stream.value(supervisor)),
          timeRecordsServiceProvider.overrideWith((ref) => fakeService),
          timeRecordValidationTargetLookupProvider.overrideWith(
            (ref) => (String userId) async => _employee(
                  userId,
                  supervisorId: supervisor.userId,
                ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentUserProvider.future);

      await expectLater(
        container
            .read(timeRecordsNotifierProvider.notifier)
            .validateRecord('employee-a', 'record-4', supervisor.userId),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('necesitas iniciar sesión'),
          ),
        ),
      );
      expect(fakeService.validations, isEmpty);
    });
  });
}

class _FakeTimeRecordsService extends TimeRecordsService {
  _FakeTimeRecordsService() : super.test();

  final List<_ValidationCall> validations = <_ValidationCall>[];

  @override
  Future<void> validateRecord(
    String userId,
    String recordId,
    String validatedBy,
  ) async {
    validations.add(
      _ValidationCall(
        userId: userId,
        recordId: recordId,
        validatedBy: validatedBy,
      ),
    );
  }
}

class _ValidationCall {
  final String userId;
  final String recordId;
  final String validatedBy;

  const _ValidationCall({
    required this.userId,
    required this.recordId,
    required this.validatedBy,
  });

  @override
  bool operator ==(Object other) {
    return other is _ValidationCall &&
        other.userId == userId &&
        other.recordId == recordId &&
        other.validatedBy == validatedBy;
  }

  @override
  int get hashCode => Object.hash(userId, recordId, validatedBy);
}

UserModel _admin() => UserModel(
      userId: 'admin-1',
      employeeId: 'EMP-admin-1',
      email: 'admin@example.com',
      displayName: 'Admin Uno',
      role: UserRole.admin,
      weeklyHours: 40,
      isActive: true,
      createdAt: DateTime(2026, 4, 1),
      nombre: 'Admin',
      apellido1: 'Uno',
    );

UserModel _employee(
  String userId, {
  bool isSupervisor = false,
  String? supervisorId,
  bool isActive = true,
}) =>
    UserModel(
      userId: userId,
      employeeId: 'EMP-$userId',
      email: '$userId@example.com',
      displayName: userId,
      role: UserRole.employee,
      isSupervisor: isSupervisor,
      supervisorId: supervisorId,
      weeklyHours: 40,
      isActive: isActive,
      createdAt: DateTime(2026, 4, 1),
      nombre: isSupervisor ? 'Supervisor' : 'Empleado',
      apellido1: userId,
    );
