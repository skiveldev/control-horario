// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_work_calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$employeeWorkCalendarHash() =>
    r'357e321c84bf1b45ef1acc5fcbb39265e5372054';

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
///
/// Copied from [employeeWorkCalendar].
@ProviderFor(employeeWorkCalendar)
final employeeWorkCalendarProvider =
    AutoDisposeStreamProvider<WorkCalendarModel?>.internal(
  employeeWorkCalendar,
  name: r'employeeWorkCalendarProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$employeeWorkCalendarHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EmployeeWorkCalendarRef
    = AutoDisposeStreamProviderRef<WorkCalendarModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
