import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar_event_model.dart';
import 'holiday_type.dart';

/// Representa un calendario laboral anual asignable a empleados
class WorkCalendarModel {
  final String id;
  final String name;
  final int year;
  final List<CalendarEventModel> events;
  final bool isActive;

  const WorkCalendarModel({
    required this.id,
    required this.name,
    required this.year,
    required this.events,
    this.isActive = true,
  });

  /// Total de días marcados como festivo (national, regional, local)
  int get totalHolidays =>
      events.where((e) => e.type != HolidayType.vacation).length;

  /// Total de días marcados como vacaciones
  int get totalVacationDays =>
      events.where((e) => e.type == HolidayType.vacation).length;

  /// Deserializar desde documento de Firestore
  factory WorkCalendarModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawEvents = data['events'] as List<dynamic>? ?? [];
    final events = rawEvents
        .map((e) => CalendarEventModel.fromMap(e as Map<String, dynamic>))
        .toList();

    return WorkCalendarModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      year: data['year'] as int? ?? DateTime.now().year,
      events: events,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Serializar para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'year': year,
      'isActive': isActive,
      'events': events.map((e) => e.toMap()).toList(),
    };
  }

  WorkCalendarModel copyWith({
    String? id,
    String? name,
    int? year,
    List<CalendarEventModel>? events,
    bool? isActive,
  }) {
    return WorkCalendarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      events: events ?? this.events,
      isActive: isActive ?? this.isActive,
    );
  }
}

// =============================================================================
// MOCK DATA (Reemplazar con Riverpod provider en Fase 2)
// =============================================================================

List<WorkCalendarModel> mockWorkCalendars = [
  WorkCalendarModel(
    id: 'cal_madrid_2025',
    name: 'Madrid 2025',
    year: 2025,
    isActive: true,
    events: _buildMockEventsMadrid2025(),
  ),
  WorkCalendarModel(
    id: 'cal_cataluna_2025',
    name: 'Cataluña 2025',
    year: 2025,
    isActive: true,
    events: _buildMockEventsCataluna2025(),
  ),
  WorkCalendarModel(
    id: 'cal_remoto_2025',
    name: 'Remoto (Nacionales)',
    year: 2025,
    isActive: false,
    events: _buildMockEventsNacionales2025(),
  ),
];

List<CalendarEventModel> _buildMockEventsNacionales2025() => [
      CalendarEventModel(
        id: 'n1',
        name: 'Año Nuevo',
        date: DateTime(2025, 1, 1),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n2',
        name: 'Reyes Magos',
        date: DateTime(2025, 1, 6),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n3',
        name: 'Viernes Santo',
        date: DateTime(2025, 4, 18),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n4',
        name: 'Día del Trabajador',
        date: DateTime(2025, 5, 1),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n5',
        name: 'Asunción de la Virgen',
        date: DateTime(2025, 8, 15),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n6',
        name: 'Fiesta Nacional',
        date: DateTime(2025, 10, 12),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n7',
        name: 'Todos los Santos',
        date: DateTime(2025, 11, 1),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n8',
        name: 'Constitución',
        date: DateTime(2025, 12, 6),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n9',
        name: 'Inmaculada Concepción',
        date: DateTime(2025, 12, 8),
        type: HolidayType.national,
      ),
      CalendarEventModel(
        id: 'n10',
        name: 'Navidad',
        date: DateTime(2025, 12, 25),
        type: HolidayType.national,
      ),
    ];

List<CalendarEventModel> _buildMockEventsMadrid2025() {
  final events =
      List<CalendarEventModel>.from(_buildMockEventsNacionales2025());
  events.addAll([
    CalendarEventModel(
      id: 'm1',
      name: 'Lunes de Pascua',
      date: DateTime(2025, 4, 21),
      type: HolidayType.regional,
    ),
    CalendarEventModel(
      id: 'm2',
      name: 'Dos de Mayo',
      date: DateTime(2025, 5, 2),
      type: HolidayType.regional,
    ),
    CalendarEventModel(
      id: 'm3',
      name: 'San Isidro',
      date: DateTime(2025, 5, 15),
      type: HolidayType.local,
    ),
    CalendarEventModel(
      id: 'm4',
      name: 'Almudena',
      date: DateTime(2025, 11, 9),
      type: HolidayType.local,
    ),
    // Vacaciones de verano
    ...List.generate(
        22,
        (i) => CalendarEventModel(
              id: 'mv$i',
              name: 'Vacaciones de Verano',
              date: DateTime(2025, 8, 1 + i),
              type: HolidayType.vacation,
            )),
    // Navidad
    CalendarEventModel(
      id: 'mv_nav1',
      name: 'Vacaciones Navidad',
      date: DateTime(2025, 12, 26),
      type: HolidayType.vacation,
    ),
    CalendarEventModel(
      id: 'mv_nav2',
      name: 'Vacaciones Navidad',
      date: DateTime(2025, 12, 29),
      type: HolidayType.vacation,
    ),
    CalendarEventModel(
      id: 'mv_nav3',
      name: 'Vacaciones Navidad',
      date: DateTime(2025, 12, 30),
      type: HolidayType.vacation,
    ),
    CalendarEventModel(
      id: 'mv_nav4',
      name: 'Vacaciones Navidad',
      date: DateTime(2025, 12, 31),
      type: HolidayType.vacation,
    ),
  ]);
  return events;
}

List<CalendarEventModel> _buildMockEventsCataluna2025() {
  final events =
      List<CalendarEventModel>.from(_buildMockEventsNacionales2025());
  events.addAll([
    CalendarEventModel(
      id: 'c1',
      name: 'San Jorge',
      date: DateTime(2025, 4, 23),
      type: HolidayType.regional,
    ),
    CalendarEventModel(
      id: 'c2',
      name: 'Sant Joan',
      date: DateTime(2025, 6, 24),
      type: HolidayType.regional,
    ),
    CalendarEventModel(
      id: 'c3',
      name: 'Diada de Catalunya',
      date: DateTime(2025, 9, 11),
      type: HolidayType.regional,
    ),
    ...List.generate(
        22,
        (i) => CalendarEventModel(
              id: 'cv$i',
              name: 'Vacaciones de Verano',
              date: DateTime(2025, 8, 1 + i),
              type: HolidayType.vacation,
            )),
  ]);
  return events;
}
