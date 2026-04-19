// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clocking_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentClockingStateHash() =>
    r'47648c4235a9dc063b67db456fa511d44c66bbea';

/// Provider que calcula el estado actual del fichaje
///
/// Usa el campo `recordStatus` para determinar si un registro está activo.
/// Esto es independiente de la duración (puedes fichar entrada/salida en el mismo minuto).
///
/// Lógica:
/// 1. No hay registros → notStarted
/// 2. Hay registro activo work → working
/// 3. Hay registro activo breakTime → onBreak
/// 4. Hay pausa completada + registro activo work → backFromBreak
/// 5. Todos los registros completados → finished
///
/// Uso:
/// ```dart
/// final state = ref.watch(currentClockingStateProvider);
/// if (state == ClockingState.working) {
///   // Mostrar botón "INICIAR PAUSA"
/// }
/// ```
///
/// Copied from [currentClockingState].
@ProviderFor(currentClockingState)
final currentClockingStateProvider =
    AutoDisposeProvider<ClockingState>.internal(
  currentClockingState,
  name: r'currentClockingStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentClockingStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentClockingStateRef = AutoDisposeProviderRef<ClockingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
