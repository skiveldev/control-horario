import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/time_record_model.dart';
import '../services/time_records_service.dart';
import 'clocking_provider.dart';

part 'dashboard_provider.g.dart';

// ==============================================================================
// STREAM PROVIDER - Registros Mensuales
// ==============================================================================

/// Provider para obtener registros del mes actual
///
/// Escucha en tiempo real todos los fichajes del mes desde time_records.
/// Ordena por fecha y hora de inicio.
///
/// Retorna lista vacía si no hay usuario autenticado.
@riverpod
Stream<List<TimeRecordModel>> monthlyRecords(MonthlyRecordsRef ref) async* {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) {
    yield [];
    return;
  }

  final now = DateTime.now();
  final timeRecordsService = TimeRecordsService();

  yield* timeRecordsService.getMonthRecords(user.userId, now);
}

// ==============================================================================
// COMPUTED PROVIDERS - Cálculos de Horas
// ==============================================================================

/// Provider computado: Total de minutos trabajados hoy
///
/// Suma los minutos de todos los registros work del día (excluye pausas).
/// Retorna 0 si no hay registros.
@riverpod
int todayTotalMinutes(TodayTotalMinutesRef ref) {
  final todayRecords = ref.watch(todayRecordsProvider).valueOrNull ?? [];

  // Sumar solo registros de trabajo (excluir pausas)
  int total = 0;
  for (final record in todayRecords) {
    if (record.category == RecordCategory.work) {
      total += record.durationMinutes;
    }
  }

  return total;
}

/// Provider computado: Total de minutos trabajados en el mes
///
/// Suma todos los minutos de registros work del mes (excluye pausas).
/// Retorna 0 si no hay registros.
@riverpod
int monthTotalMinutes(MonthTotalMinutesRef ref) {
  final records = ref.watch(monthlyRecordsProvider).valueOrNull ?? [];

  // Sumar solo registros de trabajo (excluir pausas)
  int total = 0;
  for (final record in records) {
    if (record.category == RecordCategory.work) {
      total += record.durationMinutes;
    }
  }

  return total;
}

/// Provider computado: Total de minutos en pausa hoy
///
/// Suma los minutos de todos los registros breakTime del día.
/// Retorna 0 si no hay pausas.
@riverpod
int todayBreakMinutes(TodayBreakMinutesRef ref) {
  final todayRecords = ref.watch(todayRecordsProvider).valueOrNull ?? [];

  // Sumar solo registros de pausa
  int total = 0;
  for (final record in todayRecords) {
    if (record.category == RecordCategory.breakTime) {
      total += record.durationMinutes;
    }
  }

  return total;
}

/// Provider computado: Hora de entrada de hoy
///
/// Retorna el startTime del primer registro work del día.
/// Retorna null si no hay registros.
@riverpod
String? todayClockInTime(TodayClockInTimeRef ref) {
  final todayRecords = ref.watch(todayRecordsProvider).valueOrNull ?? [];

  if (todayRecords.isEmpty) return null;

  // Buscar el primer registro work
  final firstWorkRecord = todayRecords.firstWhere(
    (r) => r.category == RecordCategory.work,
    orElse: () => todayRecords.first,
  );

  return firstWorkRecord.startTime;
}
