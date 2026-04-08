import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/admin/models/work_calendar_model.dart';
import '../../features/admin/models/calendar_event_model.dart';

/// Servicio para operaciones CRUD de calendarios laborales en Firestore
///
/// Responsabilidad: Solo comunicación con Firebase, SIN lógica de negocio.
/// La lógica (validaciones) va en CalendarManagementProvider.
///
/// Colección: calendars/
///
/// Ejemplo de uso:
/// ```dart
/// final service = CalendarService(firestore);
/// final calendars = service.watchActiveCalendars();
/// ```
class CalendarService {
  final FirebaseFirestore _db;

  CalendarService(this._db);

  // ============================================================================
  // LECTURA (Queries)
  // ============================================================================

  /// Stream de todos los calendarios activos
  ///
  /// Escucha cambios en tiempo real de calendarios con isActive = true.
  /// Ordenados alfabéticamente por nombre en memoria.
  Stream<List<WorkCalendarModel>> watchActiveCalendars() {
    return _db
        .collection('calendars')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final calendars = snapshot.docs
          .map((doc) => WorkCalendarModel.fromFirestore(doc))
          .toList();

      // Ordenar en memoria (evita índice compuesto en Firestore)
      calendars.sort((a, b) => a.name.compareTo(b.name));

      return calendars;
    }).handleError((Object error, StackTrace stackTrace) {
      debugPrint('CalendarService.watchActiveCalendars error: $error');
      throw error;
    });
  }

  /// Stream de un calendario específico por ID
  ///
  /// Retorna null si no existe o fue eliminado.
  Stream<WorkCalendarModel?> watchCalendarById(String calendarId) {
    return _db
        .collection('calendars')
        .doc(calendarId)
        .snapshots()
        .map((doc) => doc.exists ? WorkCalendarModel.fromFirestore(doc) : null)
        .handleError((Object error, StackTrace stackTrace) {
      debugPrint(
          'CalendarService.watchCalendarById error [$calendarId]: $error');
      throw error;
    });
  }

  /// Obtener calendario (una sola vez, sin stream)
  Future<WorkCalendarModel?> getCalendarById(String calendarId) async {
    final doc = await _db.collection('calendars').doc(calendarId).get();
    return doc.exists ? WorkCalendarModel.fromFirestore(doc) : null;
  }

  // ============================================================================
  // ESCRITURA (Mutations)
  // ============================================================================

  /// Crear nuevo calendario laboral
  ///
  /// Genera un ID único y crea el documento en Firestore.
  /// Retorna el calendarId generado.
  ///
  /// [name]: Nombre descriptivo (ej: "Madrid 2025")
  /// [year]: Año del calendario
  /// [events]: Lista de eventos/festivos
  /// [createdBy]: userId del admin que crea el calendario
  Future<String> createCalendar({
    required String name,
    required int year,
    required List<CalendarEventModel> events,
    required String createdBy,
    bool isActive = true,
  }) async {
    final docRef = _db.collection('calendars').doc();

    final data = WorkCalendarModel(
      id: docRef.id,
      name: name,
      year: year,
      events: events,
      isActive: isActive,
    ).toFirestore();

    await docRef.set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    });

    return docRef.id;
  }

  /// Actualizar calendario existente
  ///
  /// Reemplaza nombre, año, isActive y lista de eventos completa.
  ///
  /// [calendarId]: ID del calendario a actualizar
  /// [modifiedBy]: userId del admin que edita
  Future<void> updateCalendar({
    required String calendarId,
    required String name,
    required int year,
    required List<CalendarEventModel> events,
    required bool isActive,
    required String modifiedBy,
  }) async {
    await _db.collection('calendars').doc(calendarId).update({
      'name': name,
      'year': year,
      'isActive': isActive,
      'events': events.map((e) => e.toMap()).toList(),
      'lastModifiedAt': FieldValue.serverTimestamp(),
      'lastModifiedBy': modifiedBy,
    });
  }

  /// Eliminar calendario (soft delete)
  ///
  /// Marca isActive = false para preservar histórico.
  Future<void> deleteCalendar(String calendarId) async {
    await _db.collection('calendars').doc(calendarId).update({
      'isActive': false,
      'lastModifiedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Duplicar un calendario existente
  ///
  /// Crea un nuevo documento con el mismo contenido, nombre con sufijo " (copia)"
  /// y el año actual.
  ///
  /// Retorna el ID del nuevo calendario.
  Future<String> duplicateCalendar({
    required String calendarId,
    required String createdBy,
  }) async {
    final original = await getCalendarById(calendarId);
    if (original == null) {
      throw Exception('Calendario no encontrado: $calendarId');
    }

    return createCalendar(
      name: '${original.name} (copia)',
      year: original.year,
      events: original.events,
      createdBy: createdBy,
    );
  }
}
