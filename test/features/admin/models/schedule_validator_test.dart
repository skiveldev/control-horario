import 'package:control_horario/features/admin/models/schedule_model.dart';
import 'package:control_horario/features/admin/models/schedule_validator.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// HELPERS — build DaySchedule/TimeShift for test brevity
// =============================================================================

TimeShift _shift(String start, String end) =>
    TimeShift(startTime: start, endTime: end);

DaySchedule _workDay(List<TimeShift> shifts, {double dailyHours = 0.0}) =>
    DaySchedule(
      isWorkDay: true,
      shifts: shifts,
      dailyHours: dailyHours,
    );

DaySchedule _restDay() => const DaySchedule(isWorkDay: false);

Map<String, DaySchedule> _week(Map<String, DaySchedule> days) => days;

// =============================================================================
// TESTS — ScheduleValidator.validate
// =============================================================================

void main() {
  group('ScheduleValidator.validate', () {
    // --------------------------------------------------------------------------
    // HAPPY PATH — valid schedules
    // --------------------------------------------------------------------------
    group('valid schedules', () {
      test('single-shift workday yields derived dailyHours and total', () {
        final schedule = _week({
          'monday': _workDay([_shift('09:00', '17:00')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isTrue,
            reason: 'One valid shift should pass validation');
        expect(result.errors, isEmpty);
        expect(result.normalizedSchedule, isNotNull);
        expect(result.normalizedSchedule!['monday']!.dailyHours,
            closeTo(8.0, 0.01),
            reason: '09:00-17:00 = 8 hours');
        expect(result.totalWeeklyHours, 8);
      });

      test('split jornada (two shifts) in same day', () {
        final schedule = _week({
          'monday': _workDay([
            _shift('09:00', '13:00'),
            _shift('16:00', '20:00'),
          ]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isTrue);
        expect(result.normalizedSchedule!['monday']!.dailyHours,
            closeTo(8.0, 0.01),
            reason: '(13-9) + (20-16) = 4 + 4 = 8');
        expect(result.totalWeeklyHours, 8);
      });

      test('multiple workdays sum correctly', () {
        final schedule = _week({
          'monday': _workDay([_shift('09:00', '17:00')]),
          'tuesday': _workDay([_shift('09:00', '17:00')]),
          'wednesday': _workDay([_shift('09:00', '13:00')]),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isTrue);
        expect(result.totalWeeklyHours, 20);
      });

      test('derives dailyHours from shifts, ignoring stored value', () {
        // Stored dailyHours is WRONG (says 40) but shifts say 4 hours
        final schedule = _week({
          'monday': DaySchedule(
            isWorkDay: true,
            shifts: [_shift('09:00', '13:00')],
            dailyHours: 40.0, // ← incorrect stored value
          ),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isTrue);
        expect(result.normalizedSchedule!['monday']!.dailyHours,
            closeTo(4.0, 0.01),
            reason: 'dailyHours MUST be derived from shifts, not trusted');
        expect(result.totalWeeklyHours, 4);
      });
    });

    // --------------------------------------------------------------------------
    // ERROR PATHS — invalid schedules
    // --------------------------------------------------------------------------
    group('invalid schedules', () {
      test('empty name produces error', () {
        final schedule = _week({
          'monday': _workDay([_shift('09:00', '17:00')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule, name: '   ');

        expect(result.isValid, isFalse);
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('name'));
      });

      test('whitespace-only name considered empty', () {
        final schedule = _week({
          'monday': _workDay([_shift('09:00', '17:00')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule, name: '\t\n  ');

        expect(result.isValid, isFalse);
      });

      test('no work days produces error', () {
        final schedule = _week({
          'monday': _restDay(),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isFalse);
        expect(result.errors.any((e) => e.contains('working day')), isTrue);
      });

      test('work day with no shifts produces error', () {
        final schedule = _week({
          'monday': DaySchedule(isWorkDay: true, shifts: const []),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isFalse);
        expect(result.errors.any((e) => e.contains('no shifts')), isTrue);
      });

      test('end time equal to start time produces error', () {
        final schedule = _week({
          'monday': _workDay([_shift('09:00', '09:00')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isFalse);
        expect(
            result.errors
                .any((e) => e.contains('must be after') && e.contains('09:00')),
            isTrue);
      });

      test('end time before start time produces error', () {
        final schedule = _week({
          'monday': _workDay([_shift('17:00', '09:00')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isFalse);
        expect(result.errors.any((e) => e.contains('must be after')), isTrue);
      });

      test('overlapping shifts in same day produce error', () {
        final schedule = _week({
          'monday': _workDay([
            _shift('09:00', '14:00'),
            _shift('13:00', '18:00'), // overlaps with first (13:00 < 14:00)
          ]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isFalse);
        expect(result.errors.any((e) => e.contains('overlap')), isTrue);
      });

      test('non-overlapping adjacent shifts are valid', () {
        // Shift 1: 09:00-13:00, Shift 2: 13:00-17:00 — touching borders is OK
        final schedule = _week({
          'monday': _workDay([
            _shift('09:00', '13:00'),
            _shift('13:00', '17:00'),
          ]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isTrue,
            reason: 'Adjacent (touching) shifts do NOT overlap');
      });

      test(
          'end time before start on one shift invalidates while other shift OK',
          () {
        // Shift 2 is valid but shift 1 is backward — whole result invalid
        final schedule = _week({
          'monday': _workDay([
            _shift('17:00', '09:00'), // invalid
            _shift('16:00', '20:00'), // valid
          ]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isFalse);
        expect(result.errors.any((e) => e.contains('must be after')), isTrue);
        expect(result.normalizedSchedule, isNull,
            reason: 'normalized schedule only returned when valid');
      });
    });

    // --------------------------------------------------------------------------
    // EDGE CASES
    // --------------------------------------------------------------------------
    group('edge cases', () {
      test(
          'overnight shift (e.g. 22:00-06:00) treated as invalid (end < start)',
          () {
        // This model uses HH:mm — overnight would have 22:00 > 06:00 numerically
        final schedule = _week({
          'monday': _workDay([_shift('22:00', '06:00')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        // With this model, 22:00 > 06:00 → end <= start → invalid
        expect(result.isValid, isFalse);
      });

      test('single 1-minute shift is rejected because total rounds to 0', () {
        final schedule = _week({
          'monday': _workDay([_shift('09:00', '09:01')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isFalse,
            reason: '1 minute shift rounds to 0 total hours');
        expect(
            result.errors
                .any((e) => e.contains('hours must be greater than 0')),
            isTrue);
      });

      test('multiple small shifts that sum to at least 1 hour are valid', () {
        // 30 shifts of 2 minutes = 1 hour total (rounded to 1)
        final schedule = _week({
          'monday': _workDay([
            _shift('09:00', '09:30'), // 30 min
            _shift('10:00', '10:30'), // 30 min → total 60 min = 1 h
          ]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isTrue);
        expect(result.totalWeeklyHours, 1,
            reason: 'Two 30-minute shifts sum to 1 hour');
      });

      test('max 23:59 shift is valid', () {
        final schedule = _week({
          'monday': _workDay([_shift('00:00', '23:59')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isTrue);
        expect(result.normalizedSchedule!['monday']!.dailyHours,
            closeTo(23 + 59 / 60, 0.01));
        expect(result.totalWeeklyHours, 24);
      });

      test('rest days are preserved unchanged in normalized output', () {
        final schedule = _week({
          'monday': _workDay([_shift('09:00', '17:00')]),
          'tuesday': _restDay(),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday':
              DaySchedule(isWorkDay: false, breakMinutes: 30, dailyHours: 0),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isTrue);
        // Rest days are passed through
        for (final dayKey in [
          'tuesday',
          'wednesday',
          'thursday',
          'friday',
          'saturday'
        ]) {
          expect(result.normalizedSchedule![dayKey]!.isWorkDay, isFalse);
        }
        // Sunday with custom breakMinutes retained
        expect(result.normalizedSchedule!['sunday']!.breakMinutes, 30);
      });

      test('aggregation: multiple error types reported together', () {
        final schedule = _week({
          'monday': DaySchedule(isWorkDay: true, shifts: const []), // no shifts
          'tuesday': _workDay([
            _shift('14:00', '10:00'), // end < start
            _shift('09:00', '11:00'),
          ]),
          'wednesday': _restDay(),
          'thursday': _restDay(),
          'friday': _restDay(),
          'saturday': _restDay(),
          'sunday': _restDay(),
        });

        final result = ScheduleValidator.validate(schedule);

        expect(result.isValid, isFalse);
        // At least two distinct error categories
        final hasMissingShifts =
            result.errors.any((e) => e.contains('no shifts'));
        final hasInvalidTime =
            result.errors.any((e) => e.contains('must be after'));
        expect(hasMissingShifts, isTrue);
        expect(hasInvalidTime, isTrue);
      });
    });
  });
}
