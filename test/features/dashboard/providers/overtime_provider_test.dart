import 'package:control_horario/features/dashboard/models/overtime_request_model.dart';
import 'package:control_horario/features/dashboard/providers/overtime_provider.dart';
import 'package:control_horario/features/dashboard/services/overtime_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OvertimeProvider', () {
    late _FakeOvertimeService fakeService;
    late ProviderContainer container;

    setUp(() {
      fakeService = _FakeOvertimeService();
      container = ProviderContainer(
        overrides: [
          overtimeServiceProvider.overrideWith((ref) => fakeService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('checkAndCreateIfNeeded', () {
      test('creates a pending request when actual hours exceed weekly hours',
          () async {
        final weekStart = DateTime(2026, 5, 11); // Monday

        await container
            .read(overtimeNotifierProvider.notifier)
            .checkAndCreateIfNeeded(
              userId: 'user-1',
              weekStart: weekStart,
              weeklyHours: 40,
              actualHours: 44,
            );

        expect(fakeService.createdRequests.length, 1);
        expect(fakeService.createdRequests.first.userId, 'user-1');
        expect(fakeService.createdRequests.first.weekStart, weekStart);
        expect(fakeService.createdRequests.first.requestedHours, 4.0);
        expect(fakeService.createdRequests.first.status,
            OvertimeRequestStatus.pending);
      });

      test('does NOT create a request when actual hours equal weekly hours',
          () async {
        final weekStart = DateTime(2026, 5, 11);

        await container
            .read(overtimeNotifierProvider.notifier)
            .checkAndCreateIfNeeded(
              userId: 'user-1',
              weekStart: weekStart,
              weeklyHours: 40,
              actualHours: 40,
            );

        expect(fakeService.createdRequests, isEmpty);
      });

      test('does NOT create a request when actual hours are below weekly hours',
          () async {
        final weekStart = DateTime(2026, 5, 11);

        await container
            .read(overtimeNotifierProvider.notifier)
            .checkAndCreateIfNeeded(
              userId: 'user-1',
              weekStart: weekStart,
              weeklyHours: 40,
              actualHours: 38.5,
            );

        expect(fakeService.createdRequests, isEmpty);
      });

      test('creates request with fractional overtime hours', () async {
        final weekStart = DateTime(2026, 5, 11);

        await container
            .read(overtimeNotifierProvider.notifier)
            .checkAndCreateIfNeeded(
              userId: 'user-1',
              weekStart: weekStart,
              weeklyHours: 37.5,
              actualHours: 41.25,
            );

        expect(fakeService.createdRequests.length, 1);
        expect(fakeService.createdRequests.first.requestedHours, 3.75);
      });
    });

    group('approveRequest', () {
      test('approves a pending request as supervisor', () async {
        final weekStart = DateTime(2026, 5, 11);
        final id = await fakeService.createRequest(
          userId: 'user-1',
          weekStart: weekStart,
          requestedHours: 4.0,
        );

        await container
            .read(overtimeNotifierProvider.notifier)
            .approveRequest(id, approvedBy: 'supervisor-1');

        final approved = fakeService.approvedRequests[id];
        expect(approved, isNotNull);
        expect(approved!.status, OvertimeRequestStatus.approved);
        expect(approved.approvedBy, 'supervisor-1');
      });
    });

    group('rejectRequest', () {
      test('rejects a pending request as supervisor', () async {
        final weekStart = DateTime(2026, 5, 11);
        final id = await fakeService.createRequest(
          userId: 'user-1',
          weekStart: weekStart,
          requestedHours: 4.0,
        );

        await container
            .read(overtimeNotifierProvider.notifier)
            .rejectRequest(id, rejectedBy: 'supervisor-1');

        final rejected = fakeService.rejectedRequests[id];
        expect(rejected, isNotNull);
        expect(rejected!.status, OvertimeRequestStatus.rejected);
        expect(rejected.rejectedBy, 'supervisor-1');
      });
    });
  });
}

/// Fake OvertimeService that tracks created/approved/rejected requests
class _FakeOvertimeService extends OvertimeService {
  _FakeOvertimeService() : super.test();

  final List<OvertimeRequestModel> createdRequests = [];
  final Map<String, OvertimeRequestModel> approvedRequests = {};
  final Map<String, OvertimeRequestModel> rejectedRequests = {};
  int _nextId = 1;

  @override
  Future<String> createRequest({
    required String userId,
    required DateTime weekStart,
    required double requestedHours,
  }) async {
    final id = 'overtime-$_nextId';
    _nextId++;
    final request = OvertimeRequestModel(
      id: id,
      userId: userId,
      weekStart: weekStart,
      requestedHours: requestedHours,
      status: OvertimeRequestStatus.pending,
      createdAt: DateTime.now(),
    );
    createdRequests.add(request);
    return id;
  }

  @override
  Future<void> approveRequest(String id, {required String approvedBy}) async {
    final request = _findRequest(id);
    if (request != null) {
      final approved = request.copyWith(
        status: OvertimeRequestStatus.approved,
        approvedBy: approvedBy,
        approvedAt: DateTime.now(),
      );
      createdRequests.removeWhere((r) => r.id == id);
      approvedRequests[id] = approved;
    }
  }

  @override
  Future<void> rejectRequest(String id, {required String rejectedBy}) async {
    final request = _findRequest(id);
    if (request != null) {
      final rejected = request.copyWith(
        status: OvertimeRequestStatus.rejected,
        rejectedBy: rejectedBy,
        rejectedAt: DateTime.now(),
      );
      createdRequests.removeWhere((r) => r.id == id);
      rejectedRequests[id] = rejected;
    }
  }

  OvertimeRequestModel? _findRequest(String id) {
    for (final r in createdRequests) {
      if (r.id == id) return r;
    }
    return approvedRequests[id] ?? rejectedRequests[id];
  }
}
