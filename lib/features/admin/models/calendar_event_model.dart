import 'holiday_type.dart';

/// Representa un día o conjunto de días marcados en un calendario laboral
class CalendarEventModel {
  final String id;
  final String name;
  final DateTime date;
  final HolidayType type;

  const CalendarEventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
  });

  CalendarEventModel copyWith({
    String? id,
    String? name,
    DateTime? date,
    HolidayType? type,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
