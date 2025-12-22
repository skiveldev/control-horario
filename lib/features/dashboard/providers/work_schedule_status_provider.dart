import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';

part 'work_schedule_status_provider.g.dart';

/// Estado del horario laboral
class WorkScheduleStatus {
  /// Si el empleado está dentro de su horario laboral
  final bool isInWorkSchedule;

  /// Fecha actual formateada (ej: "Lunes, 8 de Diciembre de 2025")
  final String formattedDate;

  /// Hora de entrada del horario (ej: "09:00")
  final String scheduleStart;

  /// Hora de salida del horario (ej: "18:00")
  final String scheduleEnd;

  const WorkScheduleStatus({
    required this.isInWorkSchedule,
    required this.formattedDate,
    required this.scheduleStart,
    required this.scheduleEnd,
  });
}

/// Provider que calcula si el usuario está en horario laboral o fuera de horario
///
/// Lógica:
/// - Obtiene el horario del usuario desde auth
/// - Compara la hora actual con el rango de horario
/// - Retorna estado + fecha formateada en español
///
/// TODO [FASE-2]: Considerar:
/// - Días festivos y fines de semana
/// - Horarios flexibles o turnos
/// - Zonas horarias
@riverpod
class WorkScheduleStatusNotifier extends _$WorkScheduleStatusNotifier {
  @override
  WorkScheduleStatus build() {
    // Obtener usuario actual
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return _getDefaultStatus();
        }

        // Obtener horario del usuario (formato: "09:00 - 18:00")
        final schedule = user.schedule ?? '09:00 - 18:00';
        final scheduleParts = schedule.split(' - ');

        if (scheduleParts.length != 2) {
          return _getDefaultStatus();
        }

        final scheduleStart = scheduleParts[0].trim();
        final scheduleEnd = scheduleParts[1].trim();

        // Calcular si está en horario
        final isInWorkSchedule = _isCurrentlyInWorkSchedule(
          scheduleStart,
          scheduleEnd,
        );

        // Formatear fecha actual
        final formattedDate = _formatCurrentDate();

        return WorkScheduleStatus(
          isInWorkSchedule: isInWorkSchedule,
          formattedDate: formattedDate,
          scheduleStart: scheduleStart,
          scheduleEnd: scheduleEnd,
        );
      },
      loading: () => _getDefaultStatus(),
      error: (_, __) => _getDefaultStatus(),
    );
  }

  /// Verifica si la hora actual está dentro del rango de horario laboral
  bool _isCurrentlyInWorkSchedule(String startTime, String endTime) {
    try {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;

      // Parsear hora de inicio
      final startParts = startTime.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);

      // Parsear hora de fin
      final endParts = endTime.split(':');
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      // Convertir a minutos desde medianoche para comparar
      final currentMinutes = currentHour * 60 + currentMinute;
      final startMinutes = startHour * 60 + startMinute;
      final endMinutes = endHour * 60 + endMinute;

      // Verificar si está dentro del rango
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } catch (e) {
      // En caso de error de parseo, asumir fuera de horario
      return false;
    }
  }

  /// Formatea la fecha actual en español (ej: "Lunes, 8 de Diciembre de 2025")
  String _formatCurrentDate() {
    final now = DateTime.now();

    // Nombres de días en español
    const daysOfWeek = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    // Nombres de meses en español
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final dayOfWeek = daysOfWeek[now.weekday - 1];
    final day = now.day;
    final month = months[now.month - 1];
    final year = now.year;

    return '$dayOfWeek, $day de $month de $year';
  }

  /// Estado por defecto cuando no hay datos
  WorkScheduleStatus _getDefaultStatus() {
    return WorkScheduleStatus(
      isInWorkSchedule: false,
      formattedDate: _formatCurrentDate(),
      scheduleStart: '09:00',
      scheduleEnd: '18:00',
    );
  }

  /// Actualiza manualmente el estado (útil para forzar recálculo)
  void refresh() {
    ref.invalidateSelf();
  }
}
