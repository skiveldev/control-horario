import 'package:control_horario/features/dashboard/models/time_record_model.dart';

/// Construye una lista de TimeRecordModel a partir de tuplas
/// (date, category, startTime, endTime, durationMinutes).
///
/// Cada tupla genera un registro con valores por defecto para el resto de campos.
List<TimeRecordModel> buildMockRecordsForDays(
  List<(String, RecordCategory, String, String, int)> entries,
) {
  final now = DateTime.now();
  int idCounter = 0;

  return entries.map((entry) {
    final (date, category, startTime, endTime, durationMinutes) = entry;
    idCounter++;
    return TimeRecordModel(
      id: 'mock-record-$idCounter',
      userId: 'mock-user',
      date: date,
      category: category,
      startTime: startTime,
      endTime: endTime,
      location: 'Oficina',
      durationMinutes: durationMinutes,
      createdAt: now,
      updatedAt: now,
      createdBy: 'mock-user',
      isManual: false,
      recordStatus:
          endTime == '--:--' ? RecordStatus.active : RecordStatus.completed,
    );
  }).toList();
}
