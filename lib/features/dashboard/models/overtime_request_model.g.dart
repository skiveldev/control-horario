// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OvertimeRequestModelImpl _$$OvertimeRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$OvertimeRequestModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      requestedHours: (json['requestedHours'] as num).toDouble(),
      status: $enumDecode(_$OvertimeRequestStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      rejectedAt: json['rejectedAt'] == null
          ? null
          : DateTime.parse(json['rejectedAt'] as String),
      rejectedBy: json['rejectedBy'] as String?,
    );

Map<String, dynamic> _$$OvertimeRequestModelImplToJson(
        _$OvertimeRequestModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'weekStart': instance.weekStart.toIso8601String(),
      'requestedHours': instance.requestedHours,
      'status': _$OvertimeRequestStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'approvedBy': instance.approvedBy,
      'rejectedAt': instance.rejectedAt?.toIso8601String(),
      'rejectedBy': instance.rejectedBy,
    };

const _$OvertimeRequestStatusEnumMap = {
  OvertimeRequestStatus.pending: 'pending',
  OvertimeRequestStatus.approved: 'approved',
  OvertimeRequestStatus.rejected: 'rejected',
};
