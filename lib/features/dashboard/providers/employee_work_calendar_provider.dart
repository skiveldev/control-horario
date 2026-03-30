import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../admin/models/work_calendar_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/firebase_service.dart';

part 'employee_work_calendar_provider.g.dart';

/// Stream del calendario laboral asignado al empleado autenticado
///
/// Combina currentUser (para obtener calendarId) con CalendarService
/// para escuchar en tiempo real el calendario asignado.
///
/// Emite:
/// - null si el usuario no tiene calendarId asignado
/// - WorkCalendarModel con los datos del calendario asignado
///
/// Ejemplo de uso:
/// ```dart
/// final calendarAsync = ref.watch(employeeWorkCalendarProvider);
/// calendarAsync.when(
///   data: (calendar) {
///     if (calendar == null) return Text('Sin calendario');
///     return Text(calendar.name);
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (e, _) => Text('Error: $e'),
/// );
/// ```
@riverpod
Stream<WorkCalendarModel?> employeeWorkCalendar(
    EmployeeWorkCalendarRef ref) async* {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null || user.calendarId == null) {
    yield null;
    return;
  }

  final service = ref.watch(calendarServiceProvider);
  yield* service.watchCalendarById(user.calendarId!);
}
