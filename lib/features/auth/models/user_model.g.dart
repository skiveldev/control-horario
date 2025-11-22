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
      weeklyHours: (json['weeklyHours'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'employeeId': instance.employeeId,
      'email': instance.email,
      'displayName': instance.displayName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'weeklyHours': instance.weeklyHours,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.employee: 'employee',
  UserRole.rrhh: 'rrhh',
  UserRole.admin: 'admin',
};
