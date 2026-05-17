import 'package:control_horario/features/dashboard/models/anomaly_model.dart';

/// Crea una lista de anomalías de ejemplo para tests de widget.
List<AnomalyModel> mockAnomalies() {
  return [
    AnomalyModel(
      id: 'anom-1',
      userId: 'user-1',
      date: '2026-05-12',
      type: AnomalyType.missingExit,
      severity: AnomalySeverity.high,
      createdAt: DateTime(2026, 5, 12, 14),
      description: 'Fichaje activo sin salida',
    ),
    AnomalyModel(
      id: 'anom-2',
      userId: 'user-1',
      date: '2026-05-13',
      type: AnomalyType.insufficientHours,
      severity: AnomalySeverity.medium,
      createdAt: DateTime(2026, 5, 13, 18),
      description: 'Horas insuficientes: 4.0h de 8.0h',
    ),
    AnomalyModel(
      id: 'anom-3',
      userId: 'user-1',
      date: '2026-05-15',
      type: AnomalyType.unexcusedAbsence,
      severity: AnomalySeverity.high,
      createdAt: DateTime(2026, 5, 15, 9),
      description: 'Sin registros en día laborable',
    ),
  ];
}
