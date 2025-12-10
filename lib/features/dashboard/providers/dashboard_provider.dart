import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/daily_record_model.dart';
import 'clocking_provider.dart';

part 'dashboard_provider.g.dart';

// ==============================================================================
// STREAM PROVIDER - Registros Mensuales
// ==============================================================================

/// Provider para obtener registros del mes actual
///
/// Escucha en tiempo real todos los fichajes del mes.
/// Ordena por fecha descendente (más recientes primero).
///
/// Retorna lista vacía si no hay usuario autenticado.
@riverpod
Stream<List<DailyRecordModel>> monthlyRecords(MonthlyRecordsRef ref) async* {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) {
    yield [];
    return;
  }

  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);

  final startDate = _formatDateString(startOfMonth);
  final endDate = _formatDateString(endOfMonth);

  final firestore = ref.watch(firestoreProvider);

  yield* firestore
      .collection('users')
      .doc(user.userId)
      .collection('daily_records')
      .where('date', isGreaterThanOrEqualTo: startDate)
      .where('date', isLessThanOrEqualTo: endDate)
      .orderBy('date', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => DailyRecordModel.fromFirestore(doc))
            .toList(),
      );
}

// ==============================================================================
// COMPUTED PROVIDERS - Cálculos de Horas
// ==============================================================================

/// Provider computado: Total de minutos trabajados hoy
///
/// Calcula la diferencia entre entrada y salida del día actual.
/// Retorna 0 si:
/// - No hay registro hoy
/// - Falta entrada o salida
@riverpod
int todayTotalMinutes(TodayTotalMinutesRef ref) {
  final todayRecord = ref.watch(todayRecordProvider).valueOrNull;

  if (todayRecord == null ||
      todayRecord.clockInTimestamp == null ||
      todayRecord.clockOutTimestamp == null) {
    return 0;
  }

  final duration = todayRecord.clockOutTimestamp!.difference(
    todayRecord.clockInTimestamp!,
  );

  return duration.inMinutes;
}

/// Provider computado: Total de minutos trabajados en el mes
///
/// Suma todos los minutos de registros completos del mes.
/// Retorna 0 si no hay registros.
@riverpod
int monthTotalMinutes(MonthTotalMinutesRef ref) {
  final records = ref.watch(monthlyRecordsProvider).valueOrNull ?? [];

  int total = 0;
  for (final record in records) {
    if (record.clockInTimestamp != null && record.clockOutTimestamp != null) {
      final duration = record.clockOutTimestamp!.difference(
        record.clockInTimestamp!,
      );
      total += duration.inMinutes;
    }
  }

  return total;
}

// ==============================================================================
// HELPERS - Formateo de Fechas
// ==============================================================================

/// Formatear DateTime a string YYYY-MM-DD
String _formatDateString(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
