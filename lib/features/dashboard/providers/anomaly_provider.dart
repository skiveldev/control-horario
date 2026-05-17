import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admin/models/schedule_model.dart';
import '../models/anomaly_model.dart';
import '../models/time_record_model.dart';
import '../services/anomaly_service.dart';

/// Provider para el servicio de anomalías (sobreescribible en tests)
final anomalyServiceProvider = Provider<AnomalyService>((ref) {
  return const AnomalyService();
});

/// Datos necesarios para ejecutar la detección de anomalías mensual.
///
/// Agrupa todos los inputs que el provider necesita para no tener
/// dependencias internas con otros providers, facilitando el testing.
class MonthAnomalyParams {
  final String userId;
  final DateTime month;

  /// Horario semanal del empleado (null si no tiene horario asignado)
  final Map<String, DaySchedule>? schedule;

  /// Registros de tiempo (se filtran por mes internamente)
  final List<TimeRecordModel> records;

  /// Fechas de vacaciones en formato "YYYY-MM-DD"
  final Set<String> vacationDates;

  const MonthAnomalyParams({
    required this.userId,
    required this.month,
    this.schedule,
    this.records = const [],
    this.vacationDates = const {},
  });
}

/// Provider que detecta anomalías en los registros de un mes.
///
/// Usa [AnomalyService.detectAnomalies] internamente para encontrar los
/// 5 tipos de anomalías: missing-exit, insufficient-hours, unexcused-absence,
/// overlap y excessive-break. Los días de vacaciones y fines de semana se
/// excluyen automáticamente.
///
/// Ejemplo de uso:
/// ```dart
/// final anomalies = await ref.read(monthAnomaliesProvider(
///   MonthAnomalyParams(userId: id, month: now, schedule: sched, records: recs),
/// ).future);
/// ```
final monthAnomaliesProvider =
    FutureProvider.family<List<AnomalyModel>, MonthAnomalyParams>(
  (ref, params) async {
    final schedule = params.schedule;
    if (schedule == null) {
      return [];
    }

    final service = const AnomalyService();
    return service.detectAnomalies(
      userId: params.userId,
      month: params.month,
      records: params.records,
      weeklySchedule: schedule,
      vacationDates: params.vacationDates,
    );
  },
);
