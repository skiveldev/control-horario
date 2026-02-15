import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/schedule_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'schedule_management_provider.g.dart';

// ============================================================================
// LECTURA (Queries) - Stream providers
// ============================================================================

/// Stream de todas las plantillas de horario activas
///
/// Escucha cambios en tiempo real desde Firestore.
/// Usado en dropdowns y listas de selección de horarios.
///
/// Ejemplo de uso:
/// ```dart
/// final templatesAsync = ref.watch(allScheduleTemplatesProvider);
/// templatesAsync.when(
///   data: (templates) => DropdownMenu(items: templates),
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
@riverpod
Stream<List<ScheduleModel>> allScheduleTemplates(
  AllScheduleTemplatesRef ref,
) {
  final service = ref.watch(scheduleServiceProvider);
  return service.watchActiveTemplates();
}

/// Stream de plantilla específica por ID
///
/// Escucha cambios en tiempo real de una plantilla.
/// Retorna null si no existe o fue eliminada.
///
/// [scheduleId]: ID de la plantilla a observar
@riverpod
Stream<ScheduleModel?> scheduleById(
  ScheduleByIdRef ref,
  String scheduleId,
) {
  final service = ref.watch(scheduleServiceProvider);
  return service.watchScheduleById(scheduleId);
}

// ============================================================================
// ESCRITURA (Mutations) - Notifier para CRUD
// ============================================================================

/// Notifier para crear, editar y eliminar plantillas de horario
///
/// Responsabilidad:
/// - Validaciones de negocio
/// - Cálculos (total de horas)
/// - Llamadas a ScheduleService
/// - Manejo de estado (loading, error)
///
/// Ejemplo de uso:
/// ```dart
/// await ref.read(scheduleManagementProvider.notifier).createTemplate(
///   name: 'Jornada 40h (9-17)',
///   description: 'Lunes a Viernes',
///   weeklySchedule: {...},
/// );
/// ```
@riverpod
class ScheduleManagement extends _$ScheduleManagement {
  @override
  FutureOr<void> build() {
    // Estado inicial vacío
  }

  /// Crear nueva plantilla de horario
  ///
  /// Validaciones:
  /// - Nombre no vacío
  /// - Al menos un turno configurado (totalHours > 0)
  /// - Usuario autenticado
  ///
  /// [name]: Nombre descriptivo (ej: "Jornada 40h (9:00-17:00)")
  /// [description]: Descripción breve
  /// [weeklySchedule]: Configuración de horario semanal
  ///
  /// Retorna el scheduleId generado.
  /// Lanza excepción si falla la validación o creación.
  Future<String> createTemplate({
    required String name,
    required String description,
    required Map<String, DaySchedule> weeklySchedule,
  }) async {
    state = const AsyncLoading();

    try {
      // Validar usuario autenticado - ESPERAR a que cargue
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Validar nombre
      if (name.trim().isEmpty) {
        throw Exception('El nombre es obligatorio');
      }

      // Calcular horas semanales totales
      final totalHours = _calculateTotalWeeklyHours(weeklySchedule);

      // Validar que tenga al menos un turno
      if (totalHours <= 0) {
        throw Exception('Debe configurar al menos un turno de trabajo');
      }

      // Crear plantilla en Firestore
      final service = ref.read(scheduleServiceProvider);
      final scheduleId = await service.createTemplate(
        name: name,
        description: description,
        weeklySchedule: weeklySchedule,
        totalWeeklyHours: totalHours,
        createdBy: currentUser.userId,
      );

      state = const AsyncData(null);
      return scheduleId;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Actualizar plantilla existente
  ///
  /// Solo actualiza los campos proporcionados.
  /// Los parámetros null se ignoran (partial update).
  ///
  /// [scheduleId]: ID de la plantilla a actualizar
  /// [name]: Nuevo nombre (opcional)
  /// [description]: Nueva descripción (opcional)
  /// [weeklySchedule]: Nuevo horario semanal (opcional)
  Future<void> updateTemplate({
    required String scheduleId,
    String? name,
    String? description,
    Map<String, DaySchedule>? weeklySchedule,
  }) async {
    state = const AsyncLoading();

    try {
      // Validar usuario autenticado - ESPERAR a que cargue
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Calcular horas si se proporciona weeklySchedule
      int? totalHours;
      if (weeklySchedule != null) {
        totalHours = _calculateTotalWeeklyHours(weeklySchedule);
        if (totalHours <= 0) {
          throw Exception('Debe configurar al menos un turno de trabajo');
        }
      }

      // Actualizar en Firestore
      final service = ref.read(scheduleServiceProvider);
      await service.updateTemplate(
        scheduleId: scheduleId,
        lastModifiedBy: currentUser.userId,
        name: name,
        description: description,
        weeklySchedule: weeklySchedule,
        totalWeeklyHours: totalHours,
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Eliminar plantilla (soft delete)
  ///
  /// Marca isActive = false en lugar de borrar el documento.
  ///
  /// Validación:
  /// - No se puede eliminar si está siendo usada por empleados (usedByCount > 0)
  ///
  /// [scheduleId]: ID de la plantilla a eliminar
  Future<void> deleteTemplate(String scheduleId) async {
    state = const AsyncLoading();

    try {
      // Verificar que no esté en uso
      final template = await ref.read(scheduleByIdProvider(scheduleId).future);
      if (template != null && template.usedByCount > 0) {
        throw Exception(
          'No se puede eliminar: ${template.usedByCount} empleados están usando esta plantilla',
        );
      }

      // Eliminar (soft delete)
      final service = ref.read(scheduleServiceProvider);
      await service.deleteTemplate(scheduleId);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  // ==========================================================================
  // HELPERS PRIVADOS
  // ==========================================================================

  /// Calcular total de horas semanales
  ///
  /// Suma las horas de todos los días laborables.
  /// Redondea al entero más cercano.
  int _calculateTotalWeeklyHours(Map<String, DaySchedule> weekSchedule) {
    return weekSchedule.values
        .where((day) => day.isWorkDay)
        .fold(0.0, (sum, day) => sum + day.dailyHours)
        .round();
  }
}
