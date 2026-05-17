import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'anomaly_model.freezed.dart';
part 'anomaly_model.g.dart';

/// Modelo de Anomalía detectada en registros de tiempo
///
/// Representa una irregularidad encontrada por el sistema de detección:
/// salidas faltantes, horas insuficientes, ausencias no justificadas,
/// solapamiento de registros y pausas excesivas.
@freezed
class AnomalyModel with _$AnomalyModel {
  // ignore: unused_element
  const AnomalyModel._();

  const factory AnomalyModel({
    required String id,
    required String userId,
    required String date, // "2026-05-16"
    required AnomalyType type,
    required AnomalySeverity severity,
    required DateTime createdAt,
    String? description,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) = _AnomalyModel;

  factory AnomalyModel.fromJson(Map<String, dynamic> json) =>
      _$AnomalyModelFromJson(json);

  /// Crear AnomalyModel desde documento de Firestore
  factory AnomalyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AnomalyModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      type: _parseAnomalyType(data['type']),
      severity: _parseSeverity(data['severity']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] as String?,
      resolvedBy: data['resolvedBy'] as String?,
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Serializar a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': date,
      'type': type.name,
      'severity': severity.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (description != null) 'description': description,
      if (resolvedBy != null) 'resolvedBy': resolvedBy,
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
    };
  }

  static AnomalyType _parseAnomalyType(dynamic value) {
    try {
      return AnomalyType.values.byName(value as String);
    } catch (_) {
      return AnomalyType.missingExit;
    }
  }

  static AnomalySeverity _parseSeverity(dynamic value) {
    try {
      return AnomalySeverity.values.byName(value as String);
    } catch (_) {
      return AnomalySeverity.medium;
    }
  }
}

/// Tipos de anomalía detectables
enum AnomalyType {
  /// El empleado fichó entrada pero no tiene salida registrada
  missingExit,

  /// Las horas trabajadas son inferiores a las esperadas
  insufficientHours,

  /// Día laborable sin ningún registro de fichaje
  unexcusedAbsence,

  /// Dos o más registros de trabajo se solapan en el tiempo
  overlap,

  /// La pausa excede el tiempo máximo permitido
  excessiveBreak,
}

/// Nivel de severidad de una anomalía
enum AnomalySeverity {
  /// Leve — desviación menor, no requiere acción inmediata
  low,

  /// Media — requiere atención del supervisor
  medium,

  /// Alta — desviación grave, requiere acción inmediata
  high,
}
