import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/time_record_model.dart';
import 'clocking_provider.dart';

part 'clocking_state_provider.g.dart';

// ==============================================================================
// ENUMS - Estados de Fichaje
// ==============================================================================

/// Estados posibles del fichaje diario
///
/// Representa en qué fase del día laboral se encuentra el empleado.
enum ClockingState {
  /// No ha fichado entrada aún
  notStarted,

  /// Ha fichado entrada, está trabajando
  working,

  /// Está en pausa (ha iniciado pausa pero no la ha finalizado)
  onBreak,

  /// Ha finalizado pausa, está trabajando de nuevo
  backFromBreak,

  /// Ha fichado salida, jornada completada
  finished,
}

// ==============================================================================
// PROVIDER - Estado Actual de Fichaje
// ==============================================================================

/// Provider que calcula el estado actual del fichaje
///
/// Usa el campo `recordStatus` para determinar si un registro está activo.
/// Esto es independiente de la duración (puedes fichar entrada/salida en el mismo minuto).
///
/// Lógica:
/// 1. No hay registros → notStarted
/// 2. Hay registro activo work → working
/// 3. Hay registro activo breakTime → onBreak
/// 4. Hay pausa completada + registro activo work → backFromBreak
/// 5. Todos los registros completados → finished
///
/// Uso:
/// ```dart
/// final state = ref.watch(currentClockingStateProvider);
/// if (state == ClockingState.working) {
///   // Mostrar botón "INICIAR PAUSA"
/// }
/// ```
@riverpod
ClockingState currentClockingState(CurrentClockingStateRef ref) {
  final recordsAsync = ref.watch(todayRecordsProvider);

  return recordsAsync.when(
    data: (records) {
      // 🔍 DEBUG: Log de registros
      debugPrint('📊 [ClockingState] Total records: ${records.length}');
      for (final record in records) {
        debugPrint(
            '  - ${record.category.name}: status=${record.recordStatus.name}, duration=${record.durationMinutes}min, ${record.startTime}-${record.endTime}');
      }

      // Caso 1: No hay registros → notStarted (botón ENTRADA habilitado)
      if (records.isEmpty) {
        debugPrint('✅ [ClockingState] Estado: notStarted (sin registros)');
        return ClockingState.notStarted;
      }

      // Buscar registro activo usando el campo explícito `recordStatus`
      final activeRecord = records.firstWhere(
        (r) => r.isActive,
        orElse: () => _emptyRecord(),
      );

      // Caso 2: Hay registro activo
      if (activeRecord.isActive) {
        // Si es pausa → onBreak (solo RETORNO habilitado)
        if (activeRecord.category == RecordCategory.breakTime) {
          debugPrint('✅ [ClockingState] Estado: onBreak (pausa activa)');
          return ClockingState.onBreak;
        }

        // Si es work, verificar si hubo pausa antes
        final hasCompletedBreak = records.any(
          (r) => r.category == RecordCategory.breakTime && r.isCompleted,
        );

        if (hasCompletedBreak) {
          // Hay pausa completada → backFromBreak (solo SALIDA habilitado)
          debugPrint(
              '✅ [ClockingState] Estado: backFromBreak (vuelta de pausa)');
          return ClockingState.backFromBreak;
        }

        // Es work sin pausa → working (PAUSA y SALIDA habilitados)
        debugPrint('✅ [ClockingState] Estado: working (trabajando)');
        return ClockingState.working;
      }

      // Caso 3: Todos los registros completados → finished
      // (botón ENTRADA habilitado para nueva jornada)
      debugPrint('✅ [ClockingState] Estado: finished (jornada completada)');
      return ClockingState.finished;
    },
    loading: () => ClockingState.notStarted,
    error: (_, __) => ClockingState.notStarted,
  );
}

/// Helper para crear un registro vacío (fallback)
TimeRecordModel _emptyRecord() {
  return TimeRecordModel(
    id: '',
    userId: '',
    date: '',
    category: RecordCategory.work,
    startTime: '',
    endTime: '',
    location: '',
    durationMinutes: -1,
    recordStatus:
        RecordStatus.completed, // ✨ Marcado como completado (no activo)
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    createdBy: '',
    isManual: false,
    validationStatus: ValidationStatus.editable,
  );
}

// ==============================================================================
// HELPERS - Información del Estado
// ==============================================================================

/// Extension para obtener información legible del estado
extension ClockingStateExtension on ClockingState {
  /// Texto descriptivo del estado
  String get displayText {
    switch (this) {
      case ClockingState.notStarted:
        return 'Sin fichar';
      case ClockingState.working:
        return 'Trabajando';
      case ClockingState.onBreak:
        return 'En pausa';
      case ClockingState.backFromBreak:
        return 'Trabajando';
      case ClockingState.finished:
        return 'Jornada finalizada';
    }
  }

  /// Indica si puede fichar entrada
  bool get canClockIn => this == ClockingState.notStarted;

  /// Indica si puede iniciar pausa
  bool get canStartBreak =>
      this == ClockingState.working || this == ClockingState.backFromBreak;

  /// Indica si puede finalizar pausa
  bool get canEndBreak => this == ClockingState.onBreak;

  /// Indica si puede fichar salida
  bool get canClockOut =>
      this == ClockingState.working || this == ClockingState.backFromBreak;
}
