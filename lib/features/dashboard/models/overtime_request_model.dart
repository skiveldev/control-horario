import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'overtime_request_model.freezed.dart';
part 'overtime_request_model.g.dart';

/// Modelo de Solicitud de Horas Extra
///
/// Representa una solicitud generada automáticamente cuando las horas
/// trabajadas en una semana superan las horas semanales contratadas.
/// Requiere aprobación o rechazo por parte del supervisor.
@freezed
class OvertimeRequestModel with _$OvertimeRequestModel {
  // ignore: unused_element
  const OvertimeRequestModel._();

  const factory OvertimeRequestModel({
    required String id,
    required String userId,
    required DateTime weekStart, // Lunes 00:00:00 de la semana
    required double requestedHours, // Horas extra detectadas
    required OvertimeRequestStatus status,
    required DateTime createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? rejectedAt,
    String? rejectedBy,
  }) = _OvertimeRequestModel;

  factory OvertimeRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OvertimeRequestModelFromJson(json);

  /// Crear OvertimeRequestModel desde documento de Firestore
  factory OvertimeRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OvertimeRequestModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      weekStart: (data['weekStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      requestedHours: (data['requestedHours'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      approvedBy: data['approvedBy'] as String?,
      rejectedAt: (data['rejectedAt'] as Timestamp?)?.toDate(),
      rejectedBy: data['rejectedBy'] as String?,
    );
  }

  /// Serializar a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'weekStart': Timestamp.fromDate(weekStart),
      'requestedHours': requestedHours,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (approvedAt != null) 'approvedAt': Timestamp.fromDate(approvedAt!),
      if (approvedBy != null) 'approvedBy': approvedBy,
      if (rejectedAt != null) 'rejectedAt': Timestamp.fromDate(rejectedAt!),
      if (rejectedBy != null) 'rejectedBy': rejectedBy,
    };
  }

  /// Si la solicitud está pendiente de revisión
  bool get isPending => status == OvertimeRequestStatus.pending;

  /// Si la solicitud fue aprobada
  bool get isApproved => status == OvertimeRequestStatus.approved;

  /// Si la solicitud fue rechazada
  bool get isRejected => status == OvertimeRequestStatus.rejected;

  static OvertimeRequestStatus _parseStatus(dynamic status) {
    try {
      return OvertimeRequestStatus.values.byName(status as String);
    } catch (_) {
      return OvertimeRequestStatus.pending;
    }
  }
}

/// Estado de una solicitud de horas extra
enum OvertimeRequestStatus {
  /// Pendiente de revisión por el supervisor
  pending,

  /// Aprobada por el supervisor
  approved,

  /// Rechazada por el supervisor
  rejected,
}
