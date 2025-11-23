import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/daily_record_model.dart';

part 'clocking_provider.g.dart';

// ==============================================================================
// STREAM PROVIDER - Registro de Hoy
// ==============================================================================

/// Provider para obtener el registro de fichajes de hoy
/// 
/// Escucha en tiempo real el documento del día actual.
/// Retorna:
/// - null si no hay usuario autenticado o no hay fichajes hoy
/// - DailyRecordModel con los fichajes del día
@riverpod
Stream<DailyRecordModel?> todayRecord(TodayRecordRef ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  
  if (user == null) {
    yield null;
    return;
  }

  final today = _getTodayString();
  final firestore = ref.watch(firestoreProvider);

  yield* firestore
      .collection('users')
      .doc(user.userId)
      .collection('daily_records')
      .doc(today)
      .snapshots()
      .map((doc) => doc.exists ? DailyRecordModel.fromFirestore(doc) : null);
}

// ==============================================================================
// NOTIFIER - Acciones de Fichaje
// ==============================================================================

/// Notifier para acciones de fichaje
/// 
/// Maneja las operaciones de fichar entrada y salida.
/// Expone AsyncValue<void> como estado para manejar loading/error.
@riverpod
class ClockingNotifier extends _$ClockingNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Fichar entrada
  /// 
  /// Crea un nuevo documento en daily_records con la hora de entrada.
  /// Solo permitido si no existe registro del día o está incompleto.
  /// 
  /// Uso:
  /// ```dart
  /// await ref.read(clockingNotifierProvider.notifier).clockIn();
  /// ```
  Future<void> clockIn() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Usuario no autenticado');

      final firestore = ref.read(firestoreProvider);
      final today = _getTodayString();
      final now = DateTime.now();
      final timeString = _formatTimeString(now);

      await firestore
          .collection('users')
          .doc(user.userId)
          .collection('daily_records')
          .doc(today)
          .set({
        'date': today,
        'userId': user.userId,
        'clocks': {
          'clockIn': timeString,
          'clockOut': null,
        },
        'clockInTimestamp': Timestamp.fromDate(now),
        'clockOutTimestamp': null,
        'status': 'incomplete',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Fichar salida
  /// 
  /// Actualiza el documento del día con la hora de salida.
  /// Solo permitido si ya existe un fichaje de entrada.
  /// 
  /// Uso:
  /// ```dart
  /// await ref.read(clockingNotifierProvider.notifier).clockOut();
  /// ```
  Future<void> clockOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Usuario no autenticado');

      final firestore = ref.read(firestoreProvider);
      final today = _getTodayString();
      final now = DateTime.now();
      final timeString = _formatTimeString(now);

      await firestore
          .collection('users')
          .doc(user.userId)
          .collection('daily_records')
          .doc(today)
          .update({
        'clocks.clockOut': timeString,
        'clockOutTimestamp': Timestamp.fromDate(now),
        'status': 'complete',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

// ==============================================================================
// HELPERS - Formateo de Fechas
// ==============================================================================

/// Obtener fecha de hoy en formato YYYY-MM-DD
String _getTodayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

/// Formatear DateTime a string HH:mm:ss
String _formatTimeString(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
}




