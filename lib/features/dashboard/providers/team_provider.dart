import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/time_record_model.dart';

const int teamRecordsBatchSize = 10;

/// Miembros del equipo para el supervisor autenticado.
///
/// Retorna lista vacia si el usuario no tiene permiso de supervision.
final supervisedTeamMembersProvider = StreamProvider<List<UserModel>>((ref) {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;

  if (currentUser == null || !currentUser.canSuperviseTeam) {
    return Stream.value(const <UserModel>[]);
  }

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .where('supervisorId', isEqualTo: currentUser.userId)
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    final members = snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    return members;
  });
});

/// Resumen mensual de fichajes de un miembro del equipo.
class TeamMemberMonthlySummary {
  final UserModel member;
  final int totalRecords;
  final int validatedRecords;
  final int pendingRecords;
  final List<TimeRecordModel> monthlyRecords;
  final List<TimeRecordModel> pendingRecordItems;

  const TeamMemberMonthlySummary({
    required this.member,
    required this.totalRecords,
    required this.validatedRecords,
    required this.pendingRecords,
    required this.monthlyRecords,
    required this.pendingRecordItems,
  });

  String get statusLabel {
    if (totalRecords == 0) return 'Sin registros';
    if (pendingRecords == 0) return 'Validado';
    if (validatedRecords == 0) return 'Pendiente';
    return 'Parcial';
  }
}

class TeamPendingBreakdownItem {
  final UserModel member;
  final int pendingRecords;

  const TeamPendingBreakdownItem({
    required this.member,
    required this.pendingRecords,
  });
}

class TeamMonthlyOverview {
  final List<TeamMemberMonthlySummary> memberSummaries;

  const TeamMonthlyOverview({
    required this.memberSummaries,
  });

  int get membersCount => memberSummaries.length;
  int get totalRecords =>
      memberSummaries.fold(0, (total, item) => total + item.totalRecords);
  int get validatedRecords =>
      memberSummaries.fold(0, (total, item) => total + item.validatedRecords);
  int get pendingRecords =>
      memberSummaries.fold(0, (total, item) => total + item.pendingRecords);
  int get membersWithPending =>
      memberSummaries.where((item) => item.pendingRecords > 0).length;
  int get membersWithoutRecords =>
      memberSummaries.where((item) => item.totalRecords == 0).length;

  List<TeamPendingBreakdownItem> get pendingBreakdown {
    final items = memberSummaries
        .where((item) => item.pendingRecords > 0)
        .map(
          (item) => TeamPendingBreakdownItem(
            member: item.member,
            pendingRecords: item.pendingRecords,
          ),
        )
        .toList();

    items.sort((a, b) => b.pendingRecords.compareTo(a.pendingRecords));
    return items;
  }
}

List<List<String>> buildTeamRecordQueryBatches(
  Iterable<String> userIds, {
  int batchSize = teamRecordsBatchSize,
}) {
  final normalizedIds = <String>[];
  final seenIds = <String>{};

  for (final userId in userIds) {
    final normalized = userId.trim();
    if (normalized.isEmpty || !seenIds.add(normalized)) continue;
    normalizedIds.add(normalized);
  }

  if (normalizedIds.isEmpty) return const <List<String>>[];

  final batches = <List<String>>[];
  for (var index = 0; index < normalizedIds.length; index += batchSize) {
    final end = (index + batchSize < normalizedIds.length)
        ? index + batchSize
        : normalizedIds.length;
    batches.add(normalizedIds.sublist(index, end));
  }
  return batches;
}

TeamMonthlyOverview buildTeamMonthlyOverviewFromRecords({
  required List<UserModel> members,
  required List<TimeRecordModel> monthlyRecords,
}) {
  final recordsByUser = <String, List<TimeRecordModel>>{};
  for (final record in monthlyRecords) {
    recordsByUser.putIfAbsent(record.userId, () => <TimeRecordModel>[]).add(
          record,
        );
  }

  final summaries = members.map((member) {
    final records =
        List<TimeRecordModel>.from(recordsByUser[member.userId] ?? [])
          ..sort(_sortRecords);

    final validatedRecords = records
        .where(
            (record) => record.validationStatus == ValidationStatus.validated)
        .length;
    final pendingRecordItems = records
        .where(
            (record) => record.validationStatus != ValidationStatus.validated)
        .toList();

    return TeamMemberMonthlySummary(
      member: member,
      totalRecords: records.length,
      validatedRecords: validatedRecords,
      pendingRecords: pendingRecordItems.length,
      monthlyRecords: records,
      pendingRecordItems: pendingRecordItems,
    );
  }).toList()
    ..sort((a, b) => a.member.fullName.compareTo(b.member.fullName));

  return TeamMonthlyOverview(memberSummaries: summaries);
}

/// Resumen agregado del equipo del supervisor autenticado.
final teamMonthlyOverviewProvider =
    FutureProvider.family<TeamMonthlyOverview, DateTime>((ref, month) async {
  final teamMembers = await ref.watch(supervisedTeamMembersProvider.future);
  if (teamMembers.isEmpty) {
    return const TeamMonthlyOverview(
        memberSummaries: <TeamMemberMonthlySummary>[]);
  }

  final firestore = ref.watch(firestoreProvider);
  final startDate =
      '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
  final endDate = _formatMonthEndDate(month);
  final queryBatches =
      buildTeamRecordQueryBatches(teamMembers.map((member) => member.userId));
  final snapshots = await Future.wait(
    queryBatches.map(
      (userIdsBatch) => firestore
          .collectionGroup('time_records')
          .where('userId', whereIn: userIdsBatch)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get(),
    ),
  );

  final allRecords = snapshots
      .expand(
        (snapshot) =>
            snapshot.docs.map((doc) => TimeRecordModel.fromFirestore(doc)),
      )
      .toList();

  return buildTeamMonthlyOverviewFromRecords(
    members: teamMembers,
    monthlyRecords: allRecords,
  );
});

/// Resumen mensual por miembro para compatibilidad con consumidores existentes.
final teamMonthlySummaryProvider =
    FutureProvider.family<List<TeamMemberMonthlySummary>, DateTime>(
        (ref, month) async {
  final overview = await ref.watch(teamMonthlyOverviewProvider(month).future);
  return overview.memberSummaries;
});

String _formatMonthEndDate(DateTime month) {
  final endDate = DateTime(month.year, month.month + 1, 0);
  return '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
}

int _sortRecords(TimeRecordModel a, TimeRecordModel b) {
  final dateComparison = a.date.compareTo(b.date);
  if (dateComparison != 0) return dateComparison;
  return a.startTime.compareTo(b.startTime);
}
