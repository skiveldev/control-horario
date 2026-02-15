import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/admin/models/schedule_model.dart';

/// Servicio para operaciones CRUD de plantillas de horario en Firestore
///
/// Responsabilidad: Solo comunicación con Firebase, SIN lógica de negocio compleja.
/// La lógica (validaciones, cálculos) va en los Providers (Riverpod).
///
/// Colección: schedules/
///
/// Ejemplo de uso:
/// ```dart
/// final service = ScheduleService(firestore);
/// final templates = await service.watchActiveTemplates().first;
/// ```
class ScheduleService {
  final FirebaseFirestore _db;

  ScheduleService(this._db);

  // ============================================================================
  // LECTURA (Queries)
  // ============================================================================

  /// Stream de todas las plantillas activas
  ///
  /// Escucha cambios en tiempo real de plantillas con:
  /// - isActive = true
  /// - isTemplate = true
  ///
  /// Ordenadas alfabéticamente por nombre.
  Stream<List<ScheduleModel>> watchActiveTemplates() {
    return _db
        .collection('schedules')
        .where('isActive', isEqualTo: true)
        .where('isTemplate', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final templates =
          snapshot.docs.map((doc) => ScheduleModel.fromFirestore(doc)).toList();

      // Ordenar en memoria (evita índice compuesto en Firestore)
      templates.sort((a, b) => a.name.compareTo(b.name));

      return templates;
    });
  }

  /// Stream de una plantilla específica por ID
  ///
  /// Escucha cambios en tiempo real de una plantilla.
  /// Retorna null si no existe o fue eliminada.
  Stream<ScheduleModel?> watchScheduleById(String scheduleId) {
    return _db
        .collection('schedules')
        .doc(scheduleId)
        .snapshots()
        .map((doc) => doc.exists ? ScheduleModel.fromFirestore(doc) : null);
  }

  /// Obtener plantilla (una sola vez, sin stream)
  ///
  /// Útil para operaciones donde no necesitas observar cambios.
  Future<ScheduleModel?> getScheduleById(String scheduleId) async {
    final doc = await _db.collection('schedules').doc(scheduleId).get();
    return doc.exists ? ScheduleModel.fromFirestore(doc) : null;
  }

  // ============================================================================
  // ESCRITURA (Mutations)
  // ============================================================================

  /// Crear nueva plantilla de horario
  ///
  /// Genera un ID único y crea el documento en Firestore.
  /// Retorna el scheduleId generado.
  ///
  /// [name]: Nombre descriptivo (ej: "Jornada 40h (9:00-17:00)")
  /// [description]: Descripción breve
  /// [weeklySchedule]: Configuración de cada día de la semana
  /// [totalWeeklyHours]: Total de horas semanales
  /// [createdBy]: userId del admin que crea la plantilla
  Future<String> createTemplate({
    required String name,
    required String description,
    required Map<String, DaySchedule> weeklySchedule,
    required int totalWeeklyHours,
    required String createdBy,
  }) async {
    final docRef = _db.collection('schedules').doc();

    await docRef.set({
      'scheduleId': docRef.id,
      'name': name,
      'description': description,
      'weeklySchedule': _serializeWeekSchedule(weeklySchedule),
      'totalWeeklyHours': totalWeeklyHours,
      'isActive': true,
      'isTemplate': true,
      'usedByCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    });

    return docRef.id;
  }

  /// Actualizar plantilla existente
  ///
  /// Solo actualiza los campos proporcionados (partial update).
  /// Los campos null se ignoran.
  Future<void> updateTemplate({
    required String scheduleId,
    required String lastModifiedBy,
    String? name,
    String? description,
    Map<String, DaySchedule>? weeklySchedule,
    int? totalWeeklyHours,
  }) async {
    final updates = <String, dynamic>{
      'lastModifiedAt': FieldValue.serverTimestamp(),
      'lastModifiedBy': lastModifiedBy,
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (totalWeeklyHours != null) {
      updates['totalWeeklyHours'] = totalWeeklyHours;
    }
    if (weeklySchedule != null) {
      updates['weeklySchedule'] = _serializeWeekSchedule(weeklySchedule);
    }

    await _db.collection('schedules').doc(scheduleId).update(updates);
  }

  /// Eliminar plantilla (soft delete)
  ///
  /// Marca isActive = false en lugar de borrar el documento.
  /// Esto preserva el histórico y evita romper referencias.
  Future<void> deleteTemplate(String scheduleId) async {
    await _db.collection('schedules').doc(scheduleId).update({
      'isActive': false,
      'lastModifiedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================================
  // CONTADORES (Tracking de uso)
  // ============================================================================

  /// Incrementar contador de empleados que usan la plantilla
  ///
  /// Se llama automáticamente cuando se asigna la plantilla a un empleado.
  Future<void> incrementUsageCount(String scheduleId) async {
    await _db.collection('schedules').doc(scheduleId).update({
      'usedByCount': FieldValue.increment(1),
    });
  }

  /// Decrementar contador de empleados que usan la plantilla
  ///
  /// Se llama cuando un empleado deja de usar la plantilla
  /// (cambia a otra plantilla o a horario custom).
  Future<void> decrementUsageCount(String scheduleId) async {
    await _db.collection('schedules').doc(scheduleId).update({
      'usedByCount': FieldValue.increment(-1),
    });
  }

  // ============================================================================
  // HELPERS PRIVADOS
  // ============================================================================

  /// Serializar weeklySchedule a formato Firestore
  ///
  /// Convierte Map<String, DaySchedule> a Map<String, dynamic>
  /// para guardarlo en Firestore.
  Map<String, dynamic> _serializeWeekSchedule(
    Map<String, DaySchedule> schedule,
  ) {
    return schedule.map((day, config) => MapEntry(
          day,
          {
            'isWorkDay': config.isWorkDay,
            'shifts': config.shifts
                .map((s) => {
                      'startTime': s.startTime,
                      'endTime': s.endTime,
                    })
                .toList(),
            'breakMinutes': config.breakMinutes,
            'dailyHours': config.dailyHours,
          },
        ));
  }
}
