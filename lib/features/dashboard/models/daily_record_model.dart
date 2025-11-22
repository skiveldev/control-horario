import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'daily_record_model.freezed.dart';
part 'daily_record_model.g.dart';

/// Modelo de Registro Diario de fichajes
/// 
/// Representa los fichajes de un empleado en un día específico.
/// Un documento por día con entrada, salida y timestamps.
@freezed
class DailyRecordModel with _$DailyRecordModel {
  const factory DailyRecordModel({
    required String date,
    required String userId,
    required ClockTimes clocks,
    DateTime? clockInTimestamp,
    DateTime? clockOutTimestamp,
    required RecordStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DailyRecordModel;

  factory DailyRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordModelFromJson(json);

  /// Crear DailyRecordModel desde documento de Firestore
  factory DailyRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final clocks = data['clocks'] as Map<String, dynamic>;
    
    return DailyRecordModel(
      date: doc.id,
      userId: data['userId'] ?? '',
      clocks: ClockTimes(
        clockIn: clocks['clockIn'],
        clockOut: clocks['clockOut'],
      ),
      clockInTimestamp: (data['clockInTimestamp'] as Timestamp?)?.toDate(),
      clockOutTimestamp: (data['clockOutTimestamp'] as Timestamp?)?.toDate(),
      status: RecordStatus.values.byName(data['status'] ?? 'incomplete'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}

/// Tiempos de fichaje (formato HH:mm:ss)
@freezed
class ClockTimes with _$ClockTimes {
  const factory ClockTimes({
    String? clockIn,
    String? clockOut,
  }) = _ClockTimes;

  factory ClockTimes.fromJson(Map<String, dynamic> json) =>
      _$ClockTimesFromJson(json);
}

/// Estado del registro diario
enum RecordStatus {
  /// Fichaje incompleto - falta entrada o salida
  incomplete,
  
  /// Fichaje completo - tiene entrada y salida
  complete,
}

