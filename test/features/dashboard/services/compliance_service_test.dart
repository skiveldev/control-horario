import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/services/compliance_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper: build a TimeRecordModel for testing
TimeRecordModel _workRecord({
  required String date,
  required String startTime,
  required String endTime,
  int durationMinutes = 0,
  RecordStatus recordStatus = RecordStatus.completed,
}) {
  return TimeRecordModel(
    id: 'rec-$date-$startTime',
    userId: 'user-1',
    date: date,
    category: RecordCategory.work,
    startTime: startTime,
    endTime: endTime,
    location: 'office',
    durationMinutes: durationMinutes,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
    createdBy: 'user-1',
    isManual: false,
    recordStatus: recordStatus,
    validationStatus: ValidationStatus.editable,
  );
}

DaySchedule _workDaySchedule({
  String startTime = '09:00',
  String endTime = '18:00',
  int breakMinutes = 60,
  double dailyHours = 8.0,
}) {
  return DaySchedule(
    isWorkDay: true,
    shifts: [
      TimeShift(startTime: startTime, endTime: endTime),
    ],
    breakMinutes: breakMinutes,
    dailyHours: dailyHours,
  );
}

DaySchedule _nonWorkDay() => const DaySchedule(isWorkDay: false);

void main() {
  group('ComplianceService.computeDayCompliance', () {
    final service = ComplianceService();

    test('returns noRecord for a vacation day regardless of records', () {
      final schedule = _workDaySchedule();
      final records = [
        _workRecord(date: '2026-05-20', startTime: '09:00', endTime: '18:00'),
      ];

      final result = service.computeDayCompliance(
        date: '2026-05-20',
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 15,
        isVacationDay: true,
      );

      expect(result.status, ComplianceStatus.noRecord);
      expect(result.expectedMinutes, isNull);
    });

    test('returns noRecord for a non-work day', () {
      final schedule = _nonWorkDay();
      final records = <TimeRecordModel>[];

      final result = service.computeDayCompliance(
        date: '2026-05-17', // Sunday
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 15,
        isVacationDay: false,
      );

      expect(result.status, ComplianceStatus.noRecord);
    });

    test('returns noRecord when no time records exist on a work day', () {
      final schedule = _workDaySchedule();
      final records = <TimeRecordModel>[];

      final result = service.computeDayCompliance(
        date: '2026-05-19',
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 15,
        isVacationDay: false,
      );

      expect(result.status, ComplianceStatus.noRecord);
    });

    test('returns compliant when clock-in/out are within tolerance', () {
      final schedule = _workDaySchedule(startTime: '09:00', endTime: '18:00');
      final records = [
        _workRecord(date: '2026-05-19', startTime: '08:47', endTime: '18:05'),
      ];

      final result = service.computeDayCompliance(
        date: '2026-05-19',
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 15,
        isVacationDay: false,
      );

      expect(result.status, ComplianceStatus.compliant);
    });

    test('returns deviated when clock-in is beyond tolerance', () {
      final schedule = _workDaySchedule(startTime: '09:00', endTime: '18:00');
      final records = [
        _workRecord(date: '2026-05-19', startTime: '09:31', endTime: '18:10'),
      ];

      final result = service.computeDayCompliance(
        date: '2026-05-19',
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 15,
        isVacationDay: false,
      );

      expect(result.status, ComplianceStatus.deviated);
    });

    test('returns deviated when clock-out is beyond tolerance', () {
      final schedule = _workDaySchedule(startTime: '09:00', endTime: '18:00');
      final records = [
        _workRecord(date: '2026-05-19', startTime: '08:55', endTime: '17:30'),
      ];

      final result = service.computeDayCompliance(
        date: '2026-05-19',
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 15,
        isVacationDay: false,
      );

      expect(result.status, ComplianceStatus.deviated);
    });

    test('uses configurable tolerance (5 min) — 6 min late is deviated', () {
      final schedule = _workDaySchedule(startTime: '09:00', endTime: '18:00');
      final records = [
        _workRecord(date: '2026-05-19', startTime: '09:06', endTime: '18:04'),
      ];

      final result = service.computeDayCompliance(
        date: '2026-05-19',
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 5,
        isVacationDay: false,
      );

      expect(result.status, ComplianceStatus.deviated);
    });

    test('clock-in earlier than shift start is OK within tolerance', () {
      final schedule = _workDaySchedule(startTime: '09:00', endTime: '18:00');
      final records = [
        _workRecord(date: '2026-05-19', startTime: '08:45', endTime: '18:00'),
      ];

      final result = service.computeDayCompliance(
        date: '2026-05-19',
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 15,
        isVacationDay: false,
      );

      expect(result.status, ComplianceStatus.compliant);
    });

    test('ignores breakTime records when computing compliance', () {
      final schedule = _workDaySchedule(
        startTime: '09:00',
        endTime: '18:00',
        breakMinutes: 60,
      );
      final records = [
        _workRecord(date: '2026-05-19', startTime: '08:55', endTime: '18:00'),
        TimeRecordModel(
          id: 'rec-break',
          userId: 'user-1',
          date: '2026-05-19',
          category: RecordCategory.breakTime,
          startTime: '13:00',
          endTime: '14:00',
          location: 'office',
          durationMinutes: 60,
          createdAt: DateTime(2026, 5, 1),
          updatedAt: DateTime(2026, 5, 1),
          createdBy: 'user-1',
          isManual: false,
          recordStatus: RecordStatus.completed,
          validationStatus: ValidationStatus.editable,
        ),
      ];

      final result = service.computeDayCompliance(
        date: '2026-05-19',
        daySchedule: schedule,
        records: records,
        toleranceMinutes: 15,
        isVacationDay: false,
      );

      expect(result.status, ComplianceStatus.compliant);
    });
  });
}
