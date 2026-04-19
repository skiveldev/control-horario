import 'package:control_horario/features/dashboard/models/time_record_model.dart';
import 'package:control_horario/features/dashboard/presentation/helpers/team_validation_feedback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildTeamValidationSuccessMessage', () {
    test('incluye empleado, fecha y rango horario del registro validado', () {
      final message = buildTeamValidationSuccessMessage(
        memberName: 'Ana Bravo',
        record: _record(
          id: 'r1',
          userId: 'ana',
          date: '2026-04-12',
          startTime: '09:00',
          endTime: '13:00',
        ),
      );

      expect(
        message,
        'Registro de Ana Bravo validado correctamente (12/04/2026 · 09:00 - 13:00).',
      );
    });
  });

  group('buildTeamValidationFeedbackMessage', () {
    test('traduce el error por permisos fuera del equipo', () {
      expect(
        buildTeamValidationFeedbackMessage(
          Exception(
            'Sin permisos: solo puedes validar fichajes de tu propio equipo',
          ),
        ),
        'No tienes permiso para validar fichajes fuera de tu equipo.',
      );
    });

    test('traduce el error de rol insuficiente', () {
      expect(
        buildTeamValidationFeedbackMessage(
          Exception(
            'Sin permisos: solo administradores o supervisores pueden validar',
          ),
        ),
        'Solo administradores o supervisores pueden validar registros.',
      );
    });

    test('traduce el error de sesión expirada', () {
      expect(
        buildTeamValidationFeedbackMessage(
          Exception(
            'Sin permisos: necesitas iniciar sesión para validar registros',
          ),
        ),
        'Tu sesión ya no es válida. Vuelve a iniciar sesión para validar.',
      );
    });

    test('mantiene el detalle cuando el error no es de permisos conocidos', () {
      expect(
        buildTeamValidationFeedbackMessage(
            Exception('Error al validar registro')),
        'No se pudo validar el registro: Error al validar registro',
      );
    });
  });
}

TimeRecordModel _record({
  required String id,
  required String userId,
  required String date,
  required String startTime,
  required String endTime,
}) {
  return TimeRecordModel(
    id: id,
    userId: userId,
    date: date,
    category: RecordCategory.work,
    startTime: startTime,
    endTime: endTime,
    location: 'Centro',
    durationMinutes: 240,
    createdAt: DateTime(2026, 4, 1, 8),
    updatedAt: DateTime(2026, 4, 1, 8),
    createdBy: userId,
    isManual: true,
    recordStatus: RecordStatus.completed,
  );
}
