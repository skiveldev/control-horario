// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_schedule_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workScheduleStatusNotifierHash() =>
    r'f1434eaa95c8d2f9c452b221016eece2c1c6cf45';

/// Provider que calcula si el usuario está en horario laboral o fuera de horario
///
/// Lógica:
/// - Obtiene el horario del usuario desde auth
/// - Compara la hora actual con el rango de horario
/// - Retorna estado + fecha formateada en español
///
/// TODO [FASE-2]: Considerar:
/// - Días festivos y fines de semana
/// - Horarios flexibles o turnos
/// - Zonas horarias
///
/// Copied from [WorkScheduleStatusNotifier].
@ProviderFor(WorkScheduleStatusNotifier)
final workScheduleStatusNotifierProvider = AutoDisposeNotifierProvider<
    WorkScheduleStatusNotifier, WorkScheduleStatus>.internal(
  WorkScheduleStatusNotifier.new,
  name: r'workScheduleStatusNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workScheduleStatusNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WorkScheduleStatusNotifier = AutoDisposeNotifier<WorkScheduleStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
