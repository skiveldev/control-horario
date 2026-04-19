import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/time_record_model.dart';

/// Servicio para gestionar registros de tiempo en Firestore
///
/// Maneja operaciones CRUD sobre la colección:
/// users/{userId}/time_records/{recordId}
class TimeRecordsService {
  final FirebaseFirestore? _firestore;

  TimeRecordsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  TimeRecordsService.test() : _firestore = null;

  FirebaseFirestore get _requireFirestore {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError(
        'TimeRecordsService test double must override Firestore access methods',
      );
    }
    return firestore;
  }

  /// Obtener referencia a la colección de registros de un usuario
  CollectionReference<Map<String, dynamic>> _getRecordsCollection(
    String userId,
  ) {
    return _requireFirestore
        .collection('users')
        .doc(userId)
        .collection('time_records');
  }

  /// Obtener registros de un mes específico
  Stream<List<TimeRecordModel>> getMonthRecords(
    String userId,
    DateTime month,
  ) {
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final startDateStr = _formatDate(startDate);
    final endDateStr = _formatDate(endDate);

    return _getRecordsCollection(userId)
        .where('date', isGreaterThanOrEqualTo: startDateStr)
        .where('date', isLessThanOrEqualTo: endDateStr)
        .orderBy('date')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TimeRecordModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Obtener registros de un día específico
  Stream<List<TimeRecordModel>> getDayRecords(
    String userId,
    DateTime date,
  ) {
    final dateStr = _formatDate(date);

    return _getRecordsCollection(userId)
        .where('date', isEqualTo: dateStr)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TimeRecordModel.fromFirestore(doc);
      }).toList();
    });
  }

  /// Obtener un registro específico
  Future<TimeRecordModel?> getRecord(String userId, String recordId) async {
    try {
      final doc = await _getRecordsCollection(userId).doc(recordId).get();
      if (doc.exists) {
        return TimeRecordModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener registro: $e');
    }
  }

  /// Añadir un nuevo registro
  Future<String> addRecord(TimeRecordModel record) async {
    try {
      final docRef = await _getRecordsCollection(record.userId).add(
        record.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Error al añadir registro: $e');
    }
  }

  /// Actualizar un registro existente
  Future<void> updateRecord(TimeRecordModel record) async {
    try {
      await _getRecordsCollection(record.userId).doc(record.id).update(
            record.toFirestore(),
          );
    } catch (e) {
      throw Exception('Error al actualizar registro: $e');
    }
  }

  /// Actualizar registro y crear nuevo en transacción atómica
  ///
  /// Garantiza que ambas operaciones se ejecuten o ninguna
  Future<String> updateAndCreateRecord({
    required TimeRecordModel recordToUpdate,
    required TimeRecordModel recordToCreate,
  }) async {
    try {
      final newDocRef = _getRecordsCollection(recordToCreate.userId).doc();

      await _requireFirestore.runTransaction((transaction) async {
        // 1. Actualizar registro existente
        final updateRef =
            _getRecordsCollection(recordToUpdate.userId).doc(recordToUpdate.id);
        transaction.update(
          updateRef,
          recordToUpdate.toFirestore(),
        );

        // 2. Crear nuevo registro
        transaction.set(
          newDocRef,
          recordToCreate.toFirestore(),
        );
      });

      return newDocRef.id;
    } catch (e) {
      throw Exception('Error en transacción: $e');
    }
  }

  /// Eliminar un registro
  ///
  /// No permite eliminar registros bloqueados
  Future<void> deleteRecord(String userId, String recordId) async {
    final record = await getRecord(userId, recordId);
    if (record != null && record.isBlocked) {
      throw Exception('No se puede eliminar un registro bloqueado');
    }

    try {
      await _getRecordsCollection(userId).doc(recordId).delete();
    } catch (e) {
      throw Exception('Error al eliminar registro: $e');
    }
  }

  /// Copiar un registro a otra fecha
  Future<String> copyRecord(
    String userId,
    String recordId,
    DateTime targetDate,
  ) async {
    final originalRecord = await getRecord(userId, recordId);
    if (originalRecord == null) {
      throw Exception('Registro original no encontrado');
    }
    if (originalRecord.isBlocked) {
      throw Exception('No se puede copiar un registro bloqueado');
    }

    try {
      // Crear nuevo registro con la nueva fecha
      final newRecord = TimeRecordModel(
        id: '', // Se generará al añadir
        userId: originalRecord.userId,
        date: _formatDate(targetDate),
        category: originalRecord.category,
        startTime: originalRecord.startTime,
        endTime: originalRecord.endTime,
        location: originalRecord.location,
        durationMinutes: originalRecord.durationMinutes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: originalRecord.userId,
        isManual: true,
        copiedFrom: recordId,
        recordStatus: RecordStatus.completed,
        validationStatus: ValidationStatus.editable,
      );

      return await addRecord(newRecord);
    } catch (e) {
      throw Exception('Error al copiar registro: $e');
    }
  }

  /// Verificar si un registro puede ser editado
  Future<bool> canEditRecord(String userId, String recordId) async {
    try {
      final record = await getRecord(userId, recordId);
      return record?.canEdit ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Validar un registro (solo admin)
  Future<void> validateRecord(
    String userId,
    String recordId,
    String validatedBy,
  ) async {
    try {
      await _getRecordsCollection(userId)
          .doc(recordId)
          .update(buildValidationAuditUpdate(validatedBy: validatedBy));
    } catch (e) {
      throw Exception('Error al validar registro: $e');
    }
  }

  /// Bloquear un registro (solo admin)
  Future<void> blockRecord(
    String userId,
    String recordId,
    String blockedBy, {
    String? reason,
  }) async {
    try {
      await _getRecordsCollection(userId).doc(recordId).update({
        'validationStatus': ValidationStatus.blocked.name,
        'blockedBy': blockedBy,
        'blockedAt': Timestamp.now(),
        if (reason != null) 'blockReason': reason,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al bloquear registro: $e');
    }
  }

  /// Desbloquear un registro (solo admin)
  Future<void> unblockRecord(String userId, String recordId) async {
    try {
      await _getRecordsCollection(userId).doc(recordId).update({
        'validationStatus': ValidationStatus.editable.name,
        'blockedBy': FieldValue.delete(),
        'blockedAt': FieldValue.delete(),
        'blockReason': FieldValue.delete(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al desbloquear registro: $e');
    }
  }

  /// Formatear fecha a string YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

Map<String, dynamic> buildValidationAuditUpdate({
  required String validatedBy,
  Object? validatedAt,
  Object? updatedAt,
}) {
  return {
    'validationStatus': ValidationStatus.validated.name,
    'validatedBy': validatedBy,
    'validatedAt': validatedAt ?? Timestamp.now(),
    'updatedAt': updatedAt ?? Timestamp.now(),
  };
}
