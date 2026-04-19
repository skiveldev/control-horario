import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'team_provider.dart';

class TeamMonthClosure {
  final String id;
  final String supervisorId;
  final String month;
  final String status;
  final DateTime? closedAt;
  final String? closedBy;
  final int teamMembers;
  final int totalRecords;

  const TeamMonthClosure({
    required this.id,
    required this.supervisorId,
    required this.month,
    required this.status,
    required this.closedAt,
    required this.closedBy,
    required this.teamMembers,
    required this.totalRecords,
  });

  bool get isClosed => status == 'closed';

  factory TeamMonthClosure.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TeamMonthClosure(
      id: doc.id,
      supervisorId: data['supervisorId'] as String? ?? '',
      month: data['month'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      closedAt: (data['closedAt'] as Timestamp?)?.toDate(),
      closedBy: data['closedBy'] as String?,
      teamMembers: (data['teamSnapshot']?['teamMembers'] as num?)?.toInt() ?? 0,
      totalRecords:
          (data['teamSnapshot']?['totalRecords'] as num?)?.toInt() ?? 0,
    );
  }
}

final teamMonthClosureProvider =
    FutureProvider.family<TeamMonthClosure?, DateTime>((ref, month) async {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  if (currentUser == null || !currentUser.canSuperviseTeam) return null;

  final firestore = ref.watch(firestoreProvider);
  final monthKey = _monthKey(month);
  final closureId = '${currentUser.userId}_$monthKey';
  final doc =
      await firestore.collection('team_month_closures').doc(closureId).get();

  if (!doc.exists) return null;
  return TeamMonthClosure.fromFirestore(doc);
});

final teamMonthClosureControllerProvider =
    Provider<TeamMonthClosureController>((ref) {
  return TeamMonthClosureController(ref);
});

class TeamMonthClosureWriteRequest {
  final String closureId;
  final String supervisorId;
  final String month;
  final String closedBy;
  final int teamMembers;
  final int totalRecords;
  final int pendingRecords;

  const TeamMonthClosureWriteRequest({
    required this.closureId,
    required this.supervisorId,
    required this.month,
    required this.closedBy,
    required this.teamMembers,
    required this.totalRecords,
    required this.pendingRecords,
  });
}

abstract class TeamMonthClosureWriter {
  Future<void> saveClosedMonth(TeamMonthClosureWriteRequest request);
}

class FirestoreTeamMonthClosureWriter implements TeamMonthClosureWriter {
  final FirebaseFirestore _firestore;

  FirestoreTeamMonthClosureWriter(this._firestore);

  @override
  Future<void> saveClosedMonth(TeamMonthClosureWriteRequest request) {
    return _firestore
        .collection('team_month_closures')
        .doc(request.closureId)
        .set(
          buildClosedMonthPayload(request),
          SetOptions(merge: true),
        );
  }
}

final teamMonthClosureWriterProvider = Provider<TeamMonthClosureWriter>((ref) {
  return FirestoreTeamMonthClosureWriter(ref.watch(firestoreProvider));
});

class TeamMonthClosureController {
  final Ref _ref;

  TeamMonthClosureController(this._ref);

  Future<void> closeMonth(DateTime month) async {
    final currentUser = _ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null ||
        !currentUser.isActive ||
        !currentUser.isSupervisor) {
      throw Exception('Sin permisos para cerrar mes de equipo');
    }

    final monthKey = _monthKey(month);
    final closureId = '${currentUser.userId}_$monthKey';

    final existingClosure =
        await _ref.read(teamMonthClosureProvider(month).future);
    if (existingClosure?.isClosed == true) {
      throw Exception('Este mes ya está cerrado');
    }

    final monthlyOverview =
        await _ref.read(teamMonthlyOverviewProvider(month).future);
    final pendingTotal = monthlyOverview.pendingRecords;
    if (pendingTotal > 0) {
      throw Exception(
          'No se puede cerrar el mes: hay $pendingTotal registros pendientes');
    }

    await _ref.read(teamMonthClosureWriterProvider).saveClosedMonth(
          TeamMonthClosureWriteRequest(
            closureId: closureId,
            supervisorId: currentUser.userId,
            month: monthKey,
            closedBy: currentUser.userId,
            teamMembers: monthlyOverview.membersCount,
            totalRecords: monthlyOverview.totalRecords,
            pendingRecords: 0,
          ),
        );

    _ref.invalidate(teamMonthClosureProvider(month));
    _ref.invalidate(teamMonthlyOverviewProvider(month));
    _ref.invalidate(teamMonthlySummaryProvider(month));
  }
}

String _monthKey(DateTime month) {
  return '${month.year}-${month.month.toString().padLeft(2, '0')}';
}

Map<String, dynamic> buildClosedMonthPayload(
  TeamMonthClosureWriteRequest request, {
  Object? closedAt,
  Object? updatedAt,
}) {
  return {
    'supervisorId': request.supervisorId,
    'month': request.month,
    'status': 'closed',
    'closedAt': closedAt ?? FieldValue.serverTimestamp(),
    'closedBy': request.closedBy,
    'teamSnapshot': {
      'teamMembers': request.teamMembers,
      'totalRecords': request.totalRecords,
      'pendingRecords': request.pendingRecords,
    },
    'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
  };
}
