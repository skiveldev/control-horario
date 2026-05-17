import 'package:control_horario/features/dashboard/models/overtime_request_model.dart';

/// Crea una lista de solicitudes de horas extra de ejemplo para tests.
List<OvertimeRequestModel> mockOvertimeRequests() {
  return [
    OvertimeRequestModel(
      id: 'ot-1',
      userId: 'user-1',
      weekStart: DateTime(2026, 5, 11),
      requestedHours: 5.5,
      status: OvertimeRequestStatus.pending,
      createdAt: DateTime(2026, 5, 17),
    ),
    OvertimeRequestModel(
      id: 'ot-2',
      userId: 'user-2',
      weekStart: DateTime(2026, 5, 11),
      requestedHours: 2.0,
      status: OvertimeRequestStatus.pending,
      createdAt: DateTime(2026, 5, 17),
    ),
    OvertimeRequestModel(
      id: 'ot-3',
      userId: 'user-1',
      weekStart: DateTime(2026, 5, 4),
      requestedHours: 8.0,
      status: OvertimeRequestStatus.pending,
      createdAt: DateTime(2026, 5, 10),
    ),
  ];
}
