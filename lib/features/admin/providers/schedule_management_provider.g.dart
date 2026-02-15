// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allScheduleTemplatesHash() =>
    r'cd801a5c6c467e3ad2aaacd032926cfdad939ca1';

/// Stream de todas las plantillas de horario activas
///
/// Escucha cambios en tiempo real desde Firestore.
/// Usado en dropdowns y listas de selección de horarios.
///
/// Ejemplo de uso:
/// ```dart
/// final templatesAsync = ref.watch(allScheduleTemplatesProvider);
/// templatesAsync.when(
///   data: (templates) => DropdownMenu(items: templates),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
///
/// Copied from [allScheduleTemplates].
@ProviderFor(allScheduleTemplates)
final allScheduleTemplatesProvider =
    AutoDisposeStreamProvider<List<ScheduleModel>>.internal(
  allScheduleTemplates,
  name: r'allScheduleTemplatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allScheduleTemplatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllScheduleTemplatesRef
    = AutoDisposeStreamProviderRef<List<ScheduleModel>>;
String _$scheduleByIdHash() => r'4e112211db543ad646537be3d1e052faf736a93a';

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

/// Stream de plantilla específica por ID
///
/// Escucha cambios en tiempo real de una plantilla.
/// Retorna null si no existe o fue eliminada.
///
/// [scheduleId]: ID de la plantilla a observar
///
/// Copied from [scheduleById].
@ProviderFor(scheduleById)
const scheduleByIdProvider = ScheduleByIdFamily();

/// Stream de plantilla específica por ID
///
/// Escucha cambios en tiempo real de una plantilla.
/// Retorna null si no existe o fue eliminada.
///
/// [scheduleId]: ID de la plantilla a observar
///
/// Copied from [scheduleById].
class ScheduleByIdFamily extends Family<AsyncValue<ScheduleModel?>> {
  /// Stream de plantilla específica por ID
  ///
  /// Escucha cambios en tiempo real de una plantilla.
  /// Retorna null si no existe o fue eliminada.
  ///
  /// [scheduleId]: ID de la plantilla a observar
  ///
  /// Copied from [scheduleById].
  const ScheduleByIdFamily();

  /// Stream de plantilla específica por ID
  ///
  /// Escucha cambios en tiempo real de una plantilla.
  /// Retorna null si no existe o fue eliminada.
  ///
  /// [scheduleId]: ID de la plantilla a observar
  ///
  /// Copied from [scheduleById].
  ScheduleByIdProvider call(
    String scheduleId,
  ) {
    return ScheduleByIdProvider(
      scheduleId,
    );
  }

  @override
  ScheduleByIdProvider getProviderOverride(
    covariant ScheduleByIdProvider provider,
  ) {
    return call(
      provider.scheduleId,
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
  String? get name => r'scheduleByIdProvider';
}

/// Stream de plantilla específica por ID
///
/// Escucha cambios en tiempo real de una plantilla.
/// Retorna null si no existe o fue eliminada.
///
/// [scheduleId]: ID de la plantilla a observar
///
/// Copied from [scheduleById].
class ScheduleByIdProvider extends AutoDisposeStreamProvider<ScheduleModel?> {
  /// Stream de plantilla específica por ID
  ///
  /// Escucha cambios en tiempo real de una plantilla.
  /// Retorna null si no existe o fue eliminada.
  ///
  /// [scheduleId]: ID de la plantilla a observar
  ///
  /// Copied from [scheduleById].
  ScheduleByIdProvider(
    String scheduleId,
  ) : this._internal(
          (ref) => scheduleById(
            ref as ScheduleByIdRef,
            scheduleId,
          ),
          from: scheduleByIdProvider,
          name: r'scheduleByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$scheduleByIdHash,
          dependencies: ScheduleByIdFamily._dependencies,
          allTransitiveDependencies:
              ScheduleByIdFamily._allTransitiveDependencies,
          scheduleId: scheduleId,
        );

  ScheduleByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scheduleId,
  }) : super.internal();

  final String scheduleId;

  @override
  Override overrideWith(
    Stream<ScheduleModel?> Function(ScheduleByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ScheduleByIdProvider._internal(
        (ref) => create(ref as ScheduleByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scheduleId: scheduleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ScheduleModel?> createElement() {
    return _ScheduleByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduleByIdProvider && other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scheduleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ScheduleByIdRef on AutoDisposeStreamProviderRef<ScheduleModel?> {
  /// The parameter `scheduleId` of this provider.
  String get scheduleId;
}

class _ScheduleByIdProviderElement
    extends AutoDisposeStreamProviderElement<ScheduleModel?>
    with ScheduleByIdRef {
  _ScheduleByIdProviderElement(super.provider);

  @override
  String get scheduleId => (origin as ScheduleByIdProvider).scheduleId;
}

String _$scheduleManagementHash() =>
    r'987829443cbb4150977628d41640896097b1f651';

/// Notifier para crear, editar y eliminar plantillas de horario
///
/// Responsabilidad:
/// - Validaciones de negocio
/// - Cálculos (total de horas)
/// - Llamadas a ScheduleService
/// - Manejo de estado (loading, error)
///
/// Ejemplo de uso:
/// ```dart
/// await ref.read(scheduleManagementProvider.notifier).createTemplate(
///   name: 'Jornada 40h (9-17)',
///   description: 'Lunes a Viernes',
///   weeklySchedule: {...},
/// );
/// ```
///
/// Copied from [ScheduleManagement].
@ProviderFor(ScheduleManagement)
final scheduleManagementProvider =
    AutoDisposeAsyncNotifierProvider<ScheduleManagement, void>.internal(
  ScheduleManagement.new,
  name: r'scheduleManagementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleManagementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScheduleManagement = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
