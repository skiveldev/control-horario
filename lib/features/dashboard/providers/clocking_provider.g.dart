// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clocking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayRecordHash() => r'b3d6197094efcbd169e9105407be56c1cfd9e917';

/// Provider para obtener el registro de fichajes de hoy
///
/// Escucha en tiempo real el documento del día actual.
/// Retorna:
/// - null si no hay usuario autenticado o no hay fichajes hoy
/// - DailyRecordModel con los fichajes del día
///
/// Copied from [todayRecord].
@ProviderFor(todayRecord)
final todayRecordProvider =
    AutoDisposeStreamProvider<DailyRecordModel?>.internal(
      todayRecord,
      name: r'todayRecordProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayRecordHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayRecordRef = AutoDisposeStreamProviderRef<DailyRecordModel?>;
String _$clockingNotifierHash() => r'ad2369b570d5ad9a2104830017fe22e8304b0cac';

/// Notifier para acciones de fichaje
///
/// Maneja las operaciones de fichar entrada y salida.
/// Expone AsyncValue<void> como estado para manejar loading/error.
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
