import '../../admin/models/schedule_model.dart';
import '../models/anomaly_model.dart';
import '../models/time_record_model.dart';

/// Servicio de detección de anomalías en registros de tiempo
///
/// Servicio puro (sin dependencia de Firestore) que analiza los registros
/// de fichaje de un mes y detecta 5 tipos de anomalías: salida faltante,
/// horas insuficientes, ausencia no justificada, solapamiento y pausa excesiva.
class AnomalyService {
  const AnomalyService();

  /// Detecta anomalías en los registros de un mes para un empleado
  ///
  /// [userId] — ID del empleado
  /// [month] — mes a analizar (se usa año y mes)
  /// [records] — todos los registros del empleado (se filtran por mes)
  /// [weeklySchedule] — horario semanal (lunes a domingo)
  /// [vacationDates] — fechas de vacaciones en formato "YYYY-MM-DD"
  List<AnomalyModel> detectAnomalies({
    required String userId,
    required DateTime month,
    required List<TimeRecordModel> records,
    required Map<String, DaySchedule> weeklySchedule,
    required Set<String> vacationDates,
  }) {
    final anomalies = <AnomalyModel>[];

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

    // Iterar sobre cada día del mes
    final daysInMonth = _daysInMonth(month.year, month.month);
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final dateStr = _formatDate(date);
      final dayName = dayNames[date.weekday - 1];

      // Vacation days are excluded from anomaly detection
      if (vacationDates.contains(dateStr)) continue;

      final daySchedule = weeklySchedule[dayName];
      if (daySchedule == null || !daySchedule.isWorkDay) continue;

      // Filter records for this date
      final dayRecords = records.where((r) => r.date == dateStr).toList();

      // Work records only
      final workRecords =
          dayRecords.where((r) => r.category == RecordCategory.work).toList();

      // Break records only
      final breakRecords = dayRecords
          .where((r) => r.category == RecordCategory.breakTime)
          .toList();

      // 1. Missing exit: any work record still active
      for (final record in workRecords) {
        if (record.recordStatus == RecordStatus.active) {
          anomalies.add(_createAnomaly(
            userId: userId,
            date: dateStr,
            type: AnomalyType.missingExit,
            severity: AnomalySeverity.high,
            description: 'Fichaje activo sin salida registrada '
                '(inicio: ${record.startTime})',
          ));
        }
      }

      // 2. Unexcused absence: no work records on a work day
      if (workRecords.isEmpty) {
        anomalies.add(_createAnomaly(
          userId: userId,
          date: dateStr,
          type: AnomalyType.unexcusedAbsence,
          severity: AnomalySeverity.high,
          description: 'Sin registros de fichaje en día laborable',
        ));
        // No further checks needed for this day since there are no records
        continue;
      }

      // 3. Insufficient hours
      final totalWorkMinutes =
          workRecords.fold<int>(0, (sum, r) => sum + r.durationMinutes);
      final expectedMinutes = (daySchedule.dailyHours * 60).round();
      if (totalWorkMinutes < expectedMinutes) {
        final hoursActual = totalWorkMinutes / 60;
        final hoursExpected = expectedMinutes / 60;
        anomalies.add(_createAnomaly(
          userId: userId,
          date: dateStr,
          type: AnomalyType.insufficientHours,
          severity: totalWorkMinutes < expectedMinutes * 0.5
              ? AnomalySeverity.high
              : AnomalySeverity.medium,
          description:
              'Horas insuficientes: ${hoursActual.toStringAsFixed(1)}h trabajadas '
              'de ${hoursExpected.toStringAsFixed(1)}h esperadas',
        ));
      }

      // 4. Overlap: any two work records with overlapping time ranges
      if (workRecords.length >= 2) {
        // Sort by startTime
        final sorted = List<TimeRecordModel>.from(workRecords)
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        for (var i = 0; i < sorted.length - 1; i++) {
          for (var j = i + 1; j < sorted.length; j++) {
            if (_timeRangesOverlap(
              sorted[i].startTime,
              sorted[i].endTime,
              sorted[j].startTime,
              sorted[j].endTime,
            )) {
              anomalies.add(_createAnomaly(
                userId: userId,
                date: dateStr,
                type: AnomalyType.overlap,
                severity: AnomalySeverity.medium,
                description: 'Solapamiento entre registros: '
                    '${sorted[i].startTime}-${sorted[i].endTime} '
                    'y ${sorted[j].startTime}-${sorted[j].endTime}',
              ));
              // Only flag one overlap per day
              break;
            }
          }
        }
      }

      // 5. Excessive break
      final totalBreakMinutes =
          breakRecords.fold<int>(0, (sum, r) => sum + r.durationMinutes);
      final maxAllowedBreak = daySchedule.breakMinutes + 30;
      if (totalBreakMinutes > maxAllowedBreak) {
        anomalies.add(_createAnomaly(
          userId: userId,
          date: dateStr,
          type: AnomalyType.excessiveBreak,
          severity: AnomalySeverity.low,
          description: 'Pausa excesiva: ${totalBreakMinutes}min '
              '(máximo permitido: ${maxAllowedBreak}min)',
        ));
      }
    }

    return anomalies;
  }

  /// Crea un modelo de anomalía con valores por defecto
  AnomalyModel _createAnomaly({
    required String userId,
    required String date,
    required AnomalyType type,
    required AnomalySeverity severity,
    String? description,
  }) {
    return AnomalyModel(
      id: '${type.name}-$userId-$date',
      userId: userId,
      date: date,
      type: type,
      severity: severity,
      createdAt: DateTime.now(),
      description: description,
    );
  }

  /// Verifica si dos rangos de tiempo se solapan
  /// Los tiempos vienen en formato "HH:mm"
  bool _timeRangesOverlap(
    String start1,
    String end1,
    String start2,
    String end2,
  ) {
    final s1 = _parseTime(start1);
    final e1 = _parseTime(end1);
    final s2 = _parseTime(start2);
    final e2 = _parseTime(end2);

    // Overlap if start1 < end2 AND start2 < end1
    return s1 < e2 && s2 < e1;
  }

  /// Convierte "HH:mm" a minutos desde medianoche
  static int _parseTime(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  /// Número de días en un mes
  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Formatea DateTime a "YYYY-MM-DD"
  static String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
