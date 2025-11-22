// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyRecordsHash() => r'0af101e9386d36315fcb43d5ad0fd8d79ea2617f';

/// Provider para obtener registros del mes actual
///
/// Escucha en tiempo real todos los fichajes del mes.
/// Ordena por fecha descendente (más recientes primero).
///
/// Retorna lista vacía si no hay usuario autenticado.
///
/// Copied from [monthlyRecords].
@ProviderFor(monthlyRecords)
final monthlyRecordsProvider =
    AutoDisposeStreamProvider<List<DailyRecordModel>>.internal(
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
typedef MonthlyRecordsRef =
    AutoDisposeStreamProviderRef<List<DailyRecordModel>>;
String _$todayTotalMinutesHash() => r'd6f2a815fd5e5b850b1d52ebca16e04b1a9893b9';

/// Provider computado: Total de minutos trabajados hoy
///
/// Calcula la diferencia entre entrada y salida del día actual.
/// Retorna 0 si:
/// - No hay registro hoy
/// - Falta entrada o salida
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
String _$monthTotalMinutesHash() => r'78d5b81ef9f49a3dfd4a8476268e0e382ca483a2';

/// Provider computado: Total de minutos trabajados en el mes
///
/// Suma todos los minutos de registros completos del mes.
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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
