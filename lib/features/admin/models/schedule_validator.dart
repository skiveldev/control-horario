import 'schedule_model.dart';

/// Result of validating a weekly schedule template.
///
/// Provides a normalized version where [dailyHours] are derived from
/// shifts instead of trusting the stored value.
class ScheduleValidationResult {
  /// Whether the schedule passes all validation rules.
  final bool isValid;

  /// Human-readable error messages (empty when valid).
  final List<String> errors;

  /// Normalized schedule with dailyHours derived from shifts.
  /// Null when [isValid] is false.
  final Map<String, DaySchedule>? normalizedSchedule;

  /// Total weekly hours derived from shifts.
  final int totalWeeklyHours;

  const ScheduleValidationResult({
    required this.isValid,
    required this.errors,
    this.normalizedSchedule,
    this.totalWeeklyHours = 0,
  });

  factory ScheduleValidationResult.valid(
    Map<String, DaySchedule> normalized,
    int totalHours,
  ) =>
      ScheduleValidationResult(
        isValid: true,
        errors: const [],
        normalizedSchedule: normalized,
        totalWeeklyHours: totalHours,
      );

  factory ScheduleValidationResult.invalid(List<String> errors) =>
      ScheduleValidationResult(
        isValid: false,
        errors: errors,
        normalizedSchedule: null,
      );
}

/// Pure-function validator for schedule templates.
///
/// Validates:
/// - Template name is not empty
/// - At least one working day with shifts exists
/// - Every shift has endTime strictly after startTime
/// - No overlapping shifts in the same day
/// - Daily/weekly hours are derived from shifts (never trusted)
///
/// All methods are static and side-effect-free — they take data in, return
/// results out. No Riverpod, no Firestore, no BuildContext.
class ScheduleValidator {
  /// Validate a full weekly schedule.
  ///
  /// [weeklySchedule] — map of day key → DaySchedule.
  /// [name] — optional template name; if provided and blank, adds an error.
  ///
  /// Returns [ScheduleValidationResult] with normalized schedule when valid.
  static ScheduleValidationResult validate(
    Map<String, DaySchedule> weeklySchedule, {
    String? name,
  }) {
    final errors = <String>[];

    // 1. Name check (optional)
    if (name != null && name.trim().isEmpty) {
      errors.add('Template name cannot be empty');
    }

    // 2. At least one working day
    final workDays =
        weeklySchedule.entries.where((e) => e.value.isWorkDay).toList();
    if (workDays.isEmpty) {
      errors.add('At least one working day must be configured');
      return ScheduleValidationResult.invalid(errors);
    }

    // 3. Validate each day and normalize
    final normalized = <String, DaySchedule>{};
    var totalHours = 0.0;

    for (final entry in weeklySchedule.entries) {
      final dayKey = entry.key;
      final day = entry.value;

      if (!day.isWorkDay) {
        // Pass through rest days unchanged
        normalized[dayKey] = day;
        continue;
      }

      // Work day must have shifts
      if (day.shifts.isEmpty) {
        errors
            .add('${_dayName(dayKey)} is marked as work day but has no shifts');
        continue;
      }

      // Validate each shift
      for (var i = 0; i < day.shifts.length; i++) {
        final shift = day.shifts[i];
        final start = _timeToMinutes(shift.startTime);
        final end = _timeToMinutes(shift.endTime);

        if (end <= start) {
          errors.add(
            '${_dayName(dayKey)}: shift ${i + 1} end time '
            '(${shift.endTime}) must be after start time (${shift.startTime})',
          );
        }
      }

      // Check for overlapping shifts
      if (_shiftsOverlap(day.shifts)) {
        errors.add('${_dayName(dayKey)}: shifts cannot overlap');
      }

      // Derive dailyHours from shifts (do NOT trust stored value)
      final derivedHours = _deriveDailyHours(day.shifts);

      normalized[dayKey] = DaySchedule(
        isWorkDay: true,
        shifts: day.shifts,
        breakMinutes: day.breakMinutes,
        dailyHours: derivedHours,
      );
      totalHours += derivedHours;
    }

    final roundedHours = totalHours.round();
    if (errors.isEmpty && roundedHours <= 0) {
      errors.add('Total weekly hours must be greater than 0');
    }

    if (errors.isNotEmpty) {
      return ScheduleValidationResult.invalid(errors);
    }

    return ScheduleValidationResult.valid(normalized, roundedHours);
  }

  // ==========================================================================
  // PRIVATE HELPERS
  // ==========================================================================

  /// Sum shift durations in hours.
  static double _deriveDailyHours(List<TimeShift> shifts) {
    return shifts.fold(0.0, (sum, shift) {
      final start = _timeToMinutes(shift.startTime);
      final end = _timeToMinutes(shift.endTime);
      if (end > start) {
        return sum + (end - start) / 60.0;
      }
      return sum; // skip invalid shifts
    });
  }

  /// Check whether any pair of shifts overlaps.
  ///
  /// Sorts shifts by start time, then checks if any shift's end
  /// extends past the next shift's start.
  static bool _shiftsOverlap(List<TimeShift> shifts) {
    if (shifts.length < 2) return false;

    final sorted = List<TimeShift>.from(shifts)
      ..sort((a, b) =>
          _timeToMinutes(a.startTime).compareTo(_timeToMinutes(b.startTime)));

    for (var i = 0; i < sorted.length - 1; i++) {
      final currentEnd = _timeToMinutes(sorted[i].endTime);
      final nextStart = _timeToMinutes(sorted[i + 1].startTime);
      if (currentEnd > nextStart) {
        return true;
      }
    }
    return false;
  }

  /// Parse "HH:mm" into total minutes since midnight.
  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// English day name for a key (used in error messages).
  static String _dayName(String key) {
    const names = {
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
    };
    return names[key] ?? key;
  }
}
