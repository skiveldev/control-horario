// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clocking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayRecordsHash() => r'210e1a7f4bb9a50c7ad66d2fc7bd0c02f3008898';

/// Provider para obtener los registros de fichaje de hoy
///
/// Escucha en tiempo real los documentos en time_records del día actual.
/// Retorna lista de TimeRecordModel ordenados por startTime.
///
/// Copied from [todayRecords].
@ProviderFor(todayRecords)
final todayRecordsProvider =
    AutoDisposeStreamProvider<List<TimeRecordModel>>.internal(
  todayRecords,
  name: r'todayRecordsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayRecordsRef = AutoDisposeStreamProviderRef<List<TimeRecordModel>>;
String _$clockingSessionNotifierHash() =>
    r'7f9ce9eed940f6a4ce84351a1da0fd8197ebe9d9';

/// Provider para mantener el estado temporal del fichaje
///
/// Guarda el ID del registro activo para poder actualizarlo.
///
/// Copied from [ClockingSessionNotifier].
@ProviderFor(ClockingSessionNotifier)
final clockingSessionNotifierProvider = AutoDisposeNotifierProvider<
    ClockingSessionNotifier, ClockingSession>.internal(
  ClockingSessionNotifier.new,
  name: r'clockingSessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clockingSessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClockingSessionNotifier = AutoDisposeNotifier<ClockingSession>;
String _$clockingNotifierHash() => r'850877bcfbf0f8568fe11e8a880082f64dabe0a3';

/// Notifier para acciones de fichaje
///
/// OPCIÓN B: Registros inmediatos con actualizaciones
///
/// Flujo con pausa:
/// 1. clockIn → CREA registro work (09:00-09:00) "en curso"
/// 2. startBreak → ACTUALIZA registro anterior (09:00-12:30) + CREA breakTime (12:30-12:30)
/// 3. endBreak → ACTUALIZA registro pausa (12:30-13:00) + CREA work (13:00-13:00)
/// 4. clockOut → ACTUALIZA registro anterior (13:00-18:00)
///
/// Flujo sin pausa:
/// 1. clockIn → CREA registro work (09:00-09:00) "en curso"
/// 2. clockOut → ACTUALIZA registro (09:00-18:00)
///
/// Copied from [ClockingNotifier].
@ProviderFor(ClockingNotifier)
final clockingNotifierProvider =
    AutoDisposeNotifierProvider<ClockingNotifier, AsyncValue<void>>.internal(
  ClockingNotifier.new,
  name: r'clockingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clockingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClockingNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
