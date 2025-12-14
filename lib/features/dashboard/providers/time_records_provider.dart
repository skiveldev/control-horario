import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/time_record_model.dart';
import '../services/time_records_service.dart';

part 'time_records_provider.g.dart';

/// Provider del servicio de registros de tiempo
@riverpod
TimeRecordsService timeRecordsService(TimeRecordsServiceRef ref) {
  return TimeRecordsService();
}

/// Provider para obtener registros de un mes
@riverpod
Stream<List<TimeRecordModel>> monthTimeRecords(
  MonthTimeRecordsRef ref, {
  required String userId,
  required DateTime month,
}) {
  final service = ref.watch(timeRecordsServiceProvider);
  return service.getMonthRecords(userId, month);
}

/// Provider para obtener registros de un día
@riverpod
Stream<List<TimeRecordModel>> dayTimeRecords(
  DayTimeRecordsRef ref, {
  required String userId,
  required DateTime date,
}) {
  final service = ref.watch(timeRecordsServiceProvider);
  return service.getDayRecords(userId, date);
}

/// Provider para obtener un registro específico
@riverpod
Future<TimeRecordModel?> timeRecord(
  TimeRecordRef ref, {
  required String userId,
  required String recordId,
}) {
  final service = ref.watch(timeRecordsServiceProvider);
  return service.getRecord(userId, recordId);
}

/// Provider para verificar si un registro puede ser editado
@riverpod
Future<bool> canEditRecord(
  CanEditRecordRef ref, {
  required String userId,
  required String recordId,
}) {
  final service = ref.watch(timeRecordsServiceProvider);
  return service.canEditRecord(userId, recordId);
}

/// Notifier para operaciones CRUD sobre registros
@riverpod
class TimeRecordsNotifier extends _$TimeRecordsNotifier {
  @override
  FutureOr<String?> build() {
    // State inicial null
    return null;
  }

  /// Añadir un nuevo registro
  Future<String> addRecord(TimeRecordModel record) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(() async {
      final service = ref.read(timeRecordsServiceProvider);
      return await service.addRecord(record);
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }

    return result.value!;
  }

  /// Actualizar un registro existente
  ///
  /// Si el registro estaba validado, cambia el estado a 'modified_after_validation'
  Future<void> updateRecord(TimeRecordModel record) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(timeRecordsServiceProvider);

      // Si estaba validado, cambiar a modificado post-validación
      final updatedRecord = record.isValidated &&
              record.validationStatus !=
                  ValidationStatus.modifiedAfterValidation
          ? record.copyWith(
              validationStatus: ValidationStatus.modifiedAfterValidation,
            )
          : record;

      await service.updateRecord(updatedRecord);
      return null;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  /// Eliminar un registro
  ///
  /// No permite eliminar registros bloqueados
  Future<void> deleteRecord(String userId, String recordId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(timeRecordsServiceProvider);
      await service.deleteRecord(userId, recordId);
      return null;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  /// Copiar un registro a otra fecha
  Future<String> copyRecord(
    String userId,
    String recordId,
    DateTime targetDate,
  ) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(() async {
      final service = ref.read(timeRecordsServiceProvider);
      return await service.copyRecord(
        userId,
        recordId,
        targetDate,
      );
    });

    state = result;

    if (result.hasError) {
      throw result.error!;
    }

    return result.value!;
  }

  /// Validar un registro (solo admin)
  Future<void> validateRecord(
    String userId,
    String recordId,
    String validatedBy,
  ) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(timeRecordsServiceProvider);
      await service.validateRecord(userId, recordId, validatedBy);
      return null;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  /// Bloquear un registro (solo admin)
  Future<void> blockRecord(
    String userId,
    String recordId,
    String blockedBy, {
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(timeRecordsServiceProvider);
      await service.blockRecord(
        userId,
        recordId,
        blockedBy,
        reason: reason,
      );
      return null;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  /// Desbloquear un registro (solo admin)
  Future<void> unblockRecord(String userId, String recordId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(timeRecordsServiceProvider);
      await service.unblockRecord(userId, recordId);
      return null;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}
