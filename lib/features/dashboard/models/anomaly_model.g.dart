// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anomaly_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnomalyModelImpl _$$AnomalyModelImplFromJson(Map<String, dynamic> json) =>
    _$AnomalyModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: json['date'] as String,
      type: $enumDecode(_$AnomalyTypeEnumMap, json['type']),
      severity: $enumDecode(_$AnomalySeverityEnumMap, json['severity']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$$AnomalyModelImplToJson(_$AnomalyModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date,
      'type': _$AnomalyTypeEnumMap[instance.type]!,
      'severity': _$AnomalySeverityEnumMap[instance.severity]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
      'resolvedBy': instance.resolvedBy,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

const _$AnomalyTypeEnumMap = {
  AnomalyType.missingExit: 'missingExit',
  AnomalyType.insufficientHours: 'insufficientHours',
  AnomalyType.unexcusedAbsence: 'unexcusedAbsence',
  AnomalyType.overlap: 'overlap',
  AnomalyType.excessiveBreak: 'excessiveBreak',
};

const _$AnomalySeverityEnumMap = {
  AnomalySeverity.low: 'low',
  AnomalySeverity.medium: 'medium',
  AnomalySeverity.high: 'high',
};
