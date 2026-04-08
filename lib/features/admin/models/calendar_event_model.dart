import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Deserializar desde Map de Firestore (elemento del array events)
  factory CalendarEventModel.fromMap(Map<String, dynamic> map) {
    return CalendarEventModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime(1970),
      type: _holidayTypeFromString(map['type'] as String?),
    );
  }

  /// Serializar a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': Timestamp.fromDate(date),
      'type': type.name,
    };
  }

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

/// Convierte un string de Firestore al enum HolidayType con fallback seguro.
HolidayType _holidayTypeFromString(String? value) {
  try {
    return HolidayType.values.byName(value ?? 'national');
  } catch (_) {
    return HolidayType.national;
  }
}
