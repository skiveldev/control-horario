// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'overtime_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OvertimeRequestModel _$OvertimeRequestModelFromJson(Map<String, dynamic> json) {
  return _OvertimeRequestModel.fromJson(json);
}

/// @nodoc
mixin _$OvertimeRequestModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get weekStart =>
      throw _privateConstructorUsedError; // Lunes 00:00:00 de la semana
  double get requestedHours =>
      throw _privateConstructorUsedError; // Horas extra detectadas
  OvertimeRequestStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get approvedAt => throw _privateConstructorUsedError;
  String? get approvedBy => throw _privateConstructorUsedError;
  DateTime? get rejectedAt => throw _privateConstructorUsedError;
  String? get rejectedBy => throw _privateConstructorUsedError;

  /// Serializes this OvertimeRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OvertimeRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OvertimeRequestModelCopyWith<OvertimeRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OvertimeRequestModelCopyWith<$Res> {
  factory $OvertimeRequestModelCopyWith(OvertimeRequestModel value,
          $Res Function(OvertimeRequestModel) then) =
      _$OvertimeRequestModelCopyWithImpl<$Res, OvertimeRequestModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime weekStart,
      double requestedHours,
      OvertimeRequestStatus status,
      DateTime createdAt,
      DateTime? approvedAt,
      String? approvedBy,
      DateTime? rejectedAt,
      String? rejectedBy});
}

/// @nodoc
class _$OvertimeRequestModelCopyWithImpl<$Res,
        $Val extends OvertimeRequestModel>
    implements $OvertimeRequestModelCopyWith<$Res> {
  _$OvertimeRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OvertimeRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weekStart = null,
    Object? requestedHours = null,
    Object? status = null,
    Object? createdAt = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? rejectedAt = freezed,
    Object? rejectedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requestedHours: null == requestedHours
          ? _value.requestedHours
          : requestedHours // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OvertimeRequestStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectedAt: freezed == rejectedAt
          ? _value.rejectedAt
          : rejectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rejectedBy: freezed == rejectedBy
          ? _value.rejectedBy
          : rejectedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OvertimeRequestModelImplCopyWith<$Res>
    implements $OvertimeRequestModelCopyWith<$Res> {
  factory _$$OvertimeRequestModelImplCopyWith(_$OvertimeRequestModelImpl value,
          $Res Function(_$OvertimeRequestModelImpl) then) =
      __$$OvertimeRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime weekStart,
      double requestedHours,
      OvertimeRequestStatus status,
      DateTime createdAt,
      DateTime? approvedAt,
      String? approvedBy,
      DateTime? rejectedAt,
      String? rejectedBy});
}

/// @nodoc
class __$$OvertimeRequestModelImplCopyWithImpl<$Res>
    extends _$OvertimeRequestModelCopyWithImpl<$Res, _$OvertimeRequestModelImpl>
    implements _$$OvertimeRequestModelImplCopyWith<$Res> {
  __$$OvertimeRequestModelImplCopyWithImpl(_$OvertimeRequestModelImpl _value,
      $Res Function(_$OvertimeRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OvertimeRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weekStart = null,
    Object? requestedHours = null,
    Object? status = null,
    Object? createdAt = null,
    Object? approvedAt = freezed,
    Object? approvedBy = freezed,
    Object? rejectedAt = freezed,
    Object? rejectedBy = freezed,
  }) {
    return _then(_$OvertimeRequestModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weekStart: null == weekStart
          ? _value.weekStart
          : weekStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      requestedHours: null == requestedHours
          ? _value.requestedHours
          : requestedHours // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OvertimeRequestStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      approvedAt: freezed == approvedAt
          ? _value.approvedAt
          : approvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      approvedBy: freezed == approvedBy
          ? _value.approvedBy
          : approvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      rejectedAt: freezed == rejectedAt
          ? _value.rejectedAt
          : rejectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rejectedBy: freezed == rejectedBy
          ? _value.rejectedBy
          : rejectedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OvertimeRequestModelImpl extends _OvertimeRequestModel {
  const _$OvertimeRequestModelImpl(
      {required this.id,
      required this.userId,
      required this.weekStart,
      required this.requestedHours,
      required this.status,
      required this.createdAt,
      this.approvedAt,
      this.approvedBy,
      this.rejectedAt,
      this.rejectedBy})
      : super._();

  factory _$OvertimeRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OvertimeRequestModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime weekStart;
// Lunes 00:00:00 de la semana
  @override
  final double requestedHours;
// Horas extra detectadas
  @override
  final OvertimeRequestStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? approvedAt;
  @override
  final String? approvedBy;
  @override
  final DateTime? rejectedAt;
  @override
  final String? rejectedBy;

  @override
  String toString() {
    return 'OvertimeRequestModel(id: $id, userId: $userId, weekStart: $weekStart, requestedHours: $requestedHours, status: $status, createdAt: $createdAt, approvedAt: $approvedAt, approvedBy: $approvedBy, rejectedAt: $rejectedAt, rejectedBy: $rejectedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OvertimeRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.weekStart, weekStart) ||
                other.weekStart == weekStart) &&
            (identical(other.requestedHours, requestedHours) ||
                other.requestedHours == requestedHours) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.approvedAt, approvedAt) ||
                other.approvedAt == approvedAt) &&
            (identical(other.approvedBy, approvedBy) ||
                other.approvedBy == approvedBy) &&
            (identical(other.rejectedAt, rejectedAt) ||
                other.rejectedAt == rejectedAt) &&
            (identical(other.rejectedBy, rejectedBy) ||
                other.rejectedBy == rejectedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      weekStart,
      requestedHours,
      status,
      createdAt,
      approvedAt,
      approvedBy,
      rejectedAt,
      rejectedBy);

  /// Create a copy of OvertimeRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OvertimeRequestModelImplCopyWith<_$OvertimeRequestModelImpl>
      get copyWith =>
          __$$OvertimeRequestModelImplCopyWithImpl<_$OvertimeRequestModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OvertimeRequestModelImplToJson(
      this,
    );
  }
}

abstract class _OvertimeRequestModel extends OvertimeRequestModel {
  const factory _OvertimeRequestModel(
      {required final String id,
      required final String userId,
      required final DateTime weekStart,
      required final double requestedHours,
      required final OvertimeRequestStatus status,
      required final DateTime createdAt,
      final DateTime? approvedAt,
      final String? approvedBy,
      final DateTime? rejectedAt,
      final String? rejectedBy}) = _$OvertimeRequestModelImpl;
  const _OvertimeRequestModel._() : super._();

  factory _OvertimeRequestModel.fromJson(Map<String, dynamic> json) =
      _$OvertimeRequestModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get weekStart; // Lunes 00:00:00 de la semana
  @override
  double get requestedHours; // Horas extra detectadas
  @override
  OvertimeRequestStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get approvedAt;
  @override
  String? get approvedBy;
  @override
  DateTime? get rejectedAt;
  @override
  String? get rejectedBy;

  /// Create a copy of OvertimeRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OvertimeRequestModelImplCopyWith<_$OvertimeRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
