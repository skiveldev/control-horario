import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../admin/models/work_calendar_model.dart';
import '../../../admin/models/calendar_event_model.dart';
import '../../../admin/models/holiday_type.dart';
import '../../providers/employee_work_calendar_provider.dart';

/// Sección de calendario laboral anual para la pantalla del empleado
///
/// Muestra el calendario asignado con festivos, vacaciones y leyenda de colores.
/// Permite navegar mes a mes con botones de flechas.
///
/// Ejemplo de uso:
/// ```dart
/// AnnualCalendarSection()
/// ```
class AnnualCalendarSection extends ConsumerStatefulWidget {
  const AnnualCalendarSection({super.key});

  @override
  ConsumerState<AnnualCalendarSection> createState() =>
      _AnnualCalendarSectionState();
}

class _AnnualCalendarSectionState extends ConsumerState<AnnualCalendarSection> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(employeeWorkCalendarProvider);

    return calendarAsync.when(
      data: (calendar) {
        if (calendar == null) {
          return const _NoCalendarEmptyState();
        }
        return _buildCalendarContent(calendar);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.massive),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => _FirestoreErrorState(
        onRetry: () => ref.invalidate(employeeWorkCalendarProvider),
        errorMessage: error.toString(),
      ),
    );
  }

  Widget _buildCalendarContent(WorkCalendarModel calendar) {
    final eventsForFocusedMonth =
        _eventsForMonth(calendar.events, _focusedMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con nombre del calendario
        Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            AppSpacing.horizontalSpaceSm,
            Flexible(
              child: Text(
                calendar.name,
                style: AppTextStyles.h4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppSpacing.horizontalSpaceSm,
            Container(
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                '${calendar.year}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpaceMd,

        // Leyenda de colores
        const _CalendarLegend(),

        AppSpacing.verticalSpaceMd,

        // TableCalendar
        _buildTableCalendar(calendar),

        AppSpacing.verticalSpaceMd,

        // Lista de eventos del mes
        _MonthEventsList(
          events: eventsForFocusedMonth,
          month: _focusedMonth,
        ),
      ],
    );
  }

  Widget _buildTableCalendar(WorkCalendarModel calendar) {
    final eventsByDay = _groupEventsByDay(calendar.events);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: TableCalendar<CalendarEventModel>(
        locale: 'es_ES',
        focusedDay: _focusedMonth,
        firstDay: DateTime(calendar.year, 1, 1),
        lastDay: DateTime(calendar.year, 12, 31),
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle:
              (Theme.of(context).textTheme.bodyMedium ?? const TextStyle())
                  .copyWith(
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          headerPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
                  .copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          weekendStyle:
              (Theme.of(context).textTheme.labelSmall ?? const TextStyle())
                  .copyWith(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle:
              Theme.of(context).textTheme.bodySmall ?? const TextStyle(),
          weekendTextStyle:
              (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
                  .copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          todayDecoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle:
              (Theme.of(context).textTheme.bodySmall ?? const TextStyle())
                  .copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.transparent,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) =>
              _buildDayCell(day, eventsByDay),
          outsideBuilder: (context, day, focusedDay) => null,
        ),
        eventLoader: (day) {
          final key = _dayKey(day);
          return eventsByDay[key] ?? [];
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedMonth = focusedDay);
        },
        onDaySelected: null,
      ),
    );
  }

  Widget? _buildDayCell(
    DateTime day,
    Map<String, List<CalendarEventModel>> eventsByDay,
  ) {
    final key = _dayKey(day);
    final events = eventsByDay[key];

    if (events == null || events.isEmpty) {
      return null;
    }

    final primaryEvent = events.first;
    final color = _colorForType(primaryEvent.type);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Map<String, List<CalendarEventModel>> _groupEventsByDay(
    List<CalendarEventModel> events,
  ) {
    final map = <String, List<CalendarEventModel>>{};
    for (final event in events) {
      final key = _dayKey(event.date);
      map.putIfAbsent(key, () => []).add(event);
    }
    return map;
  }

  List<CalendarEventModel> _eventsForMonth(
    List<CalendarEventModel> events,
    DateTime month,
  ) {
    return events
        .where(
          (e) => e.date.year == month.year && e.date.month == month.month,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String _dayKey(DateTime day) => '${day.year}-${day.month}-${day.day}';
}

// =============================================================================
// HELPERS DE COLOR
// =============================================================================

Color _colorForType(HolidayType type) {
  switch (type) {
    case HolidayType.national:
      return AppColors.error;
    case HolidayType.regional:
      return AppColors.warning;
    case HolidayType.local:
      return AppColors.accent;
    case HolidayType.vacation:
      return AppColors.vacation;
  }
}

// =============================================================================
// SUBWIDGETS PRIVADOS
// =============================================================================

/// Leyenda de colores del calendario
class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _LegendItem(
          color: AppColors.error,
          label: HolidayType.national.shortLabel,
        ),
        _LegendItem(
          color: AppColors.warning,
          label: HolidayType.regional.shortLabel,
        ),
        _LegendItem(
          color: AppColors.accent,
          label: HolidayType.local.shortLabel,
        ),
        _LegendItem(
          color: AppColors.secondary,
          label: HolidayType.vacation.shortLabel,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.7)),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Lista de eventos del mes seleccionado
class _MonthEventsList extends StatelessWidget {
  final List<CalendarEventModel> events;
  final DateTime month;

  const _MonthEventsList({required this.events, required this.month});

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy', 'es').format(month);

    if (events.isEmpty) {
      return Padding(
        padding: AppSpacing.verticalMd,
        child: Text(
          'Sin eventos este mes',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Días especiales — ${monthName.toLowerCase()}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        AppSpacing.verticalSpaceSm,
        ...events.map((event) => _EventRow(event: event)),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final CalendarEventModel event;

  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(event.type);
    final dayStr = DateFormat('d MMM', 'es').format(event.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: AppSpacing.xl * 2,
            child: Text(
              dayStr,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              event.name,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            ),
            child: Text(
              event.type.shortLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío cuando el empleado no tiene calendario asignado
class _NoCalendarEmptyState extends StatelessWidget {
  const _NoCalendarEmptyState();

  @override
  Widget build(BuildContext context) {
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: AppSpacing.allXxl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: onSurfaceVar,
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'Sin calendario laboral asignado',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'Contacta con tu administrador para que te asigne un calendario.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onSurfaceVar,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Estado de error de Firestore con botón de reintento
class _FirestoreErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String? errorMessage;

  const _FirestoreErrorState({required this.onRetry, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: AppSpacing.allXxl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 64,
            color: onSurfaceVar,
          ),
          AppSpacing.verticalSpaceMd,
          Text(
            'Error al cargar el calendario',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            errorMessage ?? 'Comprueba tu conexión e inténtalo de nuevo.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: onSurfaceVar,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceLg,
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
