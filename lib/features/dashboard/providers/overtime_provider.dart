import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/overtime_request_model.dart';
import '../services/overtime_service.dart';

/// Provider para el servicio de horas extra (sobreescribible en tests)
final overtimeServiceProvider = Provider<OvertimeService>((ref) {
  return OvertimeService();
});

/// Estado del notifier de horas extra
class OvertimeState {
  final bool isProcessing;

  const OvertimeState({this.isProcessing = false});

  OvertimeState copyWith({bool? isProcessing}) {
    return OvertimeState(isProcessing: isProcessing ?? this.isProcessing);
  }
}

/// Notifier para gestionar solicitudes de horas extra.
///
/// Métodos principales:
/// - [checkAndCreateIfNeeded]: crea una solicitud pendiente si las
///   horas reales superan las horas semanales contratadas.
/// - [approveRequest]: aprueba una solicitud pendiente.
/// - [rejectRequest]: rechaza una solicitud pendiente.
///
/// Ejemplo de uso:
/// ```dart
/// final notifier = ref.read(overtimeNotifierProvider.notifier);
/// await notifier.checkAndCreateIfNeeded(
///   userId: 'user-1',
///   weekStart: mondayOfWeek,
///   weeklyHours: 40,
///   actualHours: 44,
/// );
/// ```
class OvertimeNotifier extends StateNotifier<OvertimeState> {
  final OvertimeService _service;

  OvertimeNotifier(this._service) : super(const OvertimeState());

  /// Verifica si las horas reales superan las contratadas y crea una
  /// solicitud de horas extra pendiente si corresponde.
  Future<void> checkAndCreateIfNeeded({
    required String userId,
    required DateTime weekStart,
    required double weeklyHours,
    required double actualHours,
  }) async {
    if (actualHours <= weeklyHours) return;

    final overtime = actualHours - weeklyHours;
    state = state.copyWith(isProcessing: true);
    try {
      await _service.createRequest(
        userId: userId,
        weekStart: weekStart,
        requestedHours: overtime,
      );
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Aprueba una solicitud de horas extra pendiente.
  Future<void> approveRequest(String id, {required String approvedBy}) async {
    state = state.copyWith(isProcessing: true);
    try {
      await _service.approveRequest(id, approvedBy: approvedBy);
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Rechaza una solicitud de horas extra pendiente.
  Future<void> rejectRequest(String id, {required String rejectedBy}) async {
    state = state.copyWith(isProcessing: true);
    try {
      await _service.rejectRequest(id, rejectedBy: rejectedBy);
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

/// Provider del notifier de horas extra.
final overtimeNotifierProvider =
    StateNotifierProvider<OvertimeNotifier, OvertimeState>((ref) {
  final service = ref.watch(overtimeServiceProvider);
  return OvertimeNotifier(service);
});
