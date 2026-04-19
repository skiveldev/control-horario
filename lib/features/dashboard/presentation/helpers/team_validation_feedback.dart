import 'package:intl/intl.dart';
import '../../models/time_record_model.dart';

String buildTeamValidationSuccessMessage({
  required String memberName,
  required TimeRecordModel record,
}) {
  final parsedDate = DateTime.tryParse(record.date);
  final formattedDate = parsedDate == null
      ? record.date
      : DateFormat('dd/MM/yyyy').format(parsedDate);

  return 'Registro de $memberName validado correctamente '
      '($formattedDate · ${record.startTime} - ${record.endTime}).';
}

String buildTeamValidationFeedbackMessage(Object error) {
  final message = error.toString().replaceFirst('Exception: ', '').trim();

  if (message.contains('tu propio equipo')) {
    return 'No tienes permiso para validar fichajes fuera de tu equipo.';
  }

  if (message.contains('solo administradores o supervisores')) {
    return 'Solo administradores o supervisores pueden validar registros.';
  }

  if (message.contains('necesitas iniciar sesión')) {
    return 'Tu sesión ya no es válida. Vuelve a iniciar sesión para validar.';
  }

  return 'No se pudo validar el registro: $message';
}
