// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allCalendarsHash() => r'0ddfb6170343440f00267fa16545c7fdec853d5c';

/// Stream de todos los calendarios laborales activos
///
/// Escucha cambios en tiempo real desde Firestore.
/// Usado en la lista de calendarios y en dropdowns de asignación.
///
/// Ejemplo de uso:
/// ```dart
/// final calendarsAsync = ref.watch(allCalendarsProvider);
/// calendarsAsync.when(
///   data: (calendars) => ListView(children: calendars.map(...).toList()),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [allCalendars].
@ProviderFor(allCalendars)
final allCalendarsProvider =
    AutoDisposeStreamProvider<List<WorkCalendarModel>>.internal(
  allCalendars,
  name: r'allCalendarsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allCalendarsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllCalendarsRef = AutoDisposeStreamProviderRef<List<WorkCalendarModel>>;
String _$calendarByIdHash() => r'6fcaef05ef6f5e57eaa6e3c811330fa61f1dd885';

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

/// Stream de un calendario específico por ID
///
/// Retorna null si no existe o fue eliminado.
///
/// [calendarId]: ID del calendario a observar
///
/// Copied from [calendarById].
@ProviderFor(calendarById)
const calendarByIdProvider = CalendarByIdFamily();

/// Stream de un calendario específico por ID
///
/// Retorna null si no existe o fue eliminado.
///
/// [calendarId]: ID del calendario a observar
///
/// Copied from [calendarById].
class CalendarByIdFamily extends Family<AsyncValue<WorkCalendarModel?>> {
  /// Stream de un calendario específico por ID
  ///
  /// Retorna null si no existe o fue eliminado.
  ///
  /// [calendarId]: ID del calendario a observar
  ///
  /// Copied from [calendarById].
  const CalendarByIdFamily();

  /// Stream de un calendario específico por ID
  ///
  /// Retorna null si no existe o fue eliminado.
  ///
  /// [calendarId]: ID del calendario a observar
  ///
  /// Copied from [calendarById].
  CalendarByIdProvider call(
    String calendarId,
  ) {
    return CalendarByIdProvider(
      calendarId,
    );
  }

  @override
  CalendarByIdProvider getProviderOverride(
    covariant CalendarByIdProvider provider,
  ) {
    return call(
      provider.calendarId,
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
  String? get name => r'calendarByIdProvider';
}

/// Stream de un calendario específico por ID
///
/// Retorna null si no existe o fue eliminado.
///
/// [calendarId]: ID del calendario a observar
///
/// Copied from [calendarById].
class CalendarByIdProvider
    extends AutoDisposeStreamProvider<WorkCalendarModel?> {
  /// Stream de un calendario específico por ID
  ///
  /// Retorna null si no existe o fue eliminado.
  ///
  /// [calendarId]: ID del calendario a observar
  ///
  /// Copied from [calendarById].
  CalendarByIdProvider(
    String calendarId,
  ) : this._internal(
          (ref) => calendarById(
            ref as CalendarByIdRef,
            calendarId,
          ),
          from: calendarByIdProvider,
          name: r'calendarByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$calendarByIdHash,
          dependencies: CalendarByIdFamily._dependencies,
          allTransitiveDependencies:
              CalendarByIdFamily._allTransitiveDependencies,
          calendarId: calendarId,
        );

  CalendarByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.calendarId,
  }) : super.internal();

  final String calendarId;

  @override
  Override overrideWith(
    Stream<WorkCalendarModel?> Function(CalendarByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CalendarByIdProvider._internal(
        (ref) => create(ref as CalendarByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        calendarId: calendarId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<WorkCalendarModel?> createElement() {
    return _CalendarByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarByIdProvider && other.calendarId == calendarId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, calendarId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CalendarByIdRef on AutoDisposeStreamProviderRef<WorkCalendarModel?> {
  /// The parameter `calendarId` of this provider.
  String get calendarId;
}

class _CalendarByIdProviderElement
    extends AutoDisposeStreamProviderElement<WorkCalendarModel?>
    with CalendarByIdRef {
  _CalendarByIdProviderElement(super.provider);

  @override
  String get calendarId => (origin as CalendarByIdProvider).calendarId;
}

String _$calendarManagementHash() =>
    r'4ce0e6cfa24e107dce5716689c1965692bd534a5';

/// Notifier para crear, editar, duplicar y eliminar calendarios laborales
///
/// Responsabilidad:
/// - Validaciones de negocio
/// - Llamadas a CalendarService
/// - Manejo de estado (loading, error)
///
/// Ejemplo de uso:
/// ```dart
/// await ref.read(calendarManagementProvider.notifier).saveCalendar(
///   calendarId: null, // null = crear nuevo
///   name: 'Madrid 2026',
///   year: 2026,
///   events: [...],
/// );
/// ```
///
/// Copied from [CalendarManagement].
@ProviderFor(CalendarManagement)
final calendarManagementProvider =
    AutoDisposeNotifierProvider<CalendarManagement, void>.internal(
  CalendarManagement.new,
  name: r'calendarManagementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarManagementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarManagement = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
