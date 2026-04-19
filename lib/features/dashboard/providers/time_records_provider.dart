import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
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

typedef TimeRecordValidationTargetLookup = Future<UserModel?> Function(
  String userId,
);

final timeRecordValidationTargetLookupProvider =
    Provider<TimeRecordValidationTargetLookup>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return (String userId) async {
    final targetDoc = await firestore.collection('users').doc(userId).get();
    if (!targetDoc.exists) {
      return null;
    }
    return UserModel.fromFirestore(targetDoc);
  };
});

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
    final service = ref.read(timeRecordsServiceProvider);
    // ✅ Ejecutar directamente, sin doble throw
    return await service.addRecord(record);
  }

  /// Actualizar un registro existente
  ///
  /// Si el registro estaba validado, cambia el estado a 'modified_after_validation'
  Future<void> updateRecord(TimeRecordModel record) async {
    final service = ref.read(timeRecordsServiceProvider);

    // Si estaba validado, cambiar a modificado post-validación
    final updatedRecord = record.isValidated &&
            record.validationStatus != ValidationStatus.modifiedAfterValidation
        ? record.copyWith(
            validationStatus: ValidationStatus.modifiedAfterValidation,
          )
        : record;

    // ✅ Ejecutar directamente, sin AsyncValue.guard que causa problemas
    await service.updateRecord(updatedRecord);
  }

  /// Eliminar un registro
  ///
  /// No permite eliminar registros bloqueados
  Future<void> deleteRecord(String userId, String recordId) async {
    final service = ref.read(timeRecordsServiceProvider);
    // ✅ Ejecutar directamente, sin doble throw
    await service.deleteRecord(userId, recordId);
  }

  /// Copiar un registro a otra fecha
  Future<String> copyRecord(
    String userId,
    String recordId,
    DateTime targetDate,
  ) async {
    final service = ref.read(timeRecordsServiceProvider);
    return await service.copyRecord(userId, recordId, targetDate);
  }

  /// Validar un registro (solo admin)
  Future<void> validateRecord(
    String userId,
    String recordId,
    String validatedBy,
  ) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || !user.isActive) {
      throw Exception(
          'Sin permisos: necesitas iniciar sesión para validar registros');
    }

    if (user.role != UserRole.admin) {
      if (!user.canSuperviseTeam) {
        throw Exception(
            'Sin permisos: solo administradores o supervisores pueden validar');
      }

      final lookupTargetUser =
          ref.read(timeRecordValidationTargetLookupProvider);
      final targetUser = await lookupTargetUser(userId);
      if (targetUser == null) {
        throw Exception('No se encontró el empleado a validar');
      }
      if (targetUser.supervisorId != user.userId) {
        throw Exception(
            'Sin permisos: solo puedes validar fichajes de tu propio equipo');
      }
    }

    final service = ref.read(timeRecordsServiceProvider);
    await service.validateRecord(userId, recordId, validatedBy);
  }

  /// Bloquear un registro (solo admin)
  Future<void> blockRecord(
    String userId,
    String recordId,
    String blockedBy, {
    String? reason,
  }) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || !user.isActive || user.role != UserRole.admin) {
      throw Exception(
          'Sin permisos: solo administradores activos pueden realizar esta acción');
    }
    final service = ref.read(timeRecordsServiceProvider);
    await service.blockRecord(userId, recordId, blockedBy, reason: reason);
  }

  /// Desbloquear un registro (solo admin)
  Future<void> unblockRecord(String userId, String recordId) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null || !user.isActive || user.role != UserRole.admin) {
      throw Exception(
          'Sin permisos: solo administradores activos pueden realizar esta acción');
    }
    final service = ref.read(timeRecordsServiceProvider);
    await service.unblockRecord(userId, recordId);
  }
}
