// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyRecordsHash() => r'787fad227452957143bfe00053f2b354c130ec91';

/// Provider para obtener registros del mes actual
///
/// Escucha en tiempo real todos los fichajes del mes desde time_records.
/// Ordena por fecha y hora de inicio.
///
/// Retorna lista vacía si no hay usuario autenticado.
///
/// Copied from [monthlyRecords].
@ProviderFor(monthlyRecords)
final monthlyRecordsProvider =
    AutoDisposeStreamProvider<List<TimeRecordModel>>.internal(
  monthlyRecords,
  name: r'monthlyRecordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyRecordsRef = AutoDisposeStreamProviderRef<List<TimeRecordModel>>;
String _$todayTotalMinutesHash() => r'2ec4969403914c9212316eb6445935e652cf8ff9';

/// Provider computado: Total de minutos trabajados hoy
///
/// Suma los minutos de todos los registros work del día (excluye pausas).
/// Retorna 0 si no hay registros.
///
/// Copied from [todayTotalMinutes].
@ProviderFor(todayTotalMinutes)
final todayTotalMinutesProvider = AutoDisposeProvider<int>.internal(
  todayTotalMinutes,
  name: r'todayTotalMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTotalMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTotalMinutesRef = AutoDisposeProviderRef<int>;
String _$monthTotalMinutesHash() => r'2bcfb8340629d69b8bc37b6cc0ff77f706d5114c';

/// Provider computado: Total de minutos trabajados en el mes
///
/// Suma todos los minutos de registros work del mes (excluye pausas).
/// Retorna 0 si no hay registros.
///
/// Copied from [monthTotalMinutes].
@ProviderFor(monthTotalMinutes)
final monthTotalMinutesProvider = AutoDisposeProvider<int>.internal(
  monthTotalMinutes,
  name: r'monthTotalMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthTotalMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthTotalMinutesRef = AutoDisposeProviderRef<int>;
String _$todayBreakMinutesHash() => r'9845ec41c6ab598468a76917c4c5b0670873c6a9';

/// Provider computado: Total de minutos en pausa hoy
///
/// Suma los minutos de todos los registros breakTime del día.
/// Retorna 0 si no hay pausas.
///
/// Copied from [todayBreakMinutes].
@ProviderFor(todayBreakMinutes)
final todayBreakMinutesProvider = AutoDisposeProvider<int>.internal(
  todayBreakMinutes,
  name: r'todayBreakMinutesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayBreakMinutesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayBreakMinutesRef = AutoDisposeProviderRef<int>;
String _$todayClockInTimeHash() => r'942f377eacda72b64898b5413549e39ddf025674';

/// Provider computado: Hora de entrada de hoy
///
/// Retorna el startTime del primer registro work del día.
/// Retorna null si no hay registros.
///
/// Copied from [todayClockInTime].
@ProviderFor(todayClockInTime)
final todayClockInTimeProvider = AutoDisposeProvider<String?>.internal(
  todayClockInTime,
  name: r'todayClockInTimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayClockInTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayClockInTimeRef = AutoDisposeProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
