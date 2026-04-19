// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      userId: json['userId'] as String,
      employeeId: json['employeeId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      isSupervisor: json['isSupervisor'] as bool? ?? false,
      supervisorId: json['supervisorId'] as String?,
      weeklyHours: (json['weeklyHours'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      nombre: json['nombre'] as String?,
      apellido1: json['apellido1'] as String?,
      apellido2: json['apellido2'] as String?,
      dni: json['dni'] as String?,
      telefono: json['telefono'] as String?,
      position: json['position'] as String?,
      department: json['department'] as String?,
      empresa: json['empresa'] as String?,
      scheduleId: json['scheduleId'] as String?,
      scheduleType: json['scheduleType'] as String? ?? 'template',
      customSchedule: json['customSchedule'] as Map<String, dynamic>?,
      calendarId: json['calendarId'] as String?,
      fechaInicio: json['fechaInicio'] == null
          ? null
          : DateTime.parse(json['fechaInicio'] as String),
      fechaFin: json['fechaFin'] == null
          ? null
          : DateTime.parse(json['fechaFin'] as String),
      schedule: json['schedule'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'employeeId': instance.employeeId,
      'email': instance.email,
      'displayName': instance.displayName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'isSupervisor': instance.isSupervisor,
      'supervisorId': instance.supervisorId,
      'weeklyHours': instance.weeklyHours,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'nombre': instance.nombre,
      'apellido1': instance.apellido1,
      'apellido2': instance.apellido2,
      'dni': instance.dni,
      'telefono': instance.telefono,
      'position': instance.position,
      'department': instance.department,
      'empresa': instance.empresa,
      'scheduleId': instance.scheduleId,
      'scheduleType': instance.scheduleType,
      'customSchedule': instance.customSchedule,
      'calendarId': instance.calendarId,
      'fechaInicio': instance.fechaInicio?.toIso8601String(),
      'fechaFin': instance.fechaFin?.toIso8601String(),
      'schedule': instance.schedule,
    };

const _$UserRoleEnumMap = {
  UserRole.employee: 'employee',
  UserRole.rrhh: 'rrhh',
  UserRole.admin: 'admin',
};
