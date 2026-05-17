import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/vacation_service.dart';

/// Provider para el servicio de vacaciones (sobreescribible en tests)
final vacationServiceProvider = Provider<VacationService>((ref) {
  return VacationService();
});

/// Estado del notifier de marcadores de vacaciones
class VacationMarkerState {
  final bool isProcessing;

  const VacationMarkerState({this.isProcessing = false});

  VacationMarkerState copyWith({bool? isProcessing}) {
    return VacationMarkerState(isProcessing: isProcessing ?? this.isProcessing);
  }
}

/// Notifier para añadir y quitar marcadores de vacaciones.
///
/// Gestiona la colección `employee_vacations` en Firestore.
/// Los marcadores son simples indicadores de día sin accruals ni flujos
/// de aprobación.
///
/// Métodos:
/// - [addVacation]: marca un día como vacaciones para un empleado.
/// - [removeVacation]: quita el marcador de vacaciones de un día.
///
/// Ejemplo de uso:
/// ```dart
/// final notifier = ref.read(vacationMarkerNotifierProvider.notifier);
/// await notifier.addVacation(
///   employeeId: 'user-1',
///   date: '2026-06-15',
///   markedBy: 'supervisor-1',
/// );
/// ```
class VacationMarkerNotifier extends StateNotifier<VacationMarkerState> {
  final VacationService _service;

  VacationMarkerNotifier(this._service) : super(const VacationMarkerState());

  /// Añade un marcador de vacaciones para un empleado en una fecha.
  Future<void> addVacation({
    required String employeeId,
    required String date,
    required String markedBy,
  }) async {
    state = state.copyWith(isProcessing: true);
    try {
      await _service.addVacation(
        employeeId: employeeId,
        date: date,
        markedBy: markedBy,
      );
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Elimina un marcador de vacaciones para un empleado en una fecha.
  Future<void> removeVacation({
    required String employeeId,
    required String date,
  }) async {
    state = state.copyWith(isProcessing: true);
    try {
      await _service.removeVacation(
        employeeId: employeeId,
        date: date,
      );
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

/// Provider del notifier de marcadores de vacaciones.
final vacationMarkerNotifierProvider =
    StateNotifierProvider<VacationMarkerNotifier, VacationMarkerState>((ref) {
  final service = ref.watch(vacationServiceProvider);
  return VacationMarkerNotifier(service);
});
