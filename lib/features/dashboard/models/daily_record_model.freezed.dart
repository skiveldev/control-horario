// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyRecordModel _$DailyRecordModelFromJson(Map<String, dynamic> json) {
  return _DailyRecordModel.fromJson(json);
}

/// @nodoc
mixin _$DailyRecordModel {
  String get date => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  ClockTimes get clocks => throw _privateConstructorUsedError;
  DateTime? get clockInTimestamp => throw _privateConstructorUsedError;
  DateTime? get clockOutTimestamp => throw _privateConstructorUsedError;
  RecordStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DailyRecordModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyRecordModelCopyWith<DailyRecordModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyRecordModelCopyWith<$Res> {
  factory $DailyRecordModelCopyWith(
    DailyRecordModel value,
    $Res Function(DailyRecordModel) then,
  ) = _$DailyRecordModelCopyWithImpl<$Res, DailyRecordModel>;
  @useResult
  $Res call({
    String date,
    String userId,
    ClockTimes clocks,
    DateTime? clockInTimestamp,
    DateTime? clockOutTimestamp,
    RecordStatus status,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $ClockTimesCopyWith<$Res> get clocks;
}

/// @nodoc
class _$DailyRecordModelCopyWithImpl<$Res, $Val extends DailyRecordModel>
    implements $DailyRecordModelCopyWith<$Res> {
  _$DailyRecordModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? userId = null,
    Object? clocks = null,
    Object? clockInTimestamp = freezed,
    Object? clockOutTimestamp = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                as String,
        clocks: null == clocks
            ? _value.clocks
            : clocks // ignore: cast_nullable_to_non_nullable
                as ClockTimes,
        clockInTimestamp: freezed == clockInTimestamp
            ? _value.clockInTimestamp
            : clockInTimestamp // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        clockOutTimestamp: freezed == clockOutTimestamp
            ? _value.clockOutTimestamp
            : clockOutTimestamp // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                as RecordStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
      ) as $Val,
    );
  }

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClockTimesCopyWith<$Res> get clocks {
    return $ClockTimesCopyWith<$Res>(_value.clocks, (value) {
      return _then(_value.copyWith(clocks: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyRecordModelImplCopyWith<$Res>
    implements $DailyRecordModelCopyWith<$Res> {
  factory _$$DailyRecordModelImplCopyWith(
    _$DailyRecordModelImpl value,
    $Res Function(_$DailyRecordModelImpl) then,
  ) = __$$DailyRecordModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    String userId,
    ClockTimes clocks,
    DateTime? clockInTimestamp,
    DateTime? clockOutTimestamp,
    RecordStatus status,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $ClockTimesCopyWith<$Res> get clocks;
}

/// @nodoc
class __$$DailyRecordModelImplCopyWithImpl<$Res>
    extends _$DailyRecordModelCopyWithImpl<$Res, _$DailyRecordModelImpl>
    implements _$$DailyRecordModelImplCopyWith<$Res> {
  __$$DailyRecordModelImplCopyWithImpl(
    _$DailyRecordModelImpl _value,
    $Res Function(_$DailyRecordModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? userId = null,
    Object? clocks = null,
    Object? clockInTimestamp = freezed,
    Object? clockOutTimestamp = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$DailyRecordModelImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                as String,
        clocks: null == clocks
            ? _value.clocks
            : clocks // ignore: cast_nullable_to_non_nullable
                as ClockTimes,
        clockInTimestamp: freezed == clockInTimestamp
            ? _value.clockInTimestamp
            : clockInTimestamp // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        clockOutTimestamp: freezed == clockOutTimestamp
            ? _value.clockOutTimestamp
            : clockOutTimestamp // ignore: cast_nullable_to_non_nullable
                as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                as RecordStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyRecordModelImpl implements _DailyRecordModel {
  const _$DailyRecordModelImpl({
    required this.date,
    required this.userId,
    required this.clocks,
    this.clockInTimestamp,
    this.clockOutTimestamp,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$DailyRecordModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyRecordModelImplFromJson(json);

  @override
  final String date;
  @override
  final String userId;
  @override
  final ClockTimes clocks;
  @override
  final DateTime? clockInTimestamp;
  @override
  final DateTime? clockOutTimestamp;
  @override
  final RecordStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'DailyRecordModel(date: $date, userId: $userId, clocks: $clocks, clockInTimestamp: $clockInTimestamp, clockOutTimestamp: $clockOutTimestamp, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyRecordModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.clocks, clocks) || other.clocks == clocks) &&
            (identical(other.clockInTimestamp, clockInTimestamp) ||
                other.clockInTimestamp == clockInTimestamp) &&
            (identical(other.clockOutTimestamp, clockOutTimestamp) ||
                other.clockOutTimestamp == clockOutTimestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
        runtimeType,
        date,
        userId,
        clocks,
        clockInTimestamp,
        clockOutTimestamp,
        status,
        createdAt,
        updatedAt,
      );

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyRecordModelImplCopyWith<_$DailyRecordModelImpl> get copyWith =>
      __$$DailyRecordModelImplCopyWithImpl<_$DailyRecordModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyRecordModelImplToJson(this);
  }
}

abstract class _DailyRecordModel implements DailyRecordModel {
  const factory _DailyRecordModel({
    required final String date,
    required final String userId,
    required final ClockTimes clocks,
    final DateTime? clockInTimestamp,
    final DateTime? clockOutTimestamp,
    required final RecordStatus status,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$DailyRecordModelImpl;

  factory _DailyRecordModel.fromJson(Map<String, dynamic> json) =
      _$DailyRecordModelImpl.fromJson;

  @override
  String get date;
  @override
  String get userId;
  @override
  ClockTimes get clocks;
  @override
  DateTime? get clockInTimestamp;
  @override
  DateTime? get clockOutTimestamp;
  @override
  RecordStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyRecordModelImplCopyWith<_$DailyRecordModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClockTimes _$ClockTimesFromJson(Map<String, dynamic> json) {
  return _ClockTimes.fromJson(json);
}

/// @nodoc
mixin _$ClockTimes {
  String? get clockIn => throw _privateConstructorUsedError;
  String? get clockOut => throw _privateConstructorUsedError;

  /// Serializes this ClockTimes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClockTimes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClockTimesCopyWith<ClockTimes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClockTimesCopyWith<$Res> {
  factory $ClockTimesCopyWith(
    ClockTimes value,
    $Res Function(ClockTimes) then,
  ) = _$ClockTimesCopyWithImpl<$Res, ClockTimes>;
  @useResult
  $Res call({String? clockIn, String? clockOut});
}

/// @nodoc
class _$ClockTimesCopyWithImpl<$Res, $Val extends ClockTimes>
    implements $ClockTimesCopyWith<$Res> {
  _$ClockTimesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClockTimes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? clockIn = freezed, Object? clockOut = freezed}) {
    return _then(
      _value.copyWith(
        clockIn: freezed == clockIn
            ? _value.clockIn
            : clockIn // ignore: cast_nullable_to_non_nullable
                as String?,
        clockOut: freezed == clockOut
            ? _value.clockOut
            : clockOut // ignore: cast_nullable_to_non_nullable
                as String?,
      ) as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ClockTimesImplCopyWith<$Res>
    implements $ClockTimesCopyWith<$Res> {
  factory _$$ClockTimesImplCopyWith(
    _$ClockTimesImpl value,
    $Res Function(_$ClockTimesImpl) then,
  ) = __$$ClockTimesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? clockIn, String? clockOut});
}

/// @nodoc
class __$$ClockTimesImplCopyWithImpl<$Res>
    extends _$ClockTimesCopyWithImpl<$Res, _$ClockTimesImpl>
    implements _$$ClockTimesImplCopyWith<$Res> {
  __$$ClockTimesImplCopyWithImpl(
    _$ClockTimesImpl _value,
    $Res Function(_$ClockTimesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ClockTimes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? clockIn = freezed, Object? clockOut = freezed}) {
    return _then(
      _$ClockTimesImpl(
        clockIn: freezed == clockIn
            ? _value.clockIn
            : clockIn // ignore: cast_nullable_to_non_nullable
                as String?,
        clockOut: freezed == clockOut
            ? _value.clockOut
            : clockOut // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ClockTimesImpl implements _ClockTimes {
  const _$ClockTimesImpl({this.clockIn, this.clockOut});

  factory _$ClockTimesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClockTimesImplFromJson(json);

  @override
  final String? clockIn;
  @override
  final String? clockOut;

  @override
  String toString() {
    return 'ClockTimes(clockIn: $clockIn, clockOut: $clockOut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClockTimesImpl &&
            (identical(other.clockIn, clockIn) || other.clockIn == clockIn) &&
            (identical(other.clockOut, clockOut) ||
                other.clockOut == clockOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, clockIn, clockOut);

  /// Create a copy of ClockTimes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClockTimesImplCopyWith<_$ClockTimesImpl> get copyWith =>
      __$$ClockTimesImplCopyWithImpl<_$ClockTimesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClockTimesImplToJson(this);
  }
}

abstract class _ClockTimes implements ClockTimes {
  const factory _ClockTimes({final String? clockIn, final String? clockOut}) =
      _$ClockTimesImpl;

  factory _ClockTimes.fromJson(Map<String, dynamic> json) =
      _$ClockTimesImpl.fromJson;

  @override
  String? get clockIn;
  @override
  String? get clockOut;

  /// Create a copy of ClockTimes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClockTimesImplCopyWith<_$ClockTimesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
