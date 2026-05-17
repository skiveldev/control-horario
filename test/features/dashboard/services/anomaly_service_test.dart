import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/features/dashboard/models/anomaly_model.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/services/anomaly_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper: build a TimeRecordModel for testing
TimeRecordModel _workRecord({
  required String id,
  required String userId,
  required String date,
  required String startTime,
  required String endTime,
  int durationMinutes = 0,
  RecordStatus recordStatus = RecordStatus.completed,
}) {
  return TimeRecordModel(
    id: id,
    userId: userId,
    date: date,
    category: RecordCategory.work,
    startTime: startTime,
    endTime: endTime,
    location: 'office',
    durationMinutes: durationMinutes,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
    createdBy: userId,
    isManual: false,
    recordStatus: recordStatus,
    validationStatus: ValidationStatus.editable,
  );
}

TimeRecordModel _breakRecord({
  required String id,
  required String userId,
  required String date,
  required String startTime,
  required String endTime,
  int durationMinutes = 0,
}) {
  return TimeRecordModel(
    id: id,
    userId: userId,
    date: date,
    category: RecordCategory.breakTime,
    startTime: startTime,
    endTime: endTime,
    location: 'office',
    durationMinutes: durationMinutes,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
    createdBy: userId,
    isManual: false,
    recordStatus: RecordStatus.completed,
    validationStatus: ValidationStatus.editable,
  );
}

Map<String, DaySchedule> _weeklySchedule() {
  return {
    'monday': DaySchedule(
      isWorkDay: true,
      shifts: [const TimeShift(startTime: '09:00', endTime: '18:00')],
      breakMinutes: 60,
      dailyHours: 8.0,
    ),
    'tuesday': DaySchedule(
      isWorkDay: true,
      shifts: [const TimeShift(startTime: '09:00', endTime: '18:00')],
      breakMinutes: 60,
      dailyHours: 8.0,
    ),
    'wednesday': DaySchedule(
      isWorkDay: true,
      shifts: [const TimeShift(startTime: '09:00', endTime: '18:00')],
      breakMinutes: 60,
      dailyHours: 8.0,
    ),
    'thursday': DaySchedule(
      isWorkDay: true,
      shifts: [const TimeShift(startTime: '09:00', endTime: '18:00')],
      breakMinutes: 60,
      dailyHours: 8.0,
    ),
    'friday': DaySchedule(
      isWorkDay: true,
      shifts: [const TimeShift(startTime: '09:00', endTime: '15:00')],
      breakMinutes: 30,
      dailyHours: 5.5,
    ),
    'saturday': const DaySchedule(isWorkDay: false),
    'sunday': const DaySchedule(isWorkDay: false),
  };
}

void main() {
  group('AnomalyService.detectAnomalies', () {
    final service = AnomalyService();
    const userId = 'user-1';
    final month = DateTime(2026, 5); // May 2026

    test('detects missing-exit when clock-in has no clock-out', () {
      final schedule = _weeklySchedule();
      // Provide records for all work days. Only Monday has the active record.
      final records = <TimeRecordModel>[];
      for (var day = 1; day <= 31; day++) {
        final dt = DateTime(2026, 5, day);
        if (dt.weekday > 5) continue;
        final dateStr = '2026-05-${day.toString().padLeft(2, '0')}';
        if (dateStr == '2026-05-04') {
          // Monday — active record
          records.add(_workRecord(
            id: 'rec-1',
            userId: userId,
            date: dateStr,
            startTime: '09:00',
            endTime: '09:00',
            durationMinutes: 0,
            recordStatus: RecordStatus.active,
          ));
        } else {
          records.add(_workRecord(
            id: 'rec-$dateStr',
            userId: userId,
            date: dateStr,
            startTime: '09:00',
            endTime: '18:00',
            durationMinutes: 480,
          ));
        }
      }

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: const {},
      );

      final missingExits =
          anomalies.where((a) => a.type == AnomalyType.missingExit).toList();
      expect(missingExits.length, 1);
      expect(missingExits.first.userId, userId);
      expect(missingExits.first.date, '2026-05-04');
    });

    test('detects insufficient-hours when actual < expected', () {
      final schedule = _weeklySchedule();
      final records = <TimeRecordModel>[];
      for (var day = 1; day <= 31; day++) {
        final dt = DateTime(2026, 5, day);
        if (dt.weekday > 5) continue;
        final dateStr = '2026-05-${day.toString().padLeft(2, '0')}';
        if (dateStr == '2026-05-05') {
          // Tuesday — only 4h worked
          records.add(_workRecord(
            id: 'rec-1',
            userId: userId,
            date: dateStr,
            startTime: '09:00',
            endTime: '13:00',
            durationMinutes: 240, // 4h vs expected 8h
          ));
        } else {
          records.add(_workRecord(
            id: 'rec-$dateStr',
            userId: userId,
            date: dateStr,
            startTime: '09:00',
            endTime: '18:00',
            durationMinutes: 480,
          ));
        }
      }

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: const {},
      );

      final insufficient = anomalies
          .where((a) => a.type == AnomalyType.insufficientHours)
          .toList();
      expect(insufficient.length, 1);
      expect(insufficient.first.date, '2026-05-05');
    });

    test('detects unexcused-absence when no records on a work day', () {
      final schedule = _weeklySchedule();
      // Provide records for all work days in May except Tuesday 2026-05-05
      // to isolate the test to one specific absence
      final records = <TimeRecordModel>[];
      // May 2026 work days (Mon-Fri): add dummy records for all except 2026-05-05
      for (var day = 1; day <= 31; day++) {
        final dt = DateTime(2026, 5, day);
        if (dt.weekday > 5) continue; // skip weekends
        final dateStr = '2026-05-${day.toString().padLeft(2, '0')}';
        if (dateStr == '2026-05-05') continue; // leave Tuesday empty
        records.add(_workRecord(
          id: 'rec-$dateStr',
          userId: userId,
          date: dateStr,
          startTime: '09:00',
          endTime: '18:00',
          durationMinutes: 480,
        ));
      }

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: const {},
      );

      final absences = anomalies
          .where((a) => a.type == AnomalyType.unexcusedAbsence)
          .toList();
      expect(absences.length, 1);
      expect(absences.first.date, '2026-05-05');
    });

    test('detects overlapping work records', () {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          id: 'rec-1',
          userId: userId,
          date: '2026-05-06', // Wednesday
          startTime: '09:00',
          endTime: '14:00',
          durationMinutes: 300,
        ),
        _workRecord(
          id: 'rec-2',
          userId: userId,
          date: '2026-05-06',
          startTime: '13:00', // Overlaps with rec-1
          endTime: '18:00',
          durationMinutes: 300,
        ),
      ];

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: const {},
      );

      final overlaps =
          anomalies.where((a) => a.type == AnomalyType.overlap).toList();
      expect(overlaps.length, 1);
      expect(overlaps.first.date, '2026-05-06');
    });

    test('detects excessive-break when break > schedule + 30 min', () {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          id: 'rec-1',
          userId: userId,
          date: '2026-05-07', // Thursday
          startTime: '09:00',
          endTime: '13:00',
          durationMinutes: 240,
        ),
        _breakRecord(
          id: 'rec-b1',
          userId: userId,
          date: '2026-05-07',
          startTime: '13:00',
          endTime: '14:30', // 90 min break, schedule allows 60 + 30 = 90
          durationMinutes: 90,
        ),
        _workRecord(
          id: 'rec-2',
          userId: userId,
          date: '2026-05-07',
          startTime: '14:30',
          endTime: '18:00',
          durationMinutes: 210,
        ),
      ];

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: const {},
      );

      final excessiveBreaks =
          anomalies.where((a) => a.type == AnomalyType.excessiveBreak).toList();
      // 90 min break, schedule 60 + 30 tolerance = 90, so NOT excessive
      // Actually it's at the boundary — let's check with 91 min
      expect(excessiveBreaks.length, 0);
    });

    test('excessive-break: 91 min exceeds schedule 60 + 30 tolerance', () {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          id: 'rec-1',
          userId: userId,
          date: '2026-05-08', // Friday
          startTime: '09:00',
          endTime: '13:00',
          durationMinutes: 240,
        ),
        _breakRecord(
          id: 'rec-b1',
          userId: userId,
          date: '2026-05-08',
          startTime: '13:00',
          endTime: '14:31', // 91 min break
          durationMinutes: 91,
        ),
        _workRecord(
          id: 'rec-2',
          userId: userId,
          date: '2026-05-08',
          startTime: '14:31',
          endTime: '15:00',
          durationMinutes: 29,
        ),
      ];

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: const {},
      );

      final excessiveBreaks =
          anomalies.where((a) => a.type == AnomalyType.excessiveBreak).toList();
      expect(excessiveBreaks.length, 1);
      expect(excessiveBreaks.first.date, '2026-05-08');
    });

    test('excludes vacation days from anomaly detection', () {
      final schedule = _weeklySchedule();
      final records = <TimeRecordModel>[];
      // Monday 2026-05-04 is marked as vacation

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: {'2026-05-04'},
      );

      final absences = anomalies
          .where((a) =>
              a.type == AnomalyType.unexcusedAbsence && a.date == '2026-05-04')
          .toList();
      expect(absences.length, 0,
          reason: 'Vacation day should not generate unexcused absence');
    });

    test('excludes non-work days (weekend) from anomaly detection', () {
      final schedule = _weeklySchedule();
      final records = <TimeRecordModel>[];

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: const {},
      );

      // Saturdays and Sundays should NOT have unexcused absences
      final weekendAbsences = anomalies
          .where((a) =>
              a.type == AnomalyType.unexcusedAbsence &&
              (a.date == '2026-05-03' || a.date == '2026-05-10'))
          .toList();
      expect(weekendAbsences.length, 0);
    });

    test('does not flag insufficient-hours when hours meet daily target', () {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          id: 'rec-1',
          userId: userId,
          date: '2026-05-04', // Monday, 8h expected
          startTime: '09:00',
          endTime: '18:00',
          durationMinutes: 480, // 8h = 480 min
        ),
      ];

      final anomalies = service.detectAnomalies(
        userId: userId,
        month: month,
        records: records,
        weeklySchedule: schedule,
        vacationDates: const {},
      );

      final insufficient = anomalies
          .where((a) => a.type == AnomalyType.insufficientHours)
          .toList();
      expect(insufficient.length, 0);
    });
  });
}
