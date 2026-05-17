import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/features/dashboard/models/anomaly_model.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/providers/anomaly_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper: build a work TimeRecordModel
TimeRecordModel _workRecord({
  required String date,
  required String startTime,
  required String endTime,
  int durationMinutes = 480,
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

/// Helper: a break record
TimeRecordModel _breakRecord({
  required String date,
  required String startTime,
  required String endTime,
  int durationMinutes = 60,
}) {
  return TimeRecordModel(
    id: 'brk-$date-$startTime',
    userId: 'user-1',
    date: date,
    category: RecordCategory.breakTime,
    startTime: startTime,
    endTime: endTime,
    location: 'office',
    durationMinutes: durationMinutes,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
    createdBy: 'user-1',
    isManual: false,
    recordStatus: RecordStatus.completed,
    validationStatus: ValidationStatus.editable,
  );
}

Map<String, DaySchedule> _weeklySchedule() => {
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
        shifts: [const TimeShift(startTime: '09:00', endTime: '18:00')],
        breakMinutes: 60,
        dailyHours: 8.0,
      ),
      'saturday': const DaySchedule(isWorkDay: false),
      'sunday': const DaySchedule(isWorkDay: false),
    };

void main() {
  group('AnomalyProvider — monthAnomalies', () {
    test('returns empty list when no schedule is available', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthAnomaliesProvider(
          MonthAnomalyParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: null,
            records: [],
            vacationDates: {},
          ),
        ).future,
      );

      expect(result, isEmpty);
    });

    test('detects missing-exit anomaly for active work records', () async {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          date: '2026-05-19',
          startTime: '09:00',
          endTime: '09:00',
          recordStatus: RecordStatus.active,
        ),
      ];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthAnomaliesProvider(
          MonthAnomalyParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
          ),
        ).future,
      );

      // Only the active record day should have a missing-exit anomaly
      final missingExits =
          result.where((a) => a.type == AnomalyType.missingExit);
      expect(missingExits.length, 1);
      expect(missingExits.first.date, '2026-05-19');
      expect(missingExits.first.severity, AnomalySeverity.high);
    });

    test('detects unexcused-absence on work days with no records', () async {
      final schedule = _weeklySchedule();
      final records = <TimeRecordModel>[];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthAnomaliesProvider(
          MonthAnomalyParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
          ),
        ).future,
      );

      // May 2026 has 20 work days (Mon–Fri), all should be absences
      final absences =
          result.where((a) => a.type == AnomalyType.unexcusedAbsence);
      expect(absences.length, greaterThan(0));
    });

    test('detects insufficient-hours on a work day', () async {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          date: '2026-05-19',
          startTime: '09:00',
          endTime: '13:00',
          durationMinutes: 240, // 4h instead of 8h
        ),
      ];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthAnomaliesProvider(
          MonthAnomalyParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
          ),
        ).future,
      );

      final insufficient =
          result.where((a) => a.type == AnomalyType.insufficientHours);
      expect(insufficient.length, 1);
      expect(insufficient.first.date, '2026-05-19');
      // Medium severity: 4h is exactly 50% of 8h, not below
      expect(insufficient.first.severity, AnomalySeverity.medium);
    });

    test('detects excessive-break when break exceeds schedule + 30min',
        () async {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          date: '2026-05-19',
          startTime: '09:00',
          endTime: '18:00',
          durationMinutes: 480,
        ),
        _breakRecord(
          date: '2026-05-19',
          startTime: '13:00',
          endTime:
              '14:31', // 91 min break (schedule 60 + 30 tolerance = 90 max)
          durationMinutes: 91,
        ),
      ];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthAnomaliesProvider(
          MonthAnomalyParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
          ),
        ).future,
      );

      final excessive =
          result.where((a) => a.type == AnomalyType.excessiveBreak);
      expect(excessive.length, 1);
      expect(excessive.first.date, '2026-05-19');
    });

    test('excludes vacation days from anomaly detection', () async {
      final schedule = _weeklySchedule();
      final records = <TimeRecordModel>[];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthAnomaliesProvider(
          MonthAnomalyParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {'2026-05-19'},
          ),
        ).future,
      );

      // May 19 is vacation → should NOT have an unexcused-absence
      final may19 = result.where((a) => a.date == '2026-05-19');
      expect(may19, isEmpty);
    });

    test('excludes weekends from anomaly detection', () async {
      final schedule = _weeklySchedule();
      final records = <TimeRecordModel>[];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthAnomaliesProvider(
          MonthAnomalyParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
          ),
        ).future,
      );

      // May 24 Sun and May 23 Sat → should NOT have anomalies
      final weekend = result.where(
        (a) => a.date == '2026-05-23' || a.date == '2026-05-24',
      );
      expect(weekend, isEmpty);
    });

    test('detects overlap when two work records have conflicting times',
        () async {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          date: '2026-05-19',
          startTime: '09:00',
          endTime: '13:00',
          durationMinutes: 240,
        ),
        _workRecord(
          date: '2026-05-19',
          startTime: '12:00',
          endTime: '18:00',
          durationMinutes: 360,
        ),
      ];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthAnomaliesProvider(
          MonthAnomalyParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
          ),
        ).future,
      );

      final overlaps = result.where((a) => a.type == AnomalyType.overlap);
      expect(overlaps.length, 1);
    });
  });
}
