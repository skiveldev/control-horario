import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

/// Plantilla de horario reutilizable
///
/// Representa una plantilla de horario predefinida que puede ser asignada
/// a múltiples empleados (ej: "Jornada 40h 9-17", "Media Jornada 20h").
///
/// Ejemplo:
/// ```dart
/// final template = ScheduleModel(
///   scheduleId: 'schedule_40h_9_17',
///   name: 'Jornada 40h (9:00-17:00)',
///   description: 'Lunes a Viernes con 1h pausa',
///   totalWeeklyHours: 40,
///   weeklySchedule: {...},
/// );
/// ```
@freezed
class ScheduleModel with _$ScheduleModel {
  const ScheduleModel._();

  const factory ScheduleModel({
    required String scheduleId,
    required String name,
    required String description,
    required int totalWeeklyHours,
    @Default(true) bool isActive,
    @Default(true) bool isTemplate,
    @Default(0) int usedByCount,
    required Map<String, DaySchedule> weeklySchedule,
    DateTime? createdAt,
    String? createdBy,
    DateTime? lastModifiedAt,
    String? lastModifiedBy,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);

  /// Crear desde documento Firestore
  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parsear weeklySchedule desde Firestore
    final weeklyScheduleData = data['weeklySchedule'] as Map<String, dynamic>?;
    final weeklySchedule = <String, DaySchedule>{};

    if (weeklyScheduleData != null) {
      weeklyScheduleData.forEach((day, config) {
        weeklySchedule[day] =
            DaySchedule.fromJson(config as Map<String, dynamic>);
      });
    }

    return ScheduleModel(
      scheduleId: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      totalWeeklyHours: (data['totalWeeklyHours'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      isTemplate: data['isTemplate'] as bool? ?? true,
      usedByCount: (data['usedByCount'] as num?)?.toInt() ?? 0,
      weeklySchedule: weeklySchedule,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'] as String?,
      lastModifiedAt: (data['lastModifiedAt'] as Timestamp?)?.toDate(),
      lastModifiedBy: data['lastModifiedBy'] as String?,
    );
  }

  /// Convertir a formato Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'totalWeeklyHours': totalWeeklyHours,
      'isActive': isActive,
      'isTemplate': isTemplate,
      'usedByCount': usedByCount,
      'weeklySchedule': _serializeWeekSchedule(weeklySchedule),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (createdBy != null) 'createdBy': createdBy,
      if (lastModifiedAt != null)
        'lastModifiedAt': Timestamp.fromDate(lastModifiedAt!),
      if (lastModifiedBy != null) 'lastModifiedBy': lastModifiedBy,
    };
  }

  /// Helper para serializar weeklySchedule
  static Map<String, dynamic> _serializeWeekSchedule(
      Map<String, DaySchedule> schedule) {
    return schedule.map((day, config) => MapEntry(
          day,
          config.toJson(),
        ));
  }
}

/// Configuración de un día de la semana
///
/// Define si un día es laborable y sus turnos de trabajo.
///
/// Ejemplo:
/// ```dart
/// final monday = DaySchedule(
///   isWorkDay: true,
///   shifts: [TimeShift(startTime: '09:00', endTime: '17:00')],
///   breakMinutes: 60,
///   dailyHours: 8.0,
/// );
/// ```
@freezed
class DaySchedule with _$DaySchedule {
  const factory DaySchedule({
    @Default(false) bool isWorkDay,
    @Default([]) List<TimeShift> shifts,
    @Default(0) int breakMinutes,
    @Default(0.0) double dailyHours,
  }) = _DaySchedule;

  factory DaySchedule.fromJson(Map<String, dynamic> json) =>
      _$DayScheduleFromJson(json);
}

/// Turno de trabajo dentro de un día
///
/// Representa un bloque de horario (ej: "09:00-13:00" o "15:00-20:00").
/// Un día puede tener múltiples turnos (jornada partida).
///
/// Ejemplo:
/// ```dart
/// final morningShift = TimeShift(startTime: '09:00', endTime: '13:00');
/// final afternoonShift = TimeShift(startTime: '16:00', endTime: '20:00');
/// ```
@freezed
class TimeShift with _$TimeShift {
  const factory TimeShift({
    required String startTime, // Formato: "HH:mm" (ej: "09:00")
    required String endTime, // Formato: "HH:mm" (ej: "17:00")
  }) = _TimeShift;

  factory TimeShift.fromJson(Map<String, dynamic> json) =>
      _$TimeShiftFromJson(json);
}
