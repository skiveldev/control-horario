// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_records_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timeRecordsServiceHash() =>
    r'4b085eddae2d06e35288a6757134cc67070858e5';

/// Provider del servicio de registros de tiempo
///
/// Copied from [timeRecordsService].
@ProviderFor(timeRecordsService)
final timeRecordsServiceProvider =
    AutoDisposeProvider<TimeRecordsService>.internal(
  timeRecordsService,
  name: r'timeRecordsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timeRecordsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimeRecordsServiceRef = AutoDisposeProviderRef<TimeRecordsService>;
String _$monthTimeRecordsHash() => r'855c9894c38fdd1faeef1a453845b84d91fd22de';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider para obtener registros de un mes
///
/// Copied from [monthTimeRecords].
@ProviderFor(monthTimeRecords)
const monthTimeRecordsProvider = MonthTimeRecordsFamily();

/// Provider para obtener registros de un mes
///
/// Copied from [monthTimeRecords].
class MonthTimeRecordsFamily extends Family<AsyncValue<List<TimeRecordModel>>> {
  /// Provider para obtener registros de un mes
  ///
  /// Copied from [monthTimeRecords].
  const MonthTimeRecordsFamily();

  /// Provider para obtener registros de un mes
  ///
  /// Copied from [monthTimeRecords].
  MonthTimeRecordsProvider call({
    required String userId,
    required DateTime month,
  }) {
    return MonthTimeRecordsProvider(
      userId: userId,
      month: month,
    );
  }

  @override
  MonthTimeRecordsProvider getProviderOverride(
    covariant MonthTimeRecordsProvider provider,
  ) {
    return call(
      userId: provider.userId,
      month: provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthTimeRecordsProvider';
}

/// Provider para obtener registros de un mes
///
/// Copied from [monthTimeRecords].
class MonthTimeRecordsProvider
    extends AutoDisposeStreamProvider<List<TimeRecordModel>> {
  /// Provider para obtener registros de un mes
  ///
  /// Copied from [monthTimeRecords].
  MonthTimeRecordsProvider({
    required String userId,
    required DateTime month,
  }) : this._internal(
          (ref) => monthTimeRecords(
            ref as MonthTimeRecordsRef,
            userId: userId,
            month: month,
          ),
          from: monthTimeRecordsProvider,
          name: r'monthTimeRecordsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthTimeRecordsHash,
          dependencies: MonthTimeRecordsFamily._dependencies,
          allTransitiveDependencies:
              MonthTimeRecordsFamily._allTransitiveDependencies,
          userId: userId,
          month: month,
        );

  MonthTimeRecordsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.month,
  }) : super.internal();

  final String userId;
  final DateTime month;

  @override
  Override overrideWith(
    Stream<List<TimeRecordModel>> Function(MonthTimeRecordsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthTimeRecordsProvider._internal(
        (ref) => create(ref as MonthTimeRecordsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimeRecordModel>> createElement() {
    return _MonthTimeRecordsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthTimeRecordsProvider &&
        other.userId == userId &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthTimeRecordsRef
    on AutoDisposeStreamProviderRef<List<TimeRecordModel>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `month` of this provider.
  DateTime get month;
}

class _MonthTimeRecordsProviderElement
    extends AutoDisposeStreamProviderElement<List<TimeRecordModel>>
    with MonthTimeRecordsRef {
  _MonthTimeRecordsProviderElement(super.provider);

  @override
  String get userId => (origin as MonthTimeRecordsProvider).userId;
  @override
  DateTime get month => (origin as MonthTimeRecordsProvider).month;
}

String _$dayTimeRecordsHash() => r'ce09d3fcf3793a6374236d0c65d8959d6434ac06';

/// Provider para obtener registros de un día
///
/// Copied from [dayTimeRecords].
@ProviderFor(dayTimeRecords)
const dayTimeRecordsProvider = DayTimeRecordsFamily();

/// Provider para obtener registros de un día
///
/// Copied from [dayTimeRecords].
class DayTimeRecordsFamily extends Family<AsyncValue<List<TimeRecordModel>>> {
  /// Provider para obtener registros de un día
  ///
  /// Copied from [dayTimeRecords].
  const DayTimeRecordsFamily();

  /// Provider para obtener registros de un día
  ///
  /// Copied from [dayTimeRecords].
  DayTimeRecordsProvider call({
    required String userId,
    required DateTime date,
  }) {
    return DayTimeRecordsProvider(
      userId: userId,
      date: date,
    );
  }

  @override
  DayTimeRecordsProvider getProviderOverride(
    covariant DayTimeRecordsProvider provider,
  ) {
    return call(
      userId: provider.userId,
      date: provider.date,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dayTimeRecordsProvider';
}

/// Provider para obtener registros de un día
///
/// Copied from [dayTimeRecords].
class DayTimeRecordsProvider
    extends AutoDisposeStreamProvider<List<TimeRecordModel>> {
  /// Provider para obtener registros de un día
  ///
  /// Copied from [dayTimeRecords].
  DayTimeRecordsProvider({
    required String userId,
    required DateTime date,
  }) : this._internal(
          (ref) => dayTimeRecords(
            ref as DayTimeRecordsRef,
            userId: userId,
            date: date,
          ),
          from: dayTimeRecordsProvider,
          name: r'dayTimeRecordsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dayTimeRecordsHash,
          dependencies: DayTimeRecordsFamily._dependencies,
          allTransitiveDependencies:
              DayTimeRecordsFamily._allTransitiveDependencies,
          userId: userId,
          date: date,
        );

  DayTimeRecordsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.date,
  }) : super.internal();

  final String userId;
  final DateTime date;

  @override
  Override overrideWith(
    Stream<List<TimeRecordModel>> Function(DayTimeRecordsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DayTimeRecordsProvider._internal(
        (ref) => create(ref as DayTimeRecordsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimeRecordModel>> createElement() {
    return _DayTimeRecordsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DayTimeRecordsProvider &&
        other.userId == userId &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DayTimeRecordsRef on AutoDisposeStreamProviderRef<List<TimeRecordModel>> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `date` of this provider.
  DateTime get date;
}

class _DayTimeRecordsProviderElement
    extends AutoDisposeStreamProviderElement<List<TimeRecordModel>>
    with DayTimeRecordsRef {
  _DayTimeRecordsProviderElement(super.provider);

  @override
  String get userId => (origin as DayTimeRecordsProvider).userId;
  @override
  DateTime get date => (origin as DayTimeRecordsProvider).date;
}

String _$timeRecordHash() => r'cd1c17139de00562ce730fad0fef4a847fab1e97';

/// Provider para obtener un registro específico
///
/// Copied from [timeRecord].
@ProviderFor(timeRecord)
const timeRecordProvider = TimeRecordFamily();

/// Provider para obtener un registro específico
///
/// Copied from [timeRecord].
class TimeRecordFamily extends Family<AsyncValue<TimeRecordModel?>> {
  /// Provider para obtener un registro específico
  ///
  /// Copied from [timeRecord].
  const TimeRecordFamily();

  /// Provider para obtener un registro específico
  ///
  /// Copied from [timeRecord].
  TimeRecordProvider call({
    required String userId,
    required String recordId,
  }) {
    return TimeRecordProvider(
      userId: userId,
      recordId: recordId,
    );
  }

  @override
  TimeRecordProvider getProviderOverride(
    covariant TimeRecordProvider provider,
  ) {
    return call(
      userId: provider.userId,
      recordId: provider.recordId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timeRecordProvider';
}

/// Provider para obtener un registro específico
///
/// Copied from [timeRecord].
class TimeRecordProvider extends AutoDisposeFutureProvider<TimeRecordModel?> {
  /// Provider para obtener un registro específico
  ///
  /// Copied from [timeRecord].
  TimeRecordProvider({
    required String userId,
    required String recordId,
  }) : this._internal(
          (ref) => timeRecord(
            ref as TimeRecordRef,
            userId: userId,
            recordId: recordId,
          ),
          from: timeRecordProvider,
          name: r'timeRecordProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timeRecordHash,
          dependencies: TimeRecordFamily._dependencies,
          allTransitiveDependencies:
              TimeRecordFamily._allTransitiveDependencies,
          userId: userId,
          recordId: recordId,
        );

  TimeRecordProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.recordId,
  }) : super.internal();

  final String userId;
  final String recordId;

  @override
  Override overrideWith(
    FutureOr<TimeRecordModel?> Function(TimeRecordRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimeRecordProvider._internal(
        (ref) => create(ref as TimeRecordRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        recordId: recordId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TimeRecordModel?> createElement() {
    return _TimeRecordProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeRecordProvider &&
        other.userId == userId &&
        other.recordId == recordId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, recordId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeRecordRef on AutoDisposeFutureProviderRef<TimeRecordModel?> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `recordId` of this provider.
  String get recordId;
}

class _TimeRecordProviderElement
    extends AutoDisposeFutureProviderElement<TimeRecordModel?>
    with TimeRecordRef {
  _TimeRecordProviderElement(super.provider);

  @override
  String get userId => (origin as TimeRecordProvider).userId;
  @override
  String get recordId => (origin as TimeRecordProvider).recordId;
}

String _$canEditRecordHash() => r'a9c06630def09088e31a583af6508e4eb85cc0c1';

/// Provider para verificar si un registro puede ser editado
///
/// Copied from [canEditRecord].
@ProviderFor(canEditRecord)
const canEditRecordProvider = CanEditRecordFamily();

/// Provider para verificar si un registro puede ser editado
///
/// Copied from [canEditRecord].
class CanEditRecordFamily extends Family<AsyncValue<bool>> {
  /// Provider para verificar si un registro puede ser editado
  ///
  /// Copied from [canEditRecord].
  const CanEditRecordFamily();

  /// Provider para verificar si un registro puede ser editado
  ///
  /// Copied from [canEditRecord].
  CanEditRecordProvider call({
    required String userId,
    required String recordId,
  }) {
    return CanEditRecordProvider(
      userId: userId,
      recordId: recordId,
    );
  }

  @override
  CanEditRecordProvider getProviderOverride(
    covariant CanEditRecordProvider provider,
  ) {
    return call(
      userId: provider.userId,
      recordId: provider.recordId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'canEditRecordProvider';
}

/// Provider para verificar si un registro puede ser editado
///
/// Copied from [canEditRecord].
class CanEditRecordProvider extends AutoDisposeFutureProvider<bool> {
  /// Provider para verificar si un registro puede ser editado
  ///
  /// Copied from [canEditRecord].
  CanEditRecordProvider({
    required String userId,
    required String recordId,
  }) : this._internal(
          (ref) => canEditRecord(
            ref as CanEditRecordRef,
            userId: userId,
            recordId: recordId,
          ),
          from: canEditRecordProvider,
          name: r'canEditRecordProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$canEditRecordHash,
          dependencies: CanEditRecordFamily._dependencies,
          allTransitiveDependencies:
              CanEditRecordFamily._allTransitiveDependencies,
          userId: userId,
          recordId: recordId,
        );

  CanEditRecordProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
    required this.recordId,
  }) : super.internal();

  final String userId;
  final String recordId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CanEditRecordRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanEditRecordProvider._internal(
        (ref) => create(ref as CanEditRecordRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
        recordId: recordId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CanEditRecordProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanEditRecordProvider &&
        other.userId == userId &&
        other.recordId == recordId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);
    hash = _SystemHash.combine(hash, recordId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanEditRecordRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `userId` of this provider.
  String get userId;

  /// The parameter `recordId` of this provider.
  String get recordId;
}

class _CanEditRecordProviderElement
    extends AutoDisposeFutureProviderElement<bool> with CanEditRecordRef {
  _CanEditRecordProviderElement(super.provider);

  @override
  String get userId => (origin as CanEditRecordProvider).userId;
  @override
  String get recordId => (origin as CanEditRecordProvider).recordId;
}

String _$timeRecordsNotifierHash() =>
    r'5534f1367f3ea921803b1ea8e38aafd2bee2547a';

/// Notifier para operaciones CRUD sobre registros
///
/// Copied from [TimeRecordsNotifier].
@ProviderFor(TimeRecordsNotifier)
final timeRecordsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TimeRecordsNotifier, String?>.internal(
  TimeRecordsNotifier.new,
  name: r'timeRecordsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timeRecordsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TimeRecordsNotifier = AutoDisposeAsyncNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
