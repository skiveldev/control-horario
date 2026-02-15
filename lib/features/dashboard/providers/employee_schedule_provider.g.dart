// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$employeeFullScheduleHash() =>
    r'73594ab583c8749e0080989ca1573f41ccaa8596';

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

/// Provider que obtiene el horario completo del empleado
///
/// Combina datos del usuario (scheduleId/customSchedule) con plantillas de Firestore.
///
/// Casos:
/// 1. Usuario usa plantilla (scheduleType = "template")
///    → Obtiene plantilla desde schedules/{scheduleId}
///
/// 2. Usuario tiene horario personalizado (scheduleType = "custom")
///    → Usa customSchedule embebido en su documento
///
/// 3. Usuario sin horario
///    → Retorna null
///
/// Ejemplo de uso:
/// ```dart
/// final scheduleAsync = ref.watch(employeeFullScheduleProvider(userId));
/// scheduleAsync.when(
///   data: (schedule) {
///     if (schedule == null) return Text('Sin horario');
///     return Text('${schedule.templateName} (${schedule.weeklyHours}h)');
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [employeeFullSchedule].
@ProviderFor(employeeFullSchedule)
const employeeFullScheduleProvider = EmployeeFullScheduleFamily();

/// Provider que obtiene el horario completo del empleado
///
/// Combina datos del usuario (scheduleId/customSchedule) con plantillas de Firestore.
///
/// Casos:
/// 1. Usuario usa plantilla (scheduleType = "template")
///    → Obtiene plantilla desde schedules/{scheduleId}
///
/// 2. Usuario tiene horario personalizado (scheduleType = "custom")
///    → Usa customSchedule embebido en su documento
///
/// 3. Usuario sin horario
///    → Retorna null
///
/// Ejemplo de uso:
/// ```dart
/// final scheduleAsync = ref.watch(employeeFullScheduleProvider(userId));
/// scheduleAsync.when(
///   data: (schedule) {
///     if (schedule == null) return Text('Sin horario');
///     return Text('${schedule.templateName} (${schedule.weeklyHours}h)');
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [employeeFullSchedule].
class EmployeeFullScheduleFamily
    extends Family<AsyncValue<EmployeeScheduleData?>> {
  /// Provider que obtiene el horario completo del empleado
  ///
  /// Combina datos del usuario (scheduleId/customSchedule) con plantillas de Firestore.
  ///
  /// Casos:
  /// 1. Usuario usa plantilla (scheduleType = "template")
  ///    → Obtiene plantilla desde schedules/{scheduleId}
  ///
  /// 2. Usuario tiene horario personalizado (scheduleType = "custom")
  ///    → Usa customSchedule embebido en su documento
  ///
  /// 3. Usuario sin horario
  ///    → Retorna null
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final scheduleAsync = ref.watch(employeeFullScheduleProvider(userId));
  /// scheduleAsync.when(
  ///   data: (schedule) {
  ///     if (schedule == null) return Text('Sin horario');
  ///     return Text('${schedule.templateName} (${schedule.weeklyHours}h)');
  ///   },
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (e, _) => Text('Error: $e'),
  /// );
  /// ```
  ///
  /// Copied from [employeeFullSchedule].
  const EmployeeFullScheduleFamily();

  /// Provider que obtiene el horario completo del empleado
  ///
  /// Combina datos del usuario (scheduleId/customSchedule) con plantillas de Firestore.
  ///
  /// Casos:
  /// 1. Usuario usa plantilla (scheduleType = "template")
  ///    → Obtiene plantilla desde schedules/{scheduleId}
  ///
  /// 2. Usuario tiene horario personalizado (scheduleType = "custom")
  ///    → Usa customSchedule embebido en su documento
  ///
  /// 3. Usuario sin horario
  ///    → Retorna null
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final scheduleAsync = ref.watch(employeeFullScheduleProvider(userId));
  /// scheduleAsync.when(
  ///   data: (schedule) {
  ///     if (schedule == null) return Text('Sin horario');
  ///     return Text('${schedule.templateName} (${schedule.weeklyHours}h)');
  ///   },
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (e, _) => Text('Error: $e'),
  /// );
  /// ```
  ///
  /// Copied from [employeeFullSchedule].
  EmployeeFullScheduleProvider call(
    String userId,
  ) {
    return EmployeeFullScheduleProvider(
      userId,
    );
  }

  @override
  EmployeeFullScheduleProvider getProviderOverride(
    covariant EmployeeFullScheduleProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'employeeFullScheduleProvider';
}

/// Provider que obtiene el horario completo del empleado
///
/// Combina datos del usuario (scheduleId/customSchedule) con plantillas de Firestore.
///
/// Casos:
/// 1. Usuario usa plantilla (scheduleType = "template")
///    → Obtiene plantilla desde schedules/{scheduleId}
///
/// 2. Usuario tiene horario personalizado (scheduleType = "custom")
///    → Usa customSchedule embebido en su documento
///
/// 3. Usuario sin horario
///    → Retorna null
///
/// Ejemplo de uso:
/// ```dart
/// final scheduleAsync = ref.watch(employeeFullScheduleProvider(userId));
/// scheduleAsync.when(
///   data: (schedule) {
///     if (schedule == null) return Text('Sin horario');
///     return Text('${schedule.templateName} (${schedule.weeklyHours}h)');
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [employeeFullSchedule].
class EmployeeFullScheduleProvider
    extends AutoDisposeFutureProvider<EmployeeScheduleData?> {
  /// Provider que obtiene el horario completo del empleado
  ///
  /// Combina datos del usuario (scheduleId/customSchedule) con plantillas de Firestore.
  ///
  /// Casos:
  /// 1. Usuario usa plantilla (scheduleType = "template")
  ///    → Obtiene plantilla desde schedules/{scheduleId}
  ///
  /// 2. Usuario tiene horario personalizado (scheduleType = "custom")
  ///    → Usa customSchedule embebido en su documento
  ///
  /// 3. Usuario sin horario
  ///    → Retorna null
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final scheduleAsync = ref.watch(employeeFullScheduleProvider(userId));
  /// scheduleAsync.when(
  ///   data: (schedule) {
  ///     if (schedule == null) return Text('Sin horario');
  ///     return Text('${schedule.templateName} (${schedule.weeklyHours}h)');
  ///   },
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (e, _) => Text('Error: $e'),
  /// );
  /// ```
  ///
  /// Copied from [employeeFullSchedule].
  EmployeeFullScheduleProvider(
    String userId,
  ) : this._internal(
          (ref) => employeeFullSchedule(
            ref as EmployeeFullScheduleRef,
            userId,
          ),
          from: employeeFullScheduleProvider,
          name: r'employeeFullScheduleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$employeeFullScheduleHash,
          dependencies: EmployeeFullScheduleFamily._dependencies,
          allTransitiveDependencies:
              EmployeeFullScheduleFamily._allTransitiveDependencies,
          userId: userId,
        );

  EmployeeFullScheduleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<EmployeeScheduleData?> Function(EmployeeFullScheduleRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EmployeeFullScheduleProvider._internal(
        (ref) => create(ref as EmployeeFullScheduleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<EmployeeScheduleData?> createElement() {
    return _EmployeeFullScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EmployeeFullScheduleProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin EmployeeFullScheduleRef
    on AutoDisposeFutureProviderRef<EmployeeScheduleData?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _EmployeeFullScheduleProviderElement
    extends AutoDisposeFutureProviderElement<EmployeeScheduleData?>
    with EmployeeFullScheduleRef {
  _EmployeeFullScheduleProviderElement(super.provider);

  @override
  String get userId => (origin as EmployeeFullScheduleProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
