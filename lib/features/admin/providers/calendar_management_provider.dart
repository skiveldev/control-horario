import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/work_calendar_model.dart';
import '../models/calendar_event_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'calendar_management_provider.g.dart';

// ============================================================================
// LECTURA (Queries) - Stream providers
// ============================================================================

/// Stream de todos los calendarios laborales activos
///
/// Escucha cambios en tiempo real desde Firestore.
/// Usado en la lista de calendarios y en dropdowns de asignación.
///
/// Ejemplo de uso:
/// ```dart
/// final calendarsAsync = ref.watch(allCalendarsProvider);
/// calendarsAsync.when(
///   data: (calendars) => ListView(children: calendars.map(...).toList()),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
@riverpod
Stream<List<WorkCalendarModel>> allCalendars(AllCalendarsRef ref) {
  final service = ref.watch(calendarServiceProvider);
  return service.watchActiveCalendars();
}

/// Stream de un calendario específico por ID
///
/// Retorna null si no existe o fue eliminado.
///
/// [calendarId]: ID del calendario a observar
@riverpod
Stream<WorkCalendarModel?> calendarById(
  CalendarByIdRef ref,
  String calendarId,
) {
  final service = ref.watch(calendarServiceProvider);
  return service.watchCalendarById(calendarId);
}

// ============================================================================
// ESCRITURA (Mutations) - Notifier para CRUD
// ============================================================================

/// Notifier para crear, editar, duplicar y eliminar calendarios laborales
///
/// Responsabilidad:
/// - Validaciones de negocio
/// - Llamadas a CalendarService
/// - Manejo de estado (loading, error)
///
/// Ejemplo de uso:
/// ```dart
/// await ref.read(calendarManagementProvider.notifier).saveCalendar(
///   calendarId: null, // null = crear nuevo
///   name: 'Madrid 2026',
///   year: 2026,
///   events: [...],
/// );
/// ```
@riverpod
class CalendarManagement extends _$CalendarManagement {
  @override
  void build() {
    // Sin estado gestionado — las operaciones son fire-and-throw
  }

  /// Guardar calendario (crear o actualizar)
  ///
  /// Si [calendarId] es null → crea un nuevo calendario.
  /// Si [calendarId] tiene valor → actualiza el existente.
  ///
  /// Retorna el ID del calendario guardado.
  /// Lanza excepción si falla la validación o la escritura en Firestore.
  Future<String> saveCalendar({
    required String? calendarId,
    required String name,
    required int year,
    required List<CalendarEventModel> events,
    bool isActive = true,
  }) async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    if (name.trim().isEmpty) {
      throw Exception('El nombre del calendario es obligatorio');
    }

    if (year < 2000 || year > 2100) {
      throw Exception('El año debe estar entre 2000 y 2100');
    }

    final service = ref.read(calendarServiceProvider);

    if (calendarId == null) {
      return service.createCalendar(
        name: name.trim(),
        year: year,
        events: events,
        isActive: isActive,
        createdBy: currentUser.userId,
      );
    } else {
      await service.updateCalendar(
        calendarId: calendarId,
        name: name.trim(),
        year: year,
        events: events,
        isActive: isActive,
        modifiedBy: currentUser.userId,
      );
      return calendarId;
    }
  }

  /// Eliminar calendario (soft delete)
  ///
  /// Marca isActive = false en lugar de borrar el documento.
  Future<void> deleteCalendar(String calendarId) async {
    final service = ref.read(calendarServiceProvider);
    await service.deleteCalendar(calendarId);
  }

  /// Duplicar un calendario existente
  ///
  /// Crea una copia con nombre " (copia)" y el año del original.
  /// Retorna el ID del nuevo calendario.
  Future<String> duplicateCalendar(String calendarId) async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final service = ref.read(calendarServiceProvider);
    return service.duplicateCalendar(
      calendarId: calendarId,
      createdBy: currentUser.userId,
    );
  }
}
