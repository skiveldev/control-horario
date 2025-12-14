import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'time_record_model.freezed.dart';
part 'time_record_model.g.dart';

/// Modelo de Registro Individual de Tiempo
///
/// Representa un registro individual de trabajo o pausa dentro de un día.
/// Incluye sistema de validación/bloqueo para control por admin.
@freezed
class TimeRecordModel with _$TimeRecordModel {
  const factory TimeRecordModel({
    required String id,
    required String userId,
    required String date, // "2025-12-01"
    required RecordCategory category,
    required String startTime, // "07:30"
    required String endTime, // "14:00"
    required String location,
    required int durationMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
    required bool isManual,
    String? copiedFrom,
    // Campos de validación
    @Default(ValidationStatus.editable) ValidationStatus validationStatus,
    String? validatedBy,
    DateTime? validatedAt,
    String? blockedBy,
    DateTime? blockedAt,
    String? blockReason,
  }) = _TimeRecordModel;

  factory TimeRecordModel.fromJson(Map<String, dynamic> json) =>
      _$TimeRecordModelFromJson(json);

  /// Crear TimeRecordModel desde documento de Firestore
  factory TimeRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TimeRecordModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      category: data['category'] == 'break'
          ? RecordCategory.breakTime
          : RecordCategory.work,
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      location: data['location'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      isManual: data['isManual'] ?? false,
      copiedFrom: data['copiedFrom'],
      validationStatus: _parseValidationStatus(data['validationStatus']),
      validatedBy: data['validatedBy'],
      validatedAt: (data['validatedAt'] as Timestamp?)?.toDate(),
      blockedBy: data['blockedBy'],
      blockedAt: (data['blockedAt'] as Timestamp?)?.toDate(),
      blockReason: data['blockReason'],
    );
  }

  /// Convertir a Map para Firestore
  static Map<String, dynamic> toFirestore(TimeRecordModel record) {
    return {
      'userId': record.userId,
      'date': record.date,
      'category': record.category.name,
      'startTime': record.startTime,
      'endTime': record.endTime,
      'location': record.location,
      'durationMinutes': record.durationMinutes,
      'createdAt': Timestamp.fromDate(record.createdAt),
      'updatedAt': Timestamp.fromDate(record.updatedAt),
      'createdBy': record.createdBy,
      'isManual': record.isManual,
      if (record.copiedFrom != null) 'copiedFrom': record.copiedFrom,
      'validationStatus': record.validationStatus.name,
      if (record.validatedBy != null) 'validatedBy': record.validatedBy,
      if (record.validatedAt != null)
        'validatedAt': Timestamp.fromDate(record.validatedAt!),
      if (record.blockedBy != null) 'blockedBy': record.blockedBy,
      if (record.blockedAt != null)
        'blockedAt': Timestamp.fromDate(record.blockedAt!),
      if (record.blockReason != null) 'blockReason': record.blockReason,
    };
  }

  static ValidationStatus _parseValidationStatus(dynamic status) {
    if (status == null) return ValidationStatus.editable;
    try {
      return ValidationStatus.values.byName(status);
    } catch (e) {
      return ValidationStatus.editable;
    }
  }
}

/// Categoría de registro
enum RecordCategory {
  work,
  breakTime,
}

/// Estado de validación del registro
enum ValidationStatus {
  /// Editable (default) - Empleado puede modificar libremente
  editable,

  /// Validado por Admin - Empleado puede editar pero queda marcado como modificado
  validated,

  /// Bloqueado por Admin - Empleado NO puede editar
  blocked,

  /// Modificado después de validación
  modifiedAfterValidation,
}

/// Extensión para TimeRecordModel
extension TimeRecordModelX on TimeRecordModel {
  /// Si el registro puede ser editado por el empleado
  bool get canEdit => validationStatus != ValidationStatus.blocked;

  /// Si el registro puede ser eliminado por el empleado
  bool get canDelete => validationStatus != ValidationStatus.blocked;

  /// Si el registro está validado
  bool get isValidated =>
      validationStatus == ValidationStatus.validated ||
      validationStatus == ValidationStatus.modifiedAfterValidation;

  /// Si el registro está bloqueado
  bool get isBlocked => validationStatus == ValidationStatus.blocked;

  /// Obtener el nombre de la categoría en español
  String get categoryName =>
      category == RecordCategory.work ? 'Trabajo' : 'Pausa';
}
