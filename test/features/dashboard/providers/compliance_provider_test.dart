import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/providers/compliance_provider.dart';
import 'package:control_horario/features/dashboard/services/compliance_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper: build a work TimeRecordModel for testing
TimeRecordModel _workRecord({
  required String date,
  required String startTime,
  required String endTime,
  int durationMinutes = 480,
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
    recordStatus: RecordStatus.completed,
    validationStatus: ValidationStatus.editable,
  );
}

/// Helper: a standard 9–18 work day schedule
DaySchedule _workDay() => DaySchedule(
      isWorkDay: true,
      shifts: [const TimeShift(startTime: '09:00', endTime: '18:00')],
      breakMinutes: 60,
      dailyHours: 8.0,
    );

/// Build a full weekly schedule (Mon–Fri work, Sat–Sun off)
Map<String, DaySchedule> _weeklySchedule() => {
      'monday': _workDay(),
      'tuesday': _workDay(),
      'wednesday': _workDay(),
      'thursday': _workDay(),
      'friday': _workDay(),
      'saturday': const DaySchedule(isWorkDay: false),
      'sunday': const DaySchedule(isWorkDay: false),
    };

void main() {
  group('ComplianceProvider — monthCompliance', () {
    test('returns empty map when no schedule is available', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthComplianceProvider(
          MonthComplianceParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: null,
            records: [],
            vacationDates: {},
            toleranceMinutes: 15,
          ),
        ).future,
      );

      expect(result, isEmpty);
    });

    test('returns compliance status per day with tolerance comparison',
        () async {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          date: '2026-05-19',
          startTime: '08:55',
          endTime: '18:05',
        ),
        _workRecord(
          date: '2026-05-20',
          startTime: '09:31',
          endTime: '18:10',
        ),
      ];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthComplianceProvider(
          MonthComplianceParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
            toleranceMinutes: 15,
          ),
        ).future,
      );

      // May 19 (Tue): within 15min tolerance → compliant
      expect(result['2026-05-19']?.status, ComplianceStatus.compliant);
      // May 20 (Wed): clock-in 31min late → deviated
      expect(result['2026-05-20']?.status, ComplianceStatus.deviated);
    });

    test('excludes vacation days from compliance', () async {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          date: '2026-05-19',
          startTime: '08:55',
          endTime: '18:05',
        ),
      ];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthComplianceProvider(
          MonthComplianceParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {'2026-05-19'},
            toleranceMinutes: 15,
          ),
        ).future,
      );

      // May 19: vacation → noRecord
      expect(result['2026-05-19']?.status, ComplianceStatus.noRecord);
    });

    test('returns noRecord for non-work days (weekends)', () async {
      final schedule = _weeklySchedule();
      final records = <TimeRecordModel>[];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthComplianceProvider(
          MonthComplianceParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
            toleranceMinutes: 15,
          ),
        ).future,
      );

      // May 24, 2026 is a Sunday → noRecord
      expect(result['2026-05-24']?.status, ComplianceStatus.noRecord);
      // May 23, 2026 is a Saturday → noRecord
      expect(result['2026-05-23']?.status, ComplianceStatus.noRecord);
    });

    test('returns noRecord for work days with no time records', () async {
      final schedule = _weeklySchedule();
      final records = <TimeRecordModel>[];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthComplianceProvider(
          MonthComplianceParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
            toleranceMinutes: 15,
          ),
        ).future,
      );

      // May 19, 2026 is a Tuesday (work day) but no records
      expect(result['2026-05-19']?.status, ComplianceStatus.noRecord);
    });

    test('includes expected and actual minutes in result', () async {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          date: '2026-05-19',
          startTime: '09:00',
          endTime: '18:00',
          durationMinutes: 480,
        ),
      ];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthComplianceProvider(
          MonthComplianceParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
            toleranceMinutes: 15,
          ),
        ).future,
      );

      final dayResult = result['2026-05-19'];
      expect(dayResult, isNotNull);
      expect(dayResult!.expectedMinutes, 480);
      expect(dayResult.actualMinutes, 480);
    });

    test('uses configurable tolerance', () async {
      final schedule = _weeklySchedule();
      final records = [
        _workRecord(
          date: '2026-05-19',
          startTime: '09:06',
          endTime: '18:04',
        ),
      ];

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(
        monthComplianceProvider(
          MonthComplianceParams(
            userId: 'user-1',
            month: DateTime(2026, 5),
            schedule: schedule,
            records: records,
            vacationDates: {},
            toleranceMinutes: 5,
          ),
        ).future,
      );

      // 6 min late with 5 min tolerance → deviated
      expect(result['2026-05-19']?.status, ComplianceStatus.deviated);
    });
  });
}
