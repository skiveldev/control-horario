import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/models/schedule_model.dart';
import '../models/time_record_model.dart';
import '../services/compliance_service.dart';

/// Datos necesarios para calcular el cumplimiento mensual.
///
/// Agrupa todos los inputs que el provider necesita para no tener
/// dependencias internas con otros providers, facilitando el testing.
class MonthComplianceParams {
  final String userId;
  final DateTime month;

  /// Horario semanal del empleado (null si no tiene horario asignado)
  final Map<String, DaySchedule>? schedule;

  /// Registros de tiempo del mes
  final List<TimeRecordModel> records;

  /// Fechas de vacaciones en formato "YYYY-MM-DD"
  final Set<String> vacationDates;

  /// Tolerancia en minutos para considerar cumplimiento (default: 15)
  final int toleranceMinutes;

  const MonthComplianceParams({
    required this.userId,
    required this.month,
    this.schedule,
    this.records = const [],
    this.vacationDates = const {},
    this.toleranceMinutes = 15,
  });
}

/// Provider que calcula el cumplimiento horario por día para un mes.
///
/// Usa [ComplianceService.computeDayCompliance] internamente para cada día
/// laborable del mes. Los días de vacaciones y no laborables se marcan
/// como [ComplianceStatus.noRecord].
///
/// Ejemplo de uso:
/// ```dart
/// final compliance = await ref.read(monthComplianceProvider(
///   MonthComplianceParams(userId: id, month: now, schedule: sched, records: recs),
/// ).future);
/// ```
final monthComplianceProvider =
    FutureProvider.family<Map<String, DayCompliance>, MonthComplianceParams>(
  (ref, params) async {
    final schedule = params.schedule;
    if (schedule == null) {
      return {};
    }

    final service = const ComplianceService();
    final result = <String, DayCompliance>{};

    // Días de la semana en orden (lunes=1 → monday, domingo=7 → sunday)
    const dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    final daysInMonth = _daysInMonth(params.month.year, params.month.month);
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(params.month.year, params.month.month, day);
      final dateStr = _formatDate(date);
      final dayName = dayNames[date.weekday - 1];

      final daySchedule =
          schedule[dayName] ?? const DaySchedule(isWorkDay: false);

      final dayRecords =
          params.records.where((r) => r.date == dateStr).toList();
      final isVacation = params.vacationDates.contains(dateStr);

      final compliance = service.computeDayCompliance(
        date: dateStr,
        daySchedule: daySchedule,
        records: dayRecords,
        toleranceMinutes: params.toleranceMinutes,
        isVacationDay: isVacation,
      );

      result[dateStr] = compliance;
    }

    return result;
  },
);

/// Número de días en un mes
int _daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}

/// Formatea DateTime a "YYYY-MM-DD"
String _formatDate(DateTime date) {
  return '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
