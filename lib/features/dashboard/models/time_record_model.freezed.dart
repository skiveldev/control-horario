// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeRecordModel _$TimeRecordModelFromJson(Map<String, dynamic> json) {
  return _TimeRecordModel.fromJson(json);
}

/// @nodoc
mixin _$TimeRecordModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError; // "2025-12-01"
  RecordCategory get category => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError; // "07:30"
  String get endTime => throw _privateConstructorUsedError; // "14:00"
  String get location => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  bool get isManual => throw _privateConstructorUsedError;
  String? get copiedFrom =>
      throw _privateConstructorUsedError; // Estado del registro (activo/completado)
  RecordStatus get recordStatus =>
      throw _privateConstructorUsedError; // Campos de validación
  ValidationStatus get validationStatus => throw _privateConstructorUsedError;
  String? get validatedBy => throw _privateConstructorUsedError;
  DateTime? get validatedAt => throw _privateConstructorUsedError;
  String? get blockedBy => throw _privateConstructorUsedError;
  DateTime? get blockedAt => throw _privateConstructorUsedError;
  String? get blockReason => throw _privateConstructorUsedError;

  /// Serializes this TimeRecordModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeRecordModelCopyWith<TimeRecordModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeRecordModelCopyWith<$Res> {
  factory $TimeRecordModelCopyWith(
          TimeRecordModel value, $Res Function(TimeRecordModel) then) =
      _$TimeRecordModelCopyWithImpl<$Res, TimeRecordModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String date,
      RecordCategory category,
      String startTime,
      String endTime,
      String location,
      int durationMinutes,
      DateTime createdAt,
      DateTime updatedAt,
      String createdBy,
      bool isManual,
      String? copiedFrom,
      RecordStatus recordStatus,
      ValidationStatus validationStatus,
      String? validatedBy,
      DateTime? validatedAt,
      String? blockedBy,
      DateTime? blockedAt,
      String? blockReason});
}

/// @nodoc
class _$TimeRecordModelCopyWithImpl<$Res, $Val extends TimeRecordModel>
    implements $TimeRecordModelCopyWith<$Res> {
  _$TimeRecordModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? category = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? location = null,
    Object? durationMinutes = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
    Object? isManual = null,
    Object? copiedFrom = freezed,
    Object? recordStatus = null,
    Object? validationStatus = null,
    Object? validatedBy = freezed,
    Object? validatedAt = freezed,
    Object? blockedBy = freezed,
    Object? blockedAt = freezed,
    Object? blockReason = freezed,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as RecordCategory,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      isManual: null == isManual
          ? _value.isManual
          : isManual // ignore: cast_nullable_to_non_nullable
              as bool,
      copiedFrom: freezed == copiedFrom
          ? _value.copiedFrom
          : copiedFrom // ignore: cast_nullable_to_non_nullable
              as String?,
      recordStatus: null == recordStatus
          ? _value.recordStatus
          : recordStatus // ignore: cast_nullable_to_non_nullable
              as RecordStatus,
      validationStatus: null == validationStatus
          ? _value.validationStatus
          : validationStatus // ignore: cast_nullable_to_non_nullable
              as ValidationStatus,
      validatedBy: freezed == validatedBy
          ? _value.validatedBy
          : validatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      validatedAt: freezed == validatedAt
          ? _value.validatedAt
          : validatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      blockedBy: freezed == blockedBy
          ? _value.blockedBy
          : blockedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      blockedAt: freezed == blockedAt
          ? _value.blockedAt
          : blockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      blockReason: freezed == blockReason
          ? _value.blockReason
          : blockReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeRecordModelImplCopyWith<$Res>
    implements $TimeRecordModelCopyWith<$Res> {
  factory _$$TimeRecordModelImplCopyWith(_$TimeRecordModelImpl value,
          $Res Function(_$TimeRecordModelImpl) then) =
      __$$TimeRecordModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String date,
      RecordCategory category,
      String startTime,
      String endTime,
      String location,
      int durationMinutes,
      DateTime createdAt,
      DateTime updatedAt,
      String createdBy,
      bool isManual,
      String? copiedFrom,
      RecordStatus recordStatus,
      ValidationStatus validationStatus,
      String? validatedBy,
      DateTime? validatedAt,
      String? blockedBy,
      DateTime? blockedAt,
      String? blockReason});
}

/// @nodoc
class __$$TimeRecordModelImplCopyWithImpl<$Res>
    extends _$TimeRecordModelCopyWithImpl<$Res, _$TimeRecordModelImpl>
    implements _$$TimeRecordModelImplCopyWith<$Res> {
  __$$TimeRecordModelImplCopyWithImpl(
      _$TimeRecordModelImpl _value, $Res Function(_$TimeRecordModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? category = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? location = null,
    Object? durationMinutes = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? createdBy = null,
    Object? isManual = null,
    Object? copiedFrom = freezed,
    Object? recordStatus = null,
    Object? validationStatus = null,
    Object? validatedBy = freezed,
    Object? validatedAt = freezed,
    Object? blockedBy = freezed,
    Object? blockedAt = freezed,
    Object? blockReason = freezed,
  }) {
    return _then(_$TimeRecordModelImpl(
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as RecordCategory,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      isManual: null == isManual
          ? _value.isManual
          : isManual // ignore: cast_nullable_to_non_nullable
              as bool,
      copiedFrom: freezed == copiedFrom
          ? _value.copiedFrom
          : copiedFrom // ignore: cast_nullable_to_non_nullable
              as String?,
      recordStatus: null == recordStatus
          ? _value.recordStatus
          : recordStatus // ignore: cast_nullable_to_non_nullable
              as RecordStatus,
      validationStatus: null == validationStatus
          ? _value.validationStatus
          : validationStatus // ignore: cast_nullable_to_non_nullable
              as ValidationStatus,
      validatedBy: freezed == validatedBy
          ? _value.validatedBy
          : validatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      validatedAt: freezed == validatedAt
          ? _value.validatedAt
          : validatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      blockedBy: freezed == blockedBy
          ? _value.blockedBy
          : blockedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      blockedAt: freezed == blockedAt
          ? _value.blockedAt
          : blockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      blockReason: freezed == blockReason
          ? _value.blockReason
          : blockReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeRecordModelImpl extends _TimeRecordModel {
  const _$TimeRecordModelImpl(
      {required this.id,
      required this.userId,
      required this.date,
      required this.category,
      required this.startTime,
      required this.endTime,
      required this.location,
      required this.durationMinutes,
      required this.createdAt,
      required this.updatedAt,
      required this.createdBy,
      required this.isManual,
      this.copiedFrom,
      this.recordStatus = RecordStatus.active,
      this.validationStatus = ValidationStatus.editable,
      this.validatedBy,
      this.validatedAt,
      this.blockedBy,
      this.blockedAt,
      this.blockReason})
      : super._();

  factory _$TimeRecordModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeRecordModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String date;
// "2025-12-01"
  @override
  final RecordCategory category;
  @override
  final String startTime;
// "07:30"
  @override
  final String endTime;
// "14:00"
  @override
  final String location;
  @override
  final int durationMinutes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String createdBy;
  @override
  final bool isManual;
  @override
  final String? copiedFrom;
// Estado del registro (activo/completado)
  @override
  @JsonKey()
  final RecordStatus recordStatus;
// Campos de validación
  @override
  @JsonKey()
  final ValidationStatus validationStatus;
  @override
  final String? validatedBy;
  @override
  final DateTime? validatedAt;
  @override
  final String? blockedBy;
  @override
  final DateTime? blockedAt;
  @override
  final String? blockReason;

  @override
  String toString() {
    return 'TimeRecordModel(id: $id, userId: $userId, date: $date, category: $category, startTime: $startTime, endTime: $endTime, location: $location, durationMinutes: $durationMinutes, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, isManual: $isManual, copiedFrom: $copiedFrom, recordStatus: $recordStatus, validationStatus: $validationStatus, validatedBy: $validatedBy, validatedAt: $validatedAt, blockedBy: $blockedBy, blockedAt: $blockedAt, blockReason: $blockReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeRecordModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.isManual, isManual) ||
                other.isManual == isManual) &&
            (identical(other.copiedFrom, copiedFrom) ||
                other.copiedFrom == copiedFrom) &&
            (identical(other.recordStatus, recordStatus) ||
                other.recordStatus == recordStatus) &&
            (identical(other.validationStatus, validationStatus) ||
                other.validationStatus == validationStatus) &&
            (identical(other.validatedBy, validatedBy) ||
                other.validatedBy == validatedBy) &&
            (identical(other.validatedAt, validatedAt) ||
                other.validatedAt == validatedAt) &&
            (identical(other.blockedBy, blockedBy) ||
                other.blockedBy == blockedBy) &&
            (identical(other.blockedAt, blockedAt) ||
                other.blockedAt == blockedAt) &&
            (identical(other.blockReason, blockReason) ||
                other.blockReason == blockReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        date,
        category,
        startTime,
        endTime,
        location,
        durationMinutes,
        createdAt,
        updatedAt,
        createdBy,
        isManual,
        copiedFrom,
        recordStatus,
        validationStatus,
        validatedBy,
        validatedAt,
        blockedBy,
        blockedAt,
        blockReason
      ]);

  /// Create a copy of TimeRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeRecordModelImplCopyWith<_$TimeRecordModelImpl> get copyWith =>
      __$$TimeRecordModelImplCopyWithImpl<_$TimeRecordModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeRecordModelImplToJson(
      this,
    );
  }
}

abstract class _TimeRecordModel extends TimeRecordModel {
  const factory _TimeRecordModel(
      {required final String id,
      required final String userId,
      required final String date,
      required final RecordCategory category,
      required final String startTime,
      required final String endTime,
      required final String location,
      required final int durationMinutes,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String createdBy,
      required final bool isManual,
      final String? copiedFrom,
      final RecordStatus recordStatus,
      final ValidationStatus validationStatus,
      final String? validatedBy,
      final DateTime? validatedAt,
      final String? blockedBy,
      final DateTime? blockedAt,
      final String? blockReason}) = _$TimeRecordModelImpl;
  const _TimeRecordModel._() : super._();

  factory _TimeRecordModel.fromJson(Map<String, dynamic> json) =
      _$TimeRecordModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get date; // "2025-12-01"
  @override
  RecordCategory get category;
  @override
  String get startTime; // "07:30"
  @override
  String get endTime; // "14:00"
  @override
  String get location;
  @override
  int get durationMinutes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get createdBy;
  @override
  bool get isManual;
  @override
  String? get copiedFrom; // Estado del registro (activo/completado)
  @override
  RecordStatus get recordStatus; // Campos de validación
  @override
  ValidationStatus get validationStatus;
  @override
  String? get validatedBy;
  @override
  DateTime? get validatedAt;
  @override
  String? get blockedBy;
  @override
  DateTime? get blockedAt;
  @override
  String? get blockReason;

  /// Create a copy of TimeRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeRecordModelImplCopyWith<_$TimeRecordModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
