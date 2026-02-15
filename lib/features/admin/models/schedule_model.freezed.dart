// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) {
  return _ScheduleModel.fromJson(json);
}

/// @nodoc
mixin _$ScheduleModel {
  String get scheduleId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get totalWeeklyHours => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  bool get isTemplate => throw _privateConstructorUsedError;
  int get usedByCount => throw _privateConstructorUsedError;
  Map<String, DaySchedule> get weeklySchedule =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime? get lastModifiedAt => throw _privateConstructorUsedError;
  String? get lastModifiedBy => throw _privateConstructorUsedError;

  /// Serializes this ScheduleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleModelCopyWith<ScheduleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleModelCopyWith<$Res> {
  factory $ScheduleModelCopyWith(
          ScheduleModel value, $Res Function(ScheduleModel) then) =
      _$ScheduleModelCopyWithImpl<$Res, ScheduleModel>;
  @useResult
  $Res call(
      {String scheduleId,
      String name,
      String description,
      int totalWeeklyHours,
      bool isActive,
      bool isTemplate,
      int usedByCount,
      Map<String, DaySchedule> weeklySchedule,
      DateTime? createdAt,
      String? createdBy,
      DateTime? lastModifiedAt,
      String? lastModifiedBy});
}

/// @nodoc
class _$ScheduleModelCopyWithImpl<$Res, $Val extends ScheduleModel>
    implements $ScheduleModelCopyWith<$Res> {
  _$ScheduleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = null,
    Object? name = null,
    Object? description = null,
    Object? totalWeeklyHours = null,
    Object? isActive = null,
    Object? isTemplate = null,
    Object? usedByCount = null,
    Object? weeklySchedule = null,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
    Object? lastModifiedAt = freezed,
    Object? lastModifiedBy = freezed,
  }) {
    return _then(_value.copyWith(
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      totalWeeklyHours: null == totalWeeklyHours
          ? _value.totalWeeklyHours
          : totalWeeklyHours // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isTemplate: null == isTemplate
          ? _value.isTemplate
          : isTemplate // ignore: cast_nullable_to_non_nullable
              as bool,
      usedByCount: null == usedByCount
          ? _value.usedByCount
          : usedByCount // ignore: cast_nullable_to_non_nullable
              as int,
      weeklySchedule: null == weeklySchedule
          ? _value.weeklySchedule
          : weeklySchedule // ignore: cast_nullable_to_non_nullable
              as Map<String, DaySchedule>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      lastModifiedAt: freezed == lastModifiedAt
          ? _value.lastModifiedAt
          : lastModifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastModifiedBy: freezed == lastModifiedBy
          ? _value.lastModifiedBy
          : lastModifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleModelImplCopyWith<$Res>
    implements $ScheduleModelCopyWith<$Res> {
  factory _$$ScheduleModelImplCopyWith(
          _$ScheduleModelImpl value, $Res Function(_$ScheduleModelImpl) then) =
      __$$ScheduleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String scheduleId,
      String name,
      String description,
      int totalWeeklyHours,
      bool isActive,
      bool isTemplate,
      int usedByCount,
      Map<String, DaySchedule> weeklySchedule,
      DateTime? createdAt,
      String? createdBy,
      DateTime? lastModifiedAt,
      String? lastModifiedBy});
}

/// @nodoc
class __$$ScheduleModelImplCopyWithImpl<$Res>
    extends _$ScheduleModelCopyWithImpl<$Res, _$ScheduleModelImpl>
    implements _$$ScheduleModelImplCopyWith<$Res> {
  __$$ScheduleModelImplCopyWithImpl(
      _$ScheduleModelImpl _value, $Res Function(_$ScheduleModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = null,
    Object? name = null,
    Object? description = null,
    Object? totalWeeklyHours = null,
    Object? isActive = null,
    Object? isTemplate = null,
    Object? usedByCount = null,
    Object? weeklySchedule = null,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
    Object? lastModifiedAt = freezed,
    Object? lastModifiedBy = freezed,
  }) {
    return _then(_$ScheduleModelImpl(
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      totalWeeklyHours: null == totalWeeklyHours
          ? _value.totalWeeklyHours
          : totalWeeklyHours // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isTemplate: null == isTemplate
          ? _value.isTemplate
          : isTemplate // ignore: cast_nullable_to_non_nullable
              as bool,
      usedByCount: null == usedByCount
          ? _value.usedByCount
          : usedByCount // ignore: cast_nullable_to_non_nullable
              as int,
      weeklySchedule: null == weeklySchedule
          ? _value._weeklySchedule
          : weeklySchedule // ignore: cast_nullable_to_non_nullable
              as Map<String, DaySchedule>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      lastModifiedAt: freezed == lastModifiedAt
          ? _value.lastModifiedAt
          : lastModifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastModifiedBy: freezed == lastModifiedBy
          ? _value.lastModifiedBy
          : lastModifiedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleModelImpl extends _ScheduleModel {
  const _$ScheduleModelImpl(
      {required this.scheduleId,
      required this.name,
      required this.description,
      required this.totalWeeklyHours,
      this.isActive = true,
      this.isTemplate = true,
      this.usedByCount = 0,
      required final Map<String, DaySchedule> weeklySchedule,
      this.createdAt,
      this.createdBy,
      this.lastModifiedAt,
      this.lastModifiedBy})
      : _weeklySchedule = weeklySchedule,
        super._();

  factory _$ScheduleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleModelImplFromJson(json);

  @override
  final String scheduleId;
  @override
  final String name;
  @override
  final String description;
  @override
  final int totalWeeklyHours;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isTemplate;
  @override
  @JsonKey()
  final int usedByCount;
  final Map<String, DaySchedule> _weeklySchedule;
  @override
  Map<String, DaySchedule> get weeklySchedule {
    if (_weeklySchedule is EqualUnmodifiableMapView) return _weeklySchedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_weeklySchedule);
  }

  @override
  final DateTime? createdAt;
  @override
  final String? createdBy;
  @override
  final DateTime? lastModifiedAt;
  @override
  final String? lastModifiedBy;

  @override
  String toString() {
    return 'ScheduleModel(scheduleId: $scheduleId, name: $name, description: $description, totalWeeklyHours: $totalWeeklyHours, isActive: $isActive, isTemplate: $isTemplate, usedByCount: $usedByCount, weeklySchedule: $weeklySchedule, createdAt: $createdAt, createdBy: $createdBy, lastModifiedAt: $lastModifiedAt, lastModifiedBy: $lastModifiedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleModelImpl &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.totalWeeklyHours, totalWeeklyHours) ||
                other.totalWeeklyHours == totalWeeklyHours) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isTemplate, isTemplate) ||
                other.isTemplate == isTemplate) &&
            (identical(other.usedByCount, usedByCount) ||
                other.usedByCount == usedByCount) &&
            const DeepCollectionEquality()
                .equals(other._weeklySchedule, _weeklySchedule) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.lastModifiedAt, lastModifiedAt) ||
                other.lastModifiedAt == lastModifiedAt) &&
            (identical(other.lastModifiedBy, lastModifiedBy) ||
                other.lastModifiedBy == lastModifiedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      scheduleId,
      name,
      description,
      totalWeeklyHours,
      isActive,
      isTemplate,
      usedByCount,
      const DeepCollectionEquality().hash(_weeklySchedule),
      createdAt,
      createdBy,
      lastModifiedAt,
      lastModifiedBy);

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleModelImplCopyWith<_$ScheduleModelImpl> get copyWith =>
      __$$ScheduleModelImplCopyWithImpl<_$ScheduleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleModelImplToJson(
      this,
    );
  }
}

abstract class _ScheduleModel extends ScheduleModel {
  const factory _ScheduleModel(
      {required final String scheduleId,
      required final String name,
      required final String description,
      required final int totalWeeklyHours,
      final bool isActive,
      final bool isTemplate,
      final int usedByCount,
      required final Map<String, DaySchedule> weeklySchedule,
      final DateTime? createdAt,
      final String? createdBy,
      final DateTime? lastModifiedAt,
      final String? lastModifiedBy}) = _$ScheduleModelImpl;
  const _ScheduleModel._() : super._();

  factory _ScheduleModel.fromJson(Map<String, dynamic> json) =
      _$ScheduleModelImpl.fromJson;

  @override
  String get scheduleId;
  @override
  String get name;
  @override
  String get description;
  @override
  int get totalWeeklyHours;
  @override
  bool get isActive;
  @override
  bool get isTemplate;
  @override
  int get usedByCount;
  @override
  Map<String, DaySchedule> get weeklySchedule;
  @override
  DateTime? get createdAt;
  @override
  String? get createdBy;
  @override
  DateTime? get lastModifiedAt;
  @override
  String? get lastModifiedBy;

  /// Create a copy of ScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleModelImplCopyWith<_$ScheduleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DaySchedule _$DayScheduleFromJson(Map<String, dynamic> json) {
  return _DaySchedule.fromJson(json);
}

/// @nodoc
mixin _$DaySchedule {
  bool get isWorkDay => throw _privateConstructorUsedError;
  List<TimeShift> get shifts => throw _privateConstructorUsedError;
  int get breakMinutes => throw _privateConstructorUsedError;
  double get dailyHours => throw _privateConstructorUsedError;

  /// Serializes this DaySchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DaySchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayScheduleCopyWith<DaySchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayScheduleCopyWith<$Res> {
  factory $DayScheduleCopyWith(
          DaySchedule value, $Res Function(DaySchedule) then) =
      _$DayScheduleCopyWithImpl<$Res, DaySchedule>;
  @useResult
  $Res call(
      {bool isWorkDay,
      List<TimeShift> shifts,
      int breakMinutes,
      double dailyHours});
}

/// @nodoc
class _$DayScheduleCopyWithImpl<$Res, $Val extends DaySchedule>
    implements $DayScheduleCopyWith<$Res> {
  _$DayScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DaySchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isWorkDay = null,
    Object? shifts = null,
    Object? breakMinutes = null,
    Object? dailyHours = null,
  }) {
    return _then(_value.copyWith(
      isWorkDay: null == isWorkDay
          ? _value.isWorkDay
          : isWorkDay // ignore: cast_nullable_to_non_nullable
              as bool,
      shifts: null == shifts
          ? _value.shifts
          : shifts // ignore: cast_nullable_to_non_nullable
              as List<TimeShift>,
      breakMinutes: null == breakMinutes
          ? _value.breakMinutes
          : breakMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      dailyHours: null == dailyHours
          ? _value.dailyHours
          : dailyHours // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DayScheduleImplCopyWith<$Res>
    implements $DayScheduleCopyWith<$Res> {
  factory _$$DayScheduleImplCopyWith(
          _$DayScheduleImpl value, $Res Function(_$DayScheduleImpl) then) =
      __$$DayScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isWorkDay,
      List<TimeShift> shifts,
      int breakMinutes,
      double dailyHours});
}

/// @nodoc
class __$$DayScheduleImplCopyWithImpl<$Res>
    extends _$DayScheduleCopyWithImpl<$Res, _$DayScheduleImpl>
    implements _$$DayScheduleImplCopyWith<$Res> {
  __$$DayScheduleImplCopyWithImpl(
      _$DayScheduleImpl _value, $Res Function(_$DayScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of DaySchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isWorkDay = null,
    Object? shifts = null,
    Object? breakMinutes = null,
    Object? dailyHours = null,
  }) {
    return _then(_$DayScheduleImpl(
      isWorkDay: null == isWorkDay
          ? _value.isWorkDay
          : isWorkDay // ignore: cast_nullable_to_non_nullable
              as bool,
      shifts: null == shifts
          ? _value._shifts
          : shifts // ignore: cast_nullable_to_non_nullable
              as List<TimeShift>,
      breakMinutes: null == breakMinutes
          ? _value.breakMinutes
          : breakMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      dailyHours: null == dailyHours
          ? _value.dailyHours
          : dailyHours // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DayScheduleImpl implements _DaySchedule {
  const _$DayScheduleImpl(
      {this.isWorkDay = false,
      final List<TimeShift> shifts = const [],
      this.breakMinutes = 0,
      this.dailyHours = 0.0})
      : _shifts = shifts;

  factory _$DayScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayScheduleImplFromJson(json);

  @override
  @JsonKey()
  final bool isWorkDay;
  final List<TimeShift> _shifts;
  @override
  @JsonKey()
  List<TimeShift> get shifts {
    if (_shifts is EqualUnmodifiableListView) return _shifts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shifts);
  }

  @override
  @JsonKey()
  final int breakMinutes;
  @override
  @JsonKey()
  final double dailyHours;

  @override
  String toString() {
    return 'DaySchedule(isWorkDay: $isWorkDay, shifts: $shifts, breakMinutes: $breakMinutes, dailyHours: $dailyHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayScheduleImpl &&
            (identical(other.isWorkDay, isWorkDay) ||
                other.isWorkDay == isWorkDay) &&
            const DeepCollectionEquality().equals(other._shifts, _shifts) &&
            (identical(other.breakMinutes, breakMinutes) ||
                other.breakMinutes == breakMinutes) &&
            (identical(other.dailyHours, dailyHours) ||
                other.dailyHours == dailyHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, isWorkDay,
      const DeepCollectionEquality().hash(_shifts), breakMinutes, dailyHours);

  /// Create a copy of DaySchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayScheduleImplCopyWith<_$DayScheduleImpl> get copyWith =>
      __$$DayScheduleImplCopyWithImpl<_$DayScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayScheduleImplToJson(
      this,
    );
  }
}

abstract class _DaySchedule implements DaySchedule {
  const factory _DaySchedule(
      {final bool isWorkDay,
      final List<TimeShift> shifts,
      final int breakMinutes,
      final double dailyHours}) = _$DayScheduleImpl;

  factory _DaySchedule.fromJson(Map<String, dynamic> json) =
      _$DayScheduleImpl.fromJson;

  @override
  bool get isWorkDay;
  @override
  List<TimeShift> get shifts;
  @override
  int get breakMinutes;
  @override
  double get dailyHours;

  /// Create a copy of DaySchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayScheduleImplCopyWith<_$DayScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeShift _$TimeShiftFromJson(Map<String, dynamic> json) {
  return _TimeShift.fromJson(json);
}

/// @nodoc
mixin _$TimeShift {
  String get startTime =>
      throw _privateConstructorUsedError; // Formato: "HH:mm" (ej: "09:00")
  String get endTime => throw _privateConstructorUsedError;

  /// Serializes this TimeShift to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeShift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeShiftCopyWith<TimeShift> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeShiftCopyWith<$Res> {
  factory $TimeShiftCopyWith(TimeShift value, $Res Function(TimeShift) then) =
      _$TimeShiftCopyWithImpl<$Res, TimeShift>;
  @useResult
  $Res call({String startTime, String endTime});
}

/// @nodoc
class _$TimeShiftCopyWithImpl<$Res, $Val extends TimeShift>
    implements $TimeShiftCopyWith<$Res> {
  _$TimeShiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeShift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_value.copyWith(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeShiftImplCopyWith<$Res>
    implements $TimeShiftCopyWith<$Res> {
  factory _$$TimeShiftImplCopyWith(
          _$TimeShiftImpl value, $Res Function(_$TimeShiftImpl) then) =
      __$$TimeShiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String startTime, String endTime});
}

/// @nodoc
class __$$TimeShiftImplCopyWithImpl<$Res>
    extends _$TimeShiftCopyWithImpl<$Res, _$TimeShiftImpl>
    implements _$$TimeShiftImplCopyWith<$Res> {
  __$$TimeShiftImplCopyWithImpl(
      _$TimeShiftImpl _value, $Res Function(_$TimeShiftImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeShift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startTime = null,
    Object? endTime = null,
  }) {
    return _then(_$TimeShiftImpl(
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeShiftImpl implements _TimeShift {
  const _$TimeShiftImpl({required this.startTime, required this.endTime});

  factory _$TimeShiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeShiftImplFromJson(json);

  @override
  final String startTime;
// Formato: "HH:mm" (ej: "09:00")
  @override
  final String endTime;

  @override
  String toString() {
    return 'TimeShift(startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeShiftImpl &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startTime, endTime);

  /// Create a copy of TimeShift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeShiftImplCopyWith<_$TimeShiftImpl> get copyWith =>
      __$$TimeShiftImplCopyWithImpl<_$TimeShiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeShiftImplToJson(
      this,
    );
  }
}

abstract class _TimeShift implements TimeShift {
  const factory _TimeShift(
      {required final String startTime,
      required final String endTime}) = _$TimeShiftImpl;

  factory _TimeShift.fromJson(Map<String, dynamic> json) =
      _$TimeShiftImpl.fromJson;

  @override
  String get startTime; // Formato: "HH:mm" (ej: "09:00")
  @override
  String get endTime;

  /// Create a copy of TimeShift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeShiftImplCopyWith<_$TimeShiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
