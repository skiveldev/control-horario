import '../../admin/models/schedule_model.dart';
import '../models/time_record_model.dart';

/// Resultado de cumplimiento para un día
class DayCompliance {
  final String date;
  final ComplianceStatus status;
  final int? expectedMinutes;
  final int? actualMinutes;
  final int deviationMinutes;

  const DayCompliance({
    required this.date,
    required this.status,
    this.expectedMinutes,
    this.actualMinutes,
    this.deviationMinutes = 0,
  });
}

/// Estado de cumplimiento horario
enum ComplianceStatus {
  /// El empleado fichó dentro de la tolerancia permitida
  compliant,

  /// El empleado fichó fuera de la tolerancia permitida
  deviated,

  /// Sin datos: día no laborable, vacaciones o sin registros
  noRecord,
}

/// Servicio de cumplimiento horario
///
/// Servicio puro (sin dependencia de Firestore) que compara los turnos
/// asignados del horario contra los registros reales de fichaje con una
/// tolerancia configurable.
class ComplianceService {
  const ComplianceService();

  /// Calcula el cumplimiento para un día específico
  ///
  /// [date] — fecha en formato "YYYY-MM-DD"
  /// [daySchedule] — configuración del día según el horario asignado
  /// [records] — registros de tiempo reales para esa fecha
  /// [toleranceMinutes] — margen de tolerancia en minutos (default: 15)
  /// [isVacationDay] — si el día está marcado como vacaciones (excluido)
  DayCompliance computeDayCompliance({
    required String date,
    required DaySchedule daySchedule,
    required List<TimeRecordModel> records,
    required int toleranceMinutes,
    required bool isVacationDay,
  }) {
    // Vacation days are excluded from compliance
    if (isVacationDay) {
      return DayCompliance(date: date, status: ComplianceStatus.noRecord);
    }

    // Non-work days have no expected hours
    if (!daySchedule.isWorkDay) {
      return DayCompliance(date: date, status: ComplianceStatus.noRecord);
    }

    // Only consider work records (ignore breakTime)
    final workRecords =
        records.where((r) => r.category == RecordCategory.work).toList();

    // No work records on a work day
    if (workRecords.isEmpty) {
      return DayCompliance(date: date, status: ComplianceStatus.noRecord);
    }

    final shifts = daySchedule.shifts;
    if (shifts.isEmpty) {
      return DayCompliance(date: date, status: ComplianceStatus.noRecord);
    }

    // Expected minutes from schedule (dailyHours * 60)
    final expectedTotal = daySchedule.dailyHours * 60;

    // Actual minutes from work records
    final actualTotal =
        workRecords.fold<int>(0, (sum, r) => sum + r.durationMinutes);

    // Compliance check: compare clock-in against first shift start,
    // clock-out against last shift end
    final firstShift = shifts.first;
    final lastShift = shifts.last;

    final firstWork = workRecords.first;
    final lastWork = workRecords.last;

    final shiftStartMin = _parseTime(firstShift.startTime);
    final shiftEndMin = _parseTime(lastShift.endTime);
    final clockInMin = _parseTime(firstWork.startTime);
    final clockOutMin = _parseTime(lastWork.endTime);

    final inDiff = (clockInMin - shiftStartMin).abs();
    final outDiff = (clockOutMin - shiftEndMin).abs();

    final maxDeviation = inDiff > outDiff ? inDiff : outDiff;

    if (inDiff <= toleranceMinutes && outDiff <= toleranceMinutes) {
      return DayCompliance(
        date: date,
        status: ComplianceStatus.compliant,
        expectedMinutes: expectedTotal.round(),
        actualMinutes: actualTotal,
        deviationMinutes: maxDeviation,
      );
    }

    return DayCompliance(
      date: date,
      status: ComplianceStatus.deviated,
      expectedMinutes: expectedTotal.round(),
      actualMinutes: actualTotal,
      deviationMinutes: maxDeviation,
    );
  }

  /// Convierte "HH:mm" a minutos desde medianoche
  static int _parseTime(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }
}
