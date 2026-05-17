// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anomaly_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnomalyModel _$AnomalyModelFromJson(Map<String, dynamic> json) {
  return _AnomalyModel.fromJson(json);
}

/// @nodoc
mixin _$AnomalyModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError; // "2026-05-16"
  AnomalyType get type => throw _privateConstructorUsedError;
  AnomalySeverity get severity => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get resolvedBy => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;

  /// Serializes this AnomalyModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnomalyModelCopyWith<AnomalyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnomalyModelCopyWith<$Res> {
  factory $AnomalyModelCopyWith(
          AnomalyModel value, $Res Function(AnomalyModel) then) =
      _$AnomalyModelCopyWithImpl<$Res, AnomalyModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String date,
      AnomalyType type,
      AnomalySeverity severity,
      DateTime createdAt,
      String? description,
      String? resolvedBy,
      DateTime? resolvedAt});
}

/// @nodoc
class _$AnomalyModelCopyWithImpl<$Res, $Val extends AnomalyModel>
    implements $AnomalyModelCopyWith<$Res> {
  _$AnomalyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? type = null,
    Object? severity = null,
    Object? createdAt = null,
    Object? description = freezed,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AnomalyType,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AnomalySeverity,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnomalyModelImplCopyWith<$Res>
    implements $AnomalyModelCopyWith<$Res> {
  factory _$$AnomalyModelImplCopyWith(
          _$AnomalyModelImpl value, $Res Function(_$AnomalyModelImpl) then) =
      __$$AnomalyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String date,
      AnomalyType type,
      AnomalySeverity severity,
      DateTime createdAt,
      String? description,
      String? resolvedBy,
      DateTime? resolvedAt});
}

/// @nodoc
class __$$AnomalyModelImplCopyWithImpl<$Res>
    extends _$AnomalyModelCopyWithImpl<$Res, _$AnomalyModelImpl>
    implements _$$AnomalyModelImplCopyWith<$Res> {
  __$$AnomalyModelImplCopyWithImpl(
      _$AnomalyModelImpl _value, $Res Function(_$AnomalyModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? type = null,
    Object? severity = null,
    Object? createdAt = null,
    Object? description = freezed,
    Object? resolvedBy = freezed,
    Object? resolvedAt = freezed,
  }) {
    return _then(_$AnomalyModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AnomalyType,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as AnomalySeverity,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnomalyModelImpl extends _AnomalyModel {
  const _$AnomalyModelImpl(
      {required this.id,
      required this.userId,
      required this.date,
      required this.type,
      required this.severity,
      required this.createdAt,
      this.description,
      this.resolvedBy,
      this.resolvedAt})
      : super._();

  factory _$AnomalyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnomalyModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String date;
// "2026-05-16"
  @override
  final AnomalyType type;
  @override
  final AnomalySeverity severity;
  @override
  final DateTime createdAt;
  @override
  final String? description;
  @override
  final String? resolvedBy;
  @override
  final DateTime? resolvedAt;

  @override
  String toString() {
    return 'AnomalyModel(id: $id, userId: $userId, date: $date, type: $type, severity: $severity, createdAt: $createdAt, description: $description, resolvedBy: $resolvedBy, resolvedAt: $resolvedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnomalyModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, date, type, severity,
      createdAt, description, resolvedBy, resolvedAt);

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnomalyModelImplCopyWith<_$AnomalyModelImpl> get copyWith =>
      __$$AnomalyModelImplCopyWithImpl<_$AnomalyModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnomalyModelImplToJson(
      this,
    );
  }
}

abstract class _AnomalyModel extends AnomalyModel {
  const factory _AnomalyModel(
      {required final String id,
      required final String userId,
      required final String date,
      required final AnomalyType type,
      required final AnomalySeverity severity,
      required final DateTime createdAt,
      final String? description,
      final String? resolvedBy,
      final DateTime? resolvedAt}) = _$AnomalyModelImpl;
  const _AnomalyModel._() : super._();

  factory _AnomalyModel.fromJson(Map<String, dynamic> json) =
      _$AnomalyModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get date; // "2026-05-16"
  @override
  AnomalyType get type;
  @override
  AnomalySeverity get severity;
  @override
  DateTime get createdAt;
  @override
  String? get description;
  @override
  String? get resolvedBy;
  @override
  DateTime? get resolvedAt;

  /// Create a copy of AnomalyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnomalyModelImplCopyWith<_$AnomalyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
