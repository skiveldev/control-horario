import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'daily_record_model.freezed.dart';
part 'daily_record_model.g.dart';

/// Modelo de Registro Diario de fichajes
///
/// Representa los fichajes de un empleado en un día específico.
/// Un documento por día con entrada, salida, pausas y timestamps.
@freezed
class DailyRecordModel with _$DailyRecordModel {
  // ignore: unused_element
  const DailyRecordModel._();

  const factory DailyRecordModel({
    required String date,
    required String userId,
    required ClockTimes clocks,
    DateTime? clockInTimestamp,
    DateTime? clockOutTimestamp,
    DateTime? breakStartTimestamp,
    DateTime? breakEndTimestamp,
    int? totalMinutes,
    required DailyRecordStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DailyRecordModel;

  factory DailyRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordModelFromJson(json);

  /// Crear DailyRecordModel desde documento de Firestore
  factory DailyRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final clocks = data['clocks'] as Map<String, dynamic>? ?? {};

    return DailyRecordModel(
      date: doc.id,
      userId: data['userId'] ?? '',
      clocks: ClockTimes(
        clockIn: clocks['clockIn'] as String?,
        breakStart: clocks['breakStart'] as String?,
        breakEnd: clocks['breakEnd'] as String?,
        clockOut: clocks['clockOut'] as String?,
      ),
      clockInTimestamp: (data['clockInTimestamp'] as Timestamp?)?.toDate(),
      clockOutTimestamp: (data['clockOutTimestamp'] as Timestamp?)?.toDate(),
      breakStartTimestamp:
          (data['breakStartTimestamp'] as Timestamp?)?.toDate(),
      breakEndTimestamp: (data['breakEndTimestamp'] as Timestamp?)?.toDate(),
      totalMinutes: data['totalMinutes'] as int?,
      status: _parseDailyRecordStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static DailyRecordStatus _parseDailyRecordStatus(dynamic value) {
    try {
      return DailyRecordStatus.values.byName(value as String);
    } catch (_) {
      return DailyRecordStatus.incomplete;
    }
  }

  /// Serializar a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'clocks': {
        if (clocks.clockIn != null) 'clockIn': clocks.clockIn,
        if (clocks.breakStart != null) 'breakStart': clocks.breakStart,
        if (clocks.breakEnd != null) 'breakEnd': clocks.breakEnd,
        if (clocks.clockOut != null) 'clockOut': clocks.clockOut,
      },
      if (clockInTimestamp != null)
        'clockInTimestamp': Timestamp.fromDate(clockInTimestamp!),
      if (clockOutTimestamp != null)
        'clockOutTimestamp': Timestamp.fromDate(clockOutTimestamp!),
      if (breakStartTimestamp != null)
        'breakStartTimestamp': Timestamp.fromDate(breakStartTimestamp!),
      if (breakEndTimestamp != null)
        'breakEndTimestamp': Timestamp.fromDate(breakEndTimestamp!),
      if (totalMinutes != null) 'totalMinutes': totalMinutes,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Tiempos de fichaje (formato HH:mm:ss)
@freezed
class ClockTimes with _$ClockTimes {
  const factory ClockTimes({
    String? clockIn,
    String? breakStart, // ✨ NUEVO: Hora inicio pausa
    String? breakEnd, // ✨ NUEVO: Hora fin pausa
    String? clockOut,
  }) = _ClockTimes;

  factory ClockTimes.fromJson(Map<String, dynamic> json) =>
      _$ClockTimesFromJson(json);
}

/// Estado del registro diario
enum DailyRecordStatus {
  /// Fichaje incompleto - falta entrada o salida
  incomplete,

  /// Fichaje completo - tiene entrada y salida
  complete,
}
