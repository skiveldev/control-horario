import 'package:control_horario/features/dashboard/models/overtime_request_model.dart';
import 'package:control_horario/features/dashboard/services/overtime_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OvertimeService', () {
    late _FakeOvertimeService service;

    setUp(() {
      service = _FakeOvertimeService();
    });

    group('createRequest', () {
      test('creates a pending overtime request', () async {
        final weekStart = DateTime(2026, 5, 11); // Monday
        final id = await service.createRequest(
          userId: 'user-1',
          weekStart: weekStart,
          requestedHours: 4.0,
        );

        expect(id, isNotEmpty);
        expect(service.createdRequests.length, 1);
        expect(service.createdRequests.first.userId, 'user-1');
        expect(service.createdRequests.first.weekStart, weekStart);
        expect(service.createdRequests.first.requestedHours, 4.0);
        expect(service.createdRequests.first.status,
            OvertimeRequestStatus.pending);
      });

      test('throws when called on test double without overrides', () async {
        final realService = OvertimeService.test();
        await expectLater(
          realService.createRequest(
            userId: 'user-1',
            weekStart: DateTime(2026, 5, 11),
            requestedHours: 4.0,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('test double'),
            ),
          ),
        );
      });
    });

    group('getRequestsByUserAndWeek', () {
      test('returns empty list when no requests exist', () async {
        final weekStart = DateTime(2026, 5, 11);
        final requests =
            await service.getRequestsByUserAndWeek('user-1', weekStart);

        expect(requests, isEmpty);
      });

      test('returns requests for matching userId and week', () async {
        final weekStart = DateTime(2026, 5, 11);
        await service.createRequest(
          userId: 'user-1',
          weekStart: weekStart,
          requestedHours: 4.0,
        );
        await service.createRequest(
          userId: 'user-2',
          weekStart: weekStart,
          requestedHours: 2.0,
        );

        final user1Requests =
            await service.getRequestsByUserAndWeek('user-1', weekStart);
        expect(user1Requests.length, 1);
        expect(user1Requests.first.userId, 'user-1');

        final user2Requests =
            await service.getRequestsByUserAndWeek('user-2', weekStart);
        expect(user2Requests.length, 1);
        expect(user2Requests.first.userId, 'user-2');
      });

      test('returns empty for different week', () async {
        final weekA = DateTime(2026, 5, 11);
        final weekB = DateTime(2026, 5, 18);
        await service.createRequest(
          userId: 'user-1',
          weekStart: weekA,
          requestedHours: 4.0,
        );

        final requests =
            await service.getRequestsByUserAndWeek('user-1', weekB);
        expect(requests, isEmpty);
      });
    });

    group('approveRequest', () {
      test('transitions status from pending to approved', () async {
        final weekStart = DateTime(2026, 5, 11);
        final id = await service.createRequest(
          userId: 'user-1',
          weekStart: weekStart,
          requestedHours: 4.0,
        );

        await service.approveRequest(id, approvedBy: 'supervisor-1');

        final updatedRequest = service.approvedRequests[id];
        expect(updatedRequest, isNotNull);
        expect(updatedRequest!.status, OvertimeRequestStatus.approved);
        expect(updatedRequest.approvedBy, 'supervisor-1');
        expect(updatedRequest.approvedAt, isNotNull);
      });
    });

    group('rejectRequest', () {
      test('transitions status from pending to rejected', () async {
        final weekStart = DateTime(2026, 5, 11);
        final id = await service.createRequest(
          userId: 'user-1',
          weekStart: weekStart,
          requestedHours: 4.0,
        );

        await service.rejectRequest(id, rejectedBy: 'supervisor-1');

        final updatedRequest = service.rejectedRequests[id];
        expect(updatedRequest, isNotNull);
        expect(updatedRequest!.status, OvertimeRequestStatus.rejected);
        expect(updatedRequest.rejectedBy, 'supervisor-1');
        expect(updatedRequest.rejectedAt, isNotNull);
      });
    });

    group('getPendingRequests', () {
      test('returns only pending requests', () async {
        final weekStart = DateTime(2026, 5, 11);
        final id1 = await service.createRequest(
          userId: 'user-1',
          weekStart: weekStart,
          requestedHours: 4.0,
        );
        final id2 = await service.createRequest(
          userId: 'user-2',
          weekStart: weekStart,
          requestedHours: 2.0,
        );
        await service.approveRequest(id2, approvedBy: 'supervisor-1');

        final pending = await service.getPendingRequests();
        expect(pending.length, 1);
        expect(pending.first.id, id1);
      });
    });
  });
}

/// Fake implementation of OvertimeService for unit testing
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
  Future<List<OvertimeRequestModel>> getRequestsByUserAndWeek(
    String userId,
    DateTime weekStart,
  ) async {
    final all = [
      ...createdRequests,
      ...approvedRequests.values,
      ...rejectedRequests.values,
    ];
    return all
        .where((r) =>
            r.userId == userId &&
            r.weekStart.year == weekStart.year &&
            r.weekStart.month == weekStart.month &&
            r.weekStart.day == weekStart.day)
        .toList();
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

  @override
  Future<List<OvertimeRequestModel>> getPendingRequests() async {
    final pendingCreated = createdRequests.where((r) => r.isPending).toList();
    return pendingCreated;
  }

  OvertimeRequestModel? _findRequest(String id) {
    for (final r in createdRequests) {
      if (r.id == id) return r;
    }
    return approvedRequests[id] ?? rejectedRequests[id];
  }
}
