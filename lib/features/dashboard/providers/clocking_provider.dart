import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/time_record_model.dart';
import '../services/time_records_service.dart';

part 'clocking_provider.g.dart';

// ==============================================================================
// MODELO DE ESTADO TEMPORAL DE FICHAJE
// ==============================================================================

/// Estado temporal del fichaje actual
///
/// Mantiene los IDs de los registros activos que se van creando.
/// Permite actualizar registros en lugar de solo crear nuevos.
class ClockingSession {
  final String? activeRecordId; // ID del registro actualmente activo
  final DateTime? lastEventTime; // Hora del último evento

  const ClockingSession({
    this.activeRecordId,
    this.lastEventTime,
  });

  ClockingSession copyWith({
    String? activeRecordId,
    DateTime? lastEventTime,
  }) {
    return ClockingSession(
      activeRecordId: activeRecordId ?? this.activeRecordId,
      lastEventTime: lastEventTime ?? this.lastEventTime,
    );
  }

  bool get hasActiveRecord => activeRecordId != null;
}

// ==============================================================================
// STREAM PROVIDER - Registros de Hoy
// ==============================================================================

/// Provider para obtener los registros de fichaje de hoy
///
/// Escucha en tiempo real los documentos en time_records del día actual.
/// Retorna lista de TimeRecordModel ordenados por startTime.
@riverpod
Stream<List<TimeRecordModel>> todayRecords(TodayRecordsRef ref) async* {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) {
    yield [];
    return;
  }

  final today = DateTime.now();
  final timeRecordsService = TimeRecordsService();

  yield* timeRecordsService.getDayRecords(user.userId, today);
}

// ==============================================================================
// STATE PROVIDER - Sesión de Fichaje Actual
// ==============================================================================

/// Provider para mantener el estado temporal del fichaje
///
/// Guarda el ID del registro activo para poder actualizarlo.
@riverpod
class ClockingSessionNotifier extends _$ClockingSessionNotifier {
  @override
  ClockingSession build() {
    return const ClockingSession();
  }

  void setActiveRecord(String recordId, DateTime time) {
    state = ClockingSession(
      activeRecordId: recordId,
      lastEventTime: time,
    );
  }

  void reset() {
    state = const ClockingSession();
  }
}

// ==============================================================================
// NOTIFIER - Acciones de Fichaje
// ==============================================================================

/// Notifier para acciones de fichaje
///
/// OPCIÓN B: Registros inmediatos con actualizaciones
///
/// Flujo con pausa:
/// 1. clockIn → CREA registro work (09:00-09:00) "en curso"
/// 2. startBreak → ACTUALIZA registro anterior (09:00-12:30) + CREA breakTime (12:30-12:30)
/// 3. endBreak → ACTUALIZA registro pausa (12:30-13:00) + CREA work (13:00-13:00)
/// 4. clockOut → ACTUALIZA registro anterior (13:00-18:00)
///
/// Flujo sin pausa:
/// 1. clockIn → CREA registro work (09:00-09:00) "en curso"
/// 2. clockOut → ACTUALIZA registro (09:00-18:00)
@riverpod
class ClockingNotifier extends _$ClockingNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Fichar entrada
  ///
  /// CREA registro temporal en time_records con startTime=endTime.
  /// El registro aparece inmediatamente en "Mi Control Horario".
  ///
  /// Uso:
  /// ```dart
  /// await ref.read(clockingNotifierProvider.notifier).clockIn();
  /// ```
  Future<void> clockIn() async {
    debugPrint('🔵 [clockIn] Iniciando fichaje de entrada...');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Usuario no autenticado');

      final now = DateTime.now();
      final timeRecordsService = TimeRecordsService();

      // ✨ VALIDACIÓN: Verificar que NO haya registros activos
      debugPrint('🔍 [clockIn] Verificando registros existentes...');
      final todayRecords =
          await timeRecordsService.getDayRecords(user.userId, now).first;

      final activeRecords = todayRecords.where((r) => r.isActive).toList();

      if (activeRecords.isNotEmpty) {
        debugPrint(
            '⚠️ [clockIn] YA HAY ${activeRecords.length} registro(s) activo(s). Abortando...');
        for (final record in activeRecords) {
          debugPrint(
              '  - ${record.category.name}: ${record.startTime}-${record.endTime}');
        }
        throw Exception(
            'Ya existe un fichaje activo. Completa o elimina el fichaje anterior antes de crear uno nuevo.');
      }

      debugPrint(
          '✅ [clockIn] No hay registros activos, procediendo a crear...');

      // CREAR registro work con status ACTIVE
      final workRecord = TimeRecordModel(
        id: '', // Se generará automáticamente
        userId: user.userId,
        date: _formatDate(now),
        category: RecordCategory.work,
        startTime: _formatTime(now),
        endTime: _formatTime(now), // Se actualizará al fichar salida
        location: 'Oficina',
        durationMinutes: 0,
        recordStatus: RecordStatus.active, // ✨ NUEVO: Explícitamente activo
        createdAt: now,
        updatedAt: now,
        createdBy: user.userId,
        isManual: false,
        validationStatus: ValidationStatus.editable,
      );

      final recordId = await timeRecordsService.addRecord(workRecord);
      debugPrint('✅ [clockIn] Registro creado con ID: $recordId');

      // Guardar ID del registro activo
      ref
          .read(clockingSessionNotifierProvider.notifier)
          .setActiveRecord(recordId, now);

      // 🔄 Invalidar provider para actualizar UI inmediatamente
      ref.invalidate(todayRecordsProvider);
      debugPrint('🔄 [clockIn] Provider invalidado');
    });
  }

  /// Iniciar pausa
  ///
  /// ACTUALIZA el registro anterior (entrada-pausa) con endTime real.
  /// CREA nuevo registro temporal breakTime (startTime=endTime).
  ///
  /// Uso:
  /// ```dart
  /// await ref.read(clockingNotifierProvider.notifier).startBreak();
  /// ```
  Future<void> startBreak() async {
    debugPrint('🔵 [startBreak] Iniciando pausa...');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Usuario no autenticado');

      final now = DateTime.now();
      final timeRecordsService = TimeRecordsService();

      // Buscar registro activo usando recordStatus
      final todayRecords =
          await timeRecordsService.getDayRecords(user.userId, now).first;

      debugPrint(
          '🔍 [startBreak] Registros encontrados: ${todayRecords.length}');

      final activeRecord = todayRecords.firstWhere(
        (r) => r.isActive && r.category == RecordCategory.work,
        orElse: () => throw Exception('No hay registro de entrada activo'),
      );

      debugPrint(
          '✅ [startBreak] Registro activo encontrado: ${activeRecord.id}');

      // ⚛️ TRANSACCIÓN ATÓMICA: cerrar work + crear breakTime
      final updatedRecord = activeRecord.copyWith(
        endTime: _formatTime(now),
        durationMinutes:
            _calculateDuration(activeRecord.startTime, _formatTime(now)),
        recordStatus: RecordStatus.completed, // ✨ CERRADO
        updatedAt: now,
      );

      final breakRecord = TimeRecordModel(
        id: '',
        userId: user.userId,
        date: _formatDate(now),
        category: RecordCategory.breakTime,
        startTime: _formatTime(now),
        endTime: _formatTime(now),
        location: 'Oficina',
        durationMinutes: 0,
        recordStatus: RecordStatus.active, // ✨ ACTIVO
        createdAt: now,
        updatedAt: now,
        createdBy: user.userId,
        isManual: false,
        validationStatus: ValidationStatus.editable,
      );

      final breakRecordId = await timeRecordsService.updateAndCreateRecord(
        recordToUpdate: updatedRecord,
        recordToCreate: breakRecord,
      );

      debugPrint('✅ [startBreak] Transacción completada:');
      debugPrint(
          '  - Work cerrado: ${updatedRecord.id} (${updatedRecord.durationMinutes} min)');
      debugPrint('  - Break activo: $breakRecordId');

      // Actualizar sesión con nuevo registro activo
      ref
          .read(clockingSessionNotifierProvider.notifier)
          .setActiveRecord(breakRecordId, now);

      // 🔄 Invalidar provider para actualizar UI inmediatamente
      ref.invalidate(todayRecordsProvider);
      debugPrint(
          '🔄 [startBreak] Provider invalidado, esperando actualización...');
    });
  }

  /// Finalizar pausa
  ///
  /// CIERRA el registro de pausa (recordStatus = completed).
  /// CREA nuevo registro work activo (recordStatus = active).
  ///
  /// Uso:
  /// ```dart
  /// await ref.read(clockingNotifierProvider.notifier).endBreak();
  /// ```
  Future<void> endBreak() async {
    debugPrint('🔵 [endBreak] Finalizando pausa...');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Usuario no autenticado');

      final now = DateTime.now();
      final timeRecordsService = TimeRecordsService();

      // Buscar registro de pausa activo usando recordStatus
      final todayRecords =
          await timeRecordsService.getDayRecords(user.userId, now).first;

      final activeBreak = todayRecords.firstWhere(
        (r) => r.isActive && r.category == RecordCategory.breakTime,
        orElse: () => throw Exception('No hay pausa activa'),
      );

      debugPrint('✅ [endBreak] Pausa activa encontrada: ${activeBreak.id}');

      // ⚛️ TRANSACCIÓN ATÓMICA: cerrar break + crear work
      final updatedBreak = activeBreak.copyWith(
        endTime: _formatTime(now),
        durationMinutes:
            _calculateDuration(activeBreak.startTime, _formatTime(now)),
        recordStatus: RecordStatus.completed, // ✨ CERRADO
        updatedAt: now,
      );

      final workRecord = TimeRecordModel(
        id: '',
        userId: user.userId,
        date: _formatDate(now),
        category: RecordCategory.work,
        startTime: _formatTime(now),
        endTime: _formatTime(now),
        location: 'Oficina',
        durationMinutes: 0,
        recordStatus: RecordStatus.active, // ✨ ACTIVO
        createdAt: now,
        updatedAt: now,
        createdBy: user.userId,
        isManual: false,
        validationStatus: ValidationStatus.editable,
      );

      final workRecordId = await timeRecordsService.updateAndCreateRecord(
        recordToUpdate: updatedBreak,
        recordToCreate: workRecord,
      );

      debugPrint('✅ [endBreak] Transacción completada:');
      debugPrint(
          '  - Break cerrado: ${updatedBreak.id} (${updatedBreak.durationMinutes} min)');
      debugPrint('  - Work activo: $workRecordId');

      // Actualizar sesión
      ref
          .read(clockingSessionNotifierProvider.notifier)
          .setActiveRecord(workRecordId, now);

      // 🔄 Invalidar provider para actualizar UI inmediatamente
      ref.invalidate(todayRecordsProvider);
    });
  }

  /// Fichar salida
  ///
  /// CIERRA el último registro work (recordStatus = completed).
  /// Resetea la sesión temporal (jornada completada).
  ///
  /// Uso:
  /// ```dart
  /// await ref.read(clockingNotifierProvider.notifier).clockOut();
  /// ```
  Future<void> clockOut() async {
    debugPrint('🔵 [clockOut] Fichando salida...');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Usuario no autenticado');

      final now = DateTime.now();
      final timeRecordsService = TimeRecordsService();

      // Buscar registro activo usando recordStatus
      final todayRecords =
          await timeRecordsService.getDayRecords(user.userId, now).first;

      final activeRecord = todayRecords.firstWhere(
        (r) => r.isActive,
        orElse: () => throw Exception('No hay registro activo'),
      );

      debugPrint(
          '✅ [clockOut] Registro activo encontrado: ${activeRecord.id} (${activeRecord.category.name})');

      // Verificar que no sea un registro de pausa activo
      if (activeRecord.category == RecordCategory.breakTime) {
        throw Exception('Debes finalizar la pausa antes de fichar salida');
      }

      // CERRAR último registro work
      final updatedRecord = activeRecord.copyWith(
        endTime: _formatTime(now),
        durationMinutes:
            _calculateDuration(activeRecord.startTime, _formatTime(now)),
        recordStatus: RecordStatus.completed, // ✨ CERRADO
        updatedAt: now,
      );
      await timeRecordsService.updateRecord(updatedRecord);

      debugPrint(
          '✅ [clockOut] Registro cerrado: ${updatedRecord.id} (${updatedRecord.durationMinutes} min)');

      // Resetear sesión (jornada completada)
      ref.read(clockingSessionNotifierProvider.notifier).reset();

      // 🔄 Invalidar provider para actualizar UI inmediatamente
      ref.invalidate(todayRecordsProvider);
      debugPrint('✅ [clockOut] Jornada completada');
    });
  }
}

// ==============================================================================
// HELPERS - Formateo y Cálculos
// ==============================================================================

/// Obtener fecha en formato YYYY-MM-DD
String _formatDate(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
}

/// Formatear DateTime a string HH:mm
String _formatTime(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

/// Calcular duración en minutos entre dos horas "HH:mm"
int _calculateDuration(String startTime, String endTime) {
  try {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    return endMinutes - startMinutes;
  } catch (e) {
    return 0;
  }
}
