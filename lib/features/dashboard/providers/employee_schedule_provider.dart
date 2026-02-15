import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../admin/providers/schedule_management_provider.dart';
import '../../admin/models/schedule_model.dart';
import '../../auth/providers/auth_provider.dart';

part 'employee_schedule_provider.g.dart';

/// Datos completos del horario de un empleado
///
/// Unifica el horario independientemente de si usa plantilla o custom.
class EmployeeScheduleData {
  /// Tipo de horario: "template" (plantilla) o "custom" (personalizado)
  final String type;

  /// Nombre descriptivo del horario
  final String templateName;

  /// Horas semanales totales
  final int weeklyHours;

  /// Configuración detallada de cada día
  final Map<String, DaySchedule> schedule;

  EmployeeScheduleData({
    required this.type,
    required this.templateName,
    required this.weeklyHours,
    required this.schedule,
  });
}

/// Provider que obtiene el horario completo del empleado
///
/// Combina datos del usuario (scheduleId/customSchedule) con plantillas de Firestore.
///
/// Casos:
/// 1. Usuario usa plantilla (scheduleType = "template")
///    → Obtiene plantilla desde schedules/{scheduleId}
///
/// 2. Usuario tiene horario personalizado (scheduleType = "custom")
///    → Usa customSchedule embebido en su documento
///
/// 3. Usuario sin horario
///    → Retorna null
///
/// Ejemplo de uso:
/// ```dart
/// final scheduleAsync = ref.watch(employeeFullScheduleProvider(userId));
/// scheduleAsync.when(
///   data: (schedule) {
///     if (schedule == null) return Text('Sin horario');
///     return Text('${schedule.templateName} (${schedule.weeklyHours}h)');
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
@riverpod
Future<EmployeeScheduleData?> employeeFullSchedule(
  EmployeeFullScheduleRef ref,
  String userId,
) async {
  // Obtener datos del usuario
  final user = await ref.watch(userByIdProvider(userId).future);

  if (user == null) {
    return null;
  }

  // CASO 1: Usuario usa plantilla
  if (user.scheduleType == 'template' && user.scheduleId != null) {
    // Obtener plantilla
    final template =
        await ref.watch(scheduleByIdProvider(user.scheduleId!).future);

    if (template == null) {
      // Plantilla no existe o fue eliminada
      return null;
    }

    return EmployeeScheduleData(
      type: 'template',
      templateName: template.name,
      weeklyHours: template.totalWeeklyHours,
      schedule: template.weeklySchedule,
    );
  }
  // CASO 2: Usuario tiene horario personalizado
  else if (user.scheduleType == 'custom' && user.customSchedule != null) {
    final customSchedule = _parseCustomSchedule(user.customSchedule!);
    return EmployeeScheduleData(
      type: 'custom',
      templateName: 'Horario personalizado',
      weeklyHours: user.weeklyHours.round(),
      schedule: customSchedule,
    );
  }
  // CASO 3: Usuario sin horario
  else {
    return null;
  }
}

// ============================================================================
// HELPERS PRIVADOS
// ============================================================================

/// Convertir customSchedule de Map<String, dynamic> a Map<String, DaySchedule>
///
/// El customSchedule viene como JSON desde Firestore.
/// Lo parseamos a objetos DaySchedule para mantener consistencia
/// con las plantillas.
Map<String, DaySchedule> _parseCustomSchedule(Map<String, dynamic> data) {
  return data.map((day, config) {
    final dayData = config as Map<String, dynamic>;

    // Parsear shifts
    final shiftsData = dayData['shifts'] as List<dynamic>? ?? [];
    final shifts = shiftsData.map((s) {
      final shiftMap = s as Map<String, dynamic>;
      return TimeShift(
        startTime: shiftMap['startTime'] as String? ?? '00:00',
        endTime: shiftMap['endTime'] as String? ?? '00:00',
      );
    }).toList();

    return MapEntry(
      day,
      DaySchedule(
        isWorkDay: dayData['isWorkDay'] as bool? ?? false,
        shifts: shifts,
        breakMinutes: dayData['breakMinutes'] as int? ?? 0,
        dailyHours: (dayData['dailyHours'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  });
}
