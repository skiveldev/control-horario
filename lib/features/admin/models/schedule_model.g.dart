// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleModelImpl _$$ScheduleModelImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleModelImpl(
      scheduleId: json['scheduleId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      totalWeeklyHours: (json['totalWeeklyHours'] as num).toInt(),
      isActive: json['isActive'] as bool? ?? true,
      isTemplate: json['isTemplate'] as bool? ?? true,
      usedByCount: (json['usedByCount'] as num?)?.toInt() ?? 0,
      weeklySchedule: (json['weeklySchedule'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, DaySchedule.fromJson(e as Map<String, dynamic>)),
      ),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String?,
      lastModifiedAt: json['lastModifiedAt'] == null
          ? null
          : DateTime.parse(json['lastModifiedAt'] as String),
      lastModifiedBy: json['lastModifiedBy'] as String?,
    );

Map<String, dynamic> _$$ScheduleModelImplToJson(_$ScheduleModelImpl instance) =>
    <String, dynamic>{
      'scheduleId': instance.scheduleId,
      'name': instance.name,
      'description': instance.description,
      'totalWeeklyHours': instance.totalWeeklyHours,
      'isActive': instance.isActive,
      'isTemplate': instance.isTemplate,
      'usedByCount': instance.usedByCount,
      'weeklySchedule': instance.weeklySchedule,
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'lastModifiedAt': instance.lastModifiedAt?.toIso8601String(),
      'lastModifiedBy': instance.lastModifiedBy,
    };

_$DayScheduleImpl _$$DayScheduleImplFromJson(Map<String, dynamic> json) =>
    _$DayScheduleImpl(
      isWorkDay: json['isWorkDay'] as bool? ?? false,
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((e) => TimeShift.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 0,
      dailyHours: (json['dailyHours'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$DayScheduleImplToJson(_$DayScheduleImpl instance) =>
    <String, dynamic>{
      'isWorkDay': instance.isWorkDay,
      'shifts': instance.shifts,
      'breakMinutes': instance.breakMinutes,
      'dailyHours': instance.dailyHours,
    };

_$TimeShiftImpl _$$TimeShiftImplFromJson(Map<String, dynamic> json) =>
    _$TimeShiftImpl(
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );

Map<String, dynamic> _$$TimeShiftImplToJson(_$TimeShiftImpl instance) =>
    <String, dynamic>{
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };
