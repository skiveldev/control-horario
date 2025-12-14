// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyRecordModelImpl _$$DailyRecordModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyRecordModelImpl(
      date: json['date'] as String,
      userId: json['userId'] as String,
      clocks: ClockTimes.fromJson(json['clocks'] as Map<String, dynamic>),
      clockInTimestamp: json['clockInTimestamp'] == null
          ? null
          : DateTime.parse(json['clockInTimestamp'] as String),
      clockOutTimestamp: json['clockOutTimestamp'] == null
          ? null
          : DateTime.parse(json['clockOutTimestamp'] as String),
      status: $enumDecode(_$RecordStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DailyRecordModelImplToJson(
        _$DailyRecordModelImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'userId': instance.userId,
      'clocks': instance.clocks,
      'clockInTimestamp': instance.clockInTimestamp?.toIso8601String(),
      'clockOutTimestamp': instance.clockOutTimestamp?.toIso8601String(),
      'status': _$RecordStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$RecordStatusEnumMap = {
  RecordStatus.incomplete: 'incomplete',
  RecordStatus.complete: 'complete',
};

_$ClockTimesImpl _$$ClockTimesImplFromJson(Map<String, dynamic> json) =>
    _$ClockTimesImpl(
      clockIn: json['clockIn'] as String?,
      clockOut: json['clockOut'] as String?,
    );

Map<String, dynamic> _$$ClockTimesImplToJson(_$ClockTimesImpl instance) =>
    <String, dynamic>{
      'clockIn': instance.clockIn,
      'clockOut': instance.clockOut,
    };
