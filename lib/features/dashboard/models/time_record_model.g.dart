// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimeRecordModelImpl _$$TimeRecordModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TimeRecordModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: json['date'] as String,
      category: $enumDecode(_$RecordCategoryEnumMap, json['category']),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      isManual: json['isManual'] as bool,
      copiedFrom: json['copiedFrom'] as String?,
      recordStatus:
          $enumDecodeNullable(_$RecordStatusEnumMap, json['recordStatus']) ??
              RecordStatus.active,
      validationStatus: $enumDecodeNullable(
              _$ValidationStatusEnumMap, json['validationStatus']) ??
          ValidationStatus.editable,
      validatedBy: json['validatedBy'] as String?,
      validatedAt: json['validatedAt'] == null
          ? null
          : DateTime.parse(json['validatedAt'] as String),
      blockedBy: json['blockedBy'] as String?,
      blockedAt: json['blockedAt'] == null
          ? null
          : DateTime.parse(json['blockedAt'] as String),
      blockReason: json['blockReason'] as String?,
    );

Map<String, dynamic> _$$TimeRecordModelImplToJson(
        _$TimeRecordModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date,
      'category': _$RecordCategoryEnumMap[instance.category]!,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'location': instance.location,
      'durationMinutes': instance.durationMinutes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'isManual': instance.isManual,
      'copiedFrom': instance.copiedFrom,
      'recordStatus': _$RecordStatusEnumMap[instance.recordStatus]!,
      'validationStatus': _$ValidationStatusEnumMap[instance.validationStatus]!,
      'validatedBy': instance.validatedBy,
      'validatedAt': instance.validatedAt?.toIso8601String(),
      'blockedBy': instance.blockedBy,
      'blockedAt': instance.blockedAt?.toIso8601String(),
      'blockReason': instance.blockReason,
    };

const _$RecordCategoryEnumMap = {
  RecordCategory.work: 'work',
  RecordCategory.breakTime: 'breakTime',
};

const _$RecordStatusEnumMap = {
  RecordStatus.active: 'active',
  RecordStatus.completed: 'completed',
};

const _$ValidationStatusEnumMap = {
  ValidationStatus.editable: 'editable',
  ValidationStatus.validated: 'validated',
  ValidationStatus.blocked: 'blocked',
  ValidationStatus.modifiedAfterValidation: 'modifiedAfterValidation',
};
