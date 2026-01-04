// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
// === Campos básicos obligatorios ===
  String get userId => throw _privateConstructorUsedError;
  String get employeeId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  double get weeklyHours => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // === Información personal (opcional) ===
  String? get dni => throw _privateConstructorUsedError; // DNI/NIE del empleado
  String? get telefono =>
      throw _privateConstructorUsedError; // Teléfono de contacto
// === Información laboral (opcional, desnormalizado) ===
  String? get position =>
      throw _privateConstructorUsedError; // Cargo (ej: "Desarrollador Frontend Senior")
  String? get department =>
      throw _privateConstructorUsedError; // Departamento (ej: "Tecnología", "Docente")
// === Control horario (opcional, híbrido) ===
  String? get scheduleId =>
      throw _privateConstructorUsedError; // Referencia a plantilla de horario (ej: "template_40h_001")
  DateTime? get fechaInicio =>
      throw _privateConstructorUsedError; // Fecha de inicio en la APLICACIÓN (no en la empresa)
  DateTime? get fechaFin =>
      throw _privateConstructorUsedError; // Fecha de fin en la APLICACIÓN (baja/baja temporal)
// DEPRECATED: Mantener por compatibilidad con código existente
  @Deprecated('Usar scheduleId en su lugar')
  String? get schedule => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String userId,
      String employeeId,
      String email,
      String displayName,
      UserRole role,
      double weeklyHours,
      bool isActive,
      DateTime createdAt,
      String? dni,
      String? telefono,
      String? position,
      String? department,
      String? scheduleId,
      DateTime? fechaInicio,
      DateTime? fechaFin,
      @Deprecated('Usar scheduleId en su lugar') String? schedule});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? employeeId = null,
    Object? email = null,
    Object? displayName = null,
    Object? role = null,
    Object? weeklyHours = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? dni = freezed,
    Object? telefono = freezed,
    Object? position = freezed,
    Object? department = freezed,
    Object? scheduleId = freezed,
    Object? fechaInicio = freezed,
    Object? fechaFin = freezed,
    Object? schedule = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      weeklyHours: null == weeklyHours
          ? _value.weeklyHours
          : weeklyHours // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dni: freezed == dni
          ? _value.dni
          : dni // ignore: cast_nullable_to_non_nullable
              as String?,
      telefono: freezed == telefono
          ? _value.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      fechaInicio: freezed == fechaInicio
          ? _value.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaFin: freezed == fechaFin
          ? _value.fechaFin
          : fechaFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      schedule: freezed == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String employeeId,
      String email,
      String displayName,
      UserRole role,
      double weeklyHours,
      bool isActive,
      DateTime createdAt,
      String? dni,
      String? telefono,
      String? position,
      String? department,
      String? scheduleId,
      DateTime? fechaInicio,
      DateTime? fechaFin,
      @Deprecated('Usar scheduleId en su lugar') String? schedule});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? employeeId = null,
    Object? email = null,
    Object? displayName = null,
    Object? role = null,
    Object? weeklyHours = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? dni = freezed,
    Object? telefono = freezed,
    Object? position = freezed,
    Object? department = freezed,
    Object? scheduleId = freezed,
    Object? fechaInicio = freezed,
    Object? fechaFin = freezed,
    Object? schedule = freezed,
  }) {
    return _then(_$UserModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      employeeId: null == employeeId
          ? _value.employeeId
          : employeeId // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      weeklyHours: null == weeklyHours
          ? _value.weeklyHours
          : weeklyHours // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dni: freezed == dni
          ? _value.dni
          : dni // ignore: cast_nullable_to_non_nullable
              as String?,
      telefono: freezed == telefono
          ? _value.telefono
          : telefono // ignore: cast_nullable_to_non_nullable
              as String?,
      position: freezed == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      fechaInicio: freezed == fechaInicio
          ? _value.fechaInicio
          : fechaInicio // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fechaFin: freezed == fechaFin
          ? _value.fechaFin
          : fechaFin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      schedule: freezed == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {required this.userId,
      required this.employeeId,
      required this.email,
      required this.displayName,
      required this.role,
      required this.weeklyHours,
      this.isActive = true,
      required this.createdAt,
      this.dni,
      this.telefono,
      this.position,
      this.department,
      this.scheduleId,
      this.fechaInicio,
      this.fechaFin,
      @Deprecated('Usar scheduleId en su lugar') this.schedule});

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

// === Campos básicos obligatorios ===
  @override
  final String userId;
  @override
  final String employeeId;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final UserRole role;
  @override
  final double weeklyHours;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;
// === Información personal (opcional) ===
  @override
  final String? dni;
// DNI/NIE del empleado
  @override
  final String? telefono;
// Teléfono de contacto
// === Información laboral (opcional, desnormalizado) ===
  @override
  final String? position;
// Cargo (ej: "Desarrollador Frontend Senior")
  @override
  final String? department;
// Departamento (ej: "Tecnología", "Docente")
// === Control horario (opcional, híbrido) ===
  @override
  final String? scheduleId;
// Referencia a plantilla de horario (ej: "template_40h_001")
  @override
  final DateTime? fechaInicio;
// Fecha de inicio en la APLICACIÓN (no en la empresa)
  @override
  final DateTime? fechaFin;
// Fecha de fin en la APLICACIÓN (baja/baja temporal)
// DEPRECATED: Mantener por compatibilidad con código existente
  @override
  @Deprecated('Usar scheduleId en su lugar')
  final String? schedule;

  @override
  String toString() {
    return 'UserModel(userId: $userId, employeeId: $employeeId, email: $email, displayName: $displayName, role: $role, weeklyHours: $weeklyHours, isActive: $isActive, createdAt: $createdAt, dni: $dni, telefono: $telefono, position: $position, department: $department, scheduleId: $scheduleId, fechaInicio: $fechaInicio, fechaFin: $fechaFin, schedule: $schedule)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.weeklyHours, weeklyHours) ||
                other.weeklyHours == weeklyHours) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.dni, dni) || other.dni == dni) &&
            (identical(other.telefono, telefono) ||
                other.telefono == telefono) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.fechaInicio, fechaInicio) ||
                other.fechaInicio == fechaInicio) &&
            (identical(other.fechaFin, fechaFin) ||
                other.fechaFin == fechaFin) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      employeeId,
      email,
      displayName,
      role,
      weeklyHours,
      isActive,
      createdAt,
      dni,
      telefono,
      position,
      department,
      scheduleId,
      fechaInicio,
      fechaFin,
      schedule);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
          {required final String userId,
          required final String employeeId,
          required final String email,
          required final String displayName,
          required final UserRole role,
          required final double weeklyHours,
          final bool isActive,
          required final DateTime createdAt,
          final String? dni,
          final String? telefono,
          final String? position,
          final String? department,
          final String? scheduleId,
          final DateTime? fechaInicio,
          final DateTime? fechaFin,
          @Deprecated('Usar scheduleId en su lugar') final String? schedule}) =
      _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

// === Campos básicos obligatorios ===
  @override
  String get userId;
  @override
  String get employeeId;
  @override
  String get email;
  @override
  String get displayName;
  @override
  UserRole get role;
  @override
  double get weeklyHours;
  @override
  bool get isActive;
  @override
  DateTime get createdAt; // === Información personal (opcional) ===
  @override
  String? get dni; // DNI/NIE del empleado
  @override
  String? get telefono; // Teléfono de contacto
// === Información laboral (opcional, desnormalizado) ===
  @override
  String? get position; // Cargo (ej: "Desarrollador Frontend Senior")
  @override
  String? get department; // Departamento (ej: "Tecnología", "Docente")
// === Control horario (opcional, híbrido) ===
  @override
  String?
      get scheduleId; // Referencia a plantilla de horario (ej: "template_40h_001")
  @override
  DateTime?
      get fechaInicio; // Fecha de inicio en la APLICACIÓN (no en la empresa)
  @override
  DateTime? get fechaFin; // Fecha de fin en la APLICACIÓN (baja/baja temporal)
// DEPRECATED: Mantener por compatibilidad con código existente
  @override
  @Deprecated('Usar scheduleId en su lugar')
  String? get schedule;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
