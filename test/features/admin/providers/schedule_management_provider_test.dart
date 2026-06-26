import 'dart:async';

import 'package:control_horario/core/services/schedule_service.dart';
import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/features/admin/providers/schedule_management_provider.dart';
import 'package:control_horario/features/auth/models/user_model.dart';
import 'package:control_horario/features/auth/providers/auth_provider.dart';
import 'package:control_horario/core/services/firebase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// FAKES
// =============================================================================

/// Fake ScheduleService that records calls for assertions.
class _FakeScheduleService implements ScheduleService {
  final calls = <_FakeCall>[];

  @override
  Future<String> createTemplate({
    required String name,
    required String description,
    required Map<String, DaySchedule> weeklySchedule,
    required int totalWeeklyHours,
    required String createdBy,
  }) async {
    calls.add(_FakeCall(
      method: 'createTemplate',
      name: name,
      weeklySchedule: weeklySchedule,
      totalWeeklyHours: totalWeeklyHours,
      createdBy: createdBy,
    ));
    return 'fake-id-${calls.length}';
  }

  @override
  Future<void> updateTemplate({
    required String scheduleId,
    required String lastModifiedBy,
    String? name,
    String? description,
    Map<String, DaySchedule>? weeklySchedule,
    int? totalWeeklyHours,
  }) async {
    calls.add(_FakeCall(
      method: 'updateTemplate',
      scheduleId: scheduleId,
      name: name,
      weeklySchedule: weeklySchedule,
      totalWeeklyHours: totalWeeklyHours,
      lastModifiedBy: lastModifiedBy,
    ));
  }

  // Unused by create/update but must exist for the interface.
  @override
  dynamic noSuchMethod(Invocation inv) => super.noSuchMethod(inv);
}

class _FakeCall {
  final String method;
  final String? scheduleId;
  final String? name;
  final Map<String, DaySchedule>? weeklySchedule;
  final int? totalWeeklyHours;
  final String? createdBy;
  final String? lastModifiedBy;

  _FakeCall({
    this.method = '',
    this.scheduleId,
    this.name,
    this.weeklySchedule,
    this.totalWeeklyHours,
    this.createdBy,
    this.lastModifiedBy,
  });
}

// =============================================================================
// HELPERS
// =============================================================================

UserModel _adminUser() => UserModel(
      userId: 'admin-1',
      employeeId: 'EMP001',
      email: 'admin@test.com',
      displayName: 'Test Admin',
      role: UserRole.admin,
      weeklyHours: 40,
      createdAt: DateTime(2026, 1, 1),
    );

UserModel _employeeUser() => UserModel(
      userId: 'emp-1',
      employeeId: 'EMP002',
      email: 'emp@test.com',
      displayName: 'Test Employee',
      role: UserRole.employee,
      weeklyHours: 40,
      createdAt: DateTime(2026, 1, 1),
    );

DaySchedule _workDay(List<TimeShift> shifts) => DaySchedule(
      isWorkDay: true,
      shifts: shifts,
      dailyHours: 8.0, // ← will be overridden by validator derivation
    );

DaySchedule _restDay() => const DaySchedule(isWorkDay: false);

Map<String, DaySchedule> _validWeek() => {
      'monday': _workDay([_shift('09:00', '17:00')]),
      'tuesday': _workDay([_shift('09:00', '17:00')]),
      'wednesday': _workDay([_shift('09:00', '17:00')]),
      'thursday': _workDay([_shift('09:00', '17:00')]),
      'friday': _workDay([_shift('09:00', '17:00')]),
      'saturday': _restDay(),
      'sunday': _restDay(),
    };

TimeShift _shift(String start, String end) =>
    TimeShift(startTime: start, endTime: end);

ProviderContainer _container({
  required _FakeScheduleService fakeService,
  UserModel? currentUser,
}) {
  return ProviderContainer(
    overrides: [
      scheduleServiceProvider.overrideWith((ref) => fakeService),
      currentUserProvider.overrideWith(
        (ref) => Stream.value(currentUser),
      ),
    ],
  );
}

// =============================================================================
// TESTS
// =============================================================================

void main() {
  group('ScheduleManagementProvider createTemplate', () {
    late _FakeScheduleService fakeService;
    late ProviderContainer container;

    setUp(() {
      fakeService = _FakeScheduleService();
    });

    tearDown(() {
      container.dispose();
    });

    // ------------------------------------------------------------------------
    // AUTH ERRORS
    // ------------------------------------------------------------------------
    test('throws when user is not authenticated', () async {
      container = _container(fakeService: fakeService, currentUser: null);

      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).createTemplate(
                  name: 'Test',
                  description: '',
                  weeklySchedule: _validWeek(),
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Usuario no autenticado'),
        )),
      );
    });

    test('throws when user is not admin', () async {
      container =
          _container(fakeService: fakeService, currentUser: _employeeUser());

      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).createTemplate(
                  name: 'Test',
                  description: '',
                  weeklySchedule: _validWeek(),
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Sin permisos'),
        )),
      );
    });

    // ------------------------------------------------------------------------
    // VALID SUBMISSIONS
    // ------------------------------------------------------------------------
    test('succeeds with valid schedule and normalizes dailyHours', () async {
      container =
          _container(fakeService: fakeService, currentUser: _adminUser());

      final scheduleId = await container
          .read(scheduleManagementProvider.notifier)
          .createTemplate(
            name: 'Jornada 40h',
            description: 'Standard week',
            weeklySchedule: _validWeek(),
          );

      expect(scheduleId, isNotEmpty);
      expect(fakeService.calls, hasLength(1));
      final call = fakeService.calls.first;
      expect(call.method, 'createTemplate');
      expect(call.name, 'Jornada 40h');
      expect(call.totalWeeklyHours, 40);

      // Verify dailyHours are derived from shifts (not trusted)
      final savedMonday = call.weeklySchedule!['monday']!;
      expect(savedMonday.dailyHours, closeTo(8.0, 0.01));
    });

    test('succeeds with split jornada schedule', () async {
      container =
          _container(fakeService: fakeService, currentUser: _adminUser());

      final schedule = <String, DaySchedule>{
        'monday': _workDay([
          _shift('09:00', '13:00'),
          _shift('16:00', '20:00'),
        ]),
        'tuesday': _workDay([_shift('09:00', '17:00')]),
        'wednesday': _restDay(),
        'thursday': _restDay(),
        'friday': _restDay(),
        'saturday': _restDay(),
        'sunday': _restDay(),
      };

      await container.read(scheduleManagementProvider.notifier).createTemplate(
            name: 'Split',
            description: '',
            weeklySchedule: schedule,
          );

      expect(fakeService.calls, hasLength(1));
      expect(fakeService.calls.first.totalWeeklyHours, 16);
    });

    // ------------------------------------------------------------------------
    // VALIDATION ERRORS — detected by ScheduleValidator
    // ------------------------------------------------------------------------
    test('throws when schedule has endTime before startTime', () async {
      container =
          _container(fakeService: fakeService, currentUser: _adminUser());

      final invalid = <String, DaySchedule>{
        'monday': _workDay([_shift('17:00', '09:00')]),
        'tuesday': _restDay(),
        'wednesday': _restDay(),
        'thursday': _restDay(),
        'friday': _restDay(),
        'saturday': _restDay(),
        'sunday': _restDay(),
      };

      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).createTemplate(
                  name: 'Invalid',
                  description: '',
                  weeklySchedule: invalid,
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('must be after'),
        )),
      );

      // Service should NOT be called
      expect(fakeService.calls, isEmpty);
    });

    test('throws when schedule has overlapping shifts', () async {
      container =
          _container(fakeService: fakeService, currentUser: _adminUser());

      final invalid = <String, DaySchedule>{
        'monday': _workDay([
          _shift('09:00', '14:00'),
          _shift('13:00', '18:00'), // overlaps
        ]),
        'tuesday': _restDay(),
        'wednesday': _restDay(),
        'thursday': _restDay(),
        'friday': _restDay(),
        'saturday': _restDay(),
        'sunday': _restDay(),
      };

      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).createTemplate(
                  name: 'Invalid',
                  description: '',
                  weeklySchedule: invalid,
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('overlap'),
        )),
      );

      expect(fakeService.calls, isEmpty);
    });

    test('throws when schedule has no work days', () async {
      container =
          _container(fakeService: fakeService, currentUser: _adminUser());

      final invalid = <String, DaySchedule>{
        'monday': _restDay(),
        'tuesday': _restDay(),
        'wednesday': _restDay(),
        'thursday': _restDay(),
        'friday': _restDay(),
        'saturday': _restDay(),
        'sunday': _restDay(),
      };

      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).createTemplate(
                  name: 'Empty',
                  description: '',
                  weeklySchedule: invalid,
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('working day'),
        )),
      );
    });

    test('throws when name is empty', () async {
      container =
          _container(fakeService: fakeService, currentUser: _adminUser());

      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).createTemplate(
                  name: '   ',
                  description: '',
                  weeklySchedule: _validWeek(),
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('name'),
        )),
      );
    });
  });

  group('ScheduleManagementProvider updateTemplate', () {
    late _FakeScheduleService fakeService;
    late ProviderContainer container;

    setUp(() {
      fakeService = _FakeScheduleService();
      container =
          _container(fakeService: fakeService, currentUser: _adminUser());
    });

    tearDown(() {
      container.dispose();
    });

    test('succeeds with valid schedule update', () async {
      await container.read(scheduleManagementProvider.notifier).updateTemplate(
            scheduleId: 'sched-1',
            name: 'Updated Name',
            weeklySchedule: _validWeek(),
          );

      expect(fakeService.calls, hasLength(1));
      final call = fakeService.calls.first;
      expect(call.method, 'updateTemplate');
      expect(call.name, 'Updated Name');
      expect(call.totalWeeklyHours, 40);
    });

    test('succeeds without weeklySchedule (partial update)', () async {
      await container.read(scheduleManagementProvider.notifier).updateTemplate(
            scheduleId: 'sched-1',
            name: 'New Name Only',
          );

      expect(fakeService.calls, hasLength(1));
      final call = fakeService.calls.first;
      expect(call.name, 'New Name Only');
      expect(call.weeklySchedule, isNull);
      expect(call.totalWeeklyHours, isNull);
    });

    test('throws when schedule validation fails', () async {
      final invalid = <String, DaySchedule>{
        'monday': _workDay([_shift('17:00', '09:00')]),
        'tuesday': _restDay(),
        'wednesday': _restDay(),
        'thursday': _restDay(),
        'friday': _restDay(),
        'saturday': _restDay(),
        'sunday': _restDay(),
      };

      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).updateTemplate(
                  scheduleId: 'sched-1',
                  weeklySchedule: invalid,
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('must be after'),
        )),
      );

      expect(fakeService.calls, isEmpty);
    });

    test('throws when name is empty (update without weeklySchedule)', () async {
      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).updateTemplate(
                  scheduleId: 'sched-1',
                  name: '   ',
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('name'),
        )),
      );

      expect(fakeService.calls, isEmpty);
    });

    test('throws when name is whitespace-only (update with weeklySchedule)',
        () async {
      expect(
        () =>
            container.read(scheduleManagementProvider.notifier).updateTemplate(
                  scheduleId: 'sched-1',
                  name: '\t\n ',
                  weeklySchedule: _validWeek(),
                ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('name'),
        )),
      );

      expect(fakeService.calls, isEmpty);
    });

    test('throws when user is not authenticated', () async {
      container.dispose();
      container = _container(
        fakeService: fakeService,
        currentUser: null,
      );

      expect(
        () => container
            .read(scheduleManagementProvider.notifier)
            .updateTemplate(scheduleId: 'sched-1'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Usuario no autenticado'),
        )),
      );
    });
  });
}
