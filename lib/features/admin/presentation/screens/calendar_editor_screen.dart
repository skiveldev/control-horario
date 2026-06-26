import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../models/calendar_event_model.dart';
import '../../models/holiday_type.dart';
import '../../models/work_calendar_model.dart';
import '../../providers/calendar_management_provider.dart';
import '../widgets/day_editor_dialog.dart';

/// Pantalla de edición de un calendario laboral
///
/// Permite al administrador:
/// - Nombrar el calendario y elegir el año
/// - Marcar festivos nacionales, autonómicos, locales y vacaciones
/// - Usar rangos de fechas para periodos vacacionales
/// - Ver el resumen lateral de todos los días marcados
class CalendarEditorScreen extends ConsumerStatefulWidget {
  /// Calendario existente (null para crear nuevo)
  final WorkCalendarModel? existingCalendar;

  const CalendarEditorScreen({super.key, this.existingCalendar});

  @override
  ConsumerState<CalendarEditorScreen> createState() =>
      _CalendarEditorScreenState();
}

class CalendarEditorRouteScreen extends ConsumerWidget {
  final String calendarId;
  final WorkCalendarModel? existingCalendar;

  const CalendarEditorRouteScreen({
    super.key,
    required this.calendarId,
    this.existingCalendar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (calendarId == 'new') {
      return const CalendarEditorScreen();
    }

    final calendar = existingCalendar;
    if (calendar != null) {
      return CalendarEditorScreen(existingCalendar: calendar);
    }

    final calendarAsync = ref.watch(calendarByIdProvider(calendarId));
    return calendarAsync.when(
      data: (resolvedCalendar) {
        if (resolvedCalendar == null) {
          return const _CalendarEditorRouteError(
            message: 'Calendario no encontrado',
          );
        }

        return CalendarEditorScreen(existingCalendar: resolvedCalendar);
      },
      loading: () => const _CalendarEditorRouteLoading(),
      error: (error, _) => _CalendarEditorRouteError(
        message: 'Error al cargar el calendario: $error',
      ),
    );
  }
}

class _CalendarEditorRouteLoading extends StatelessWidget {
  const _CalendarEditorRouteLoading();

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      currentRoute: AppRouter.adminCalendars,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _CalendarEditorRouteError extends StatelessWidget {
  final String message;

  const _CalendarEditorRouteError({required this.message});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRouter.adminCalendars,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: AppTextStyles.bodyLarge),
            AppSpacing.verticalSpaceMd,
            CustomButton(
              text: 'Volver',
              variant: ButtonVariant.text,
              onPressed: () => context.go(AppRouter.adminCalendars),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarEditorScreenState extends ConsumerState<CalendarEditorScreen> {
  late TextEditingController _nameController;
  late int _selectedYear;
  late bool _isActive;
  late List<CalendarEventModel> _events;
  bool _isSaving = false;

  // Estado del TableCalendar
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<int> _availableYears = List.generate(
    5,
    (i) => DateTime.now().year + i - 1,
  );

  @override
  void initState() {
    super.initState();
    final cal = widget.existingCalendar;
    _nameController = TextEditingController(text: cal?.name ?? '');
    _selectedYear = cal?.year ?? DateTime.now().year;
    _isActive = cal?.isActive ?? true;
    _events = List.from(cal?.events ?? []);
    _focusedDay = DateTime(_selectedYear);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  List<CalendarEventModel> _eventsForDay(DateTime day) {
    return _events.where((e) => isSameDay(e.date, day)).toList();
  }

  List<CalendarEventModel> get _eventsForFocusedMonth => _events
      .where(
        (e) =>
            e.date.month == _focusedDay.month &&
            e.date.year == _focusedDay.year,
      )
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  Color _colorForType(HolidayType type) {
    switch (type) {
      case HolidayType.national:
        return AppColors.error;
      case HolidayType.regional:
        return AppColors.info;
      case HolidayType.local:
        return AppColors.warning;
      case HolidayType.vacation:
        return AppColors.success;
    }
  }

  Widget _buildEmptyDayCell(DateTime day) {
    return _HoverableDayCell(
      builder: (isHovered) => Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isHovered
              ? AppColors.primary.withValues(alpha: 0.04)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: isHovered
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isHovered
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventDayCell(DateTime day, CalendarEventModel event) {
    final color = _colorForType(event.type);
    final shortName = event.name.toUpperCase();

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            shortName,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ACCIONES
  // ===========================================================================

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    // Solo abrir el diálogo si el día pertenece al año del calendario
    if (selectedDay.year != _selectedYear) return;

    final existing = _eventsForDay(selectedDay);
    final existingEvent = existing.isNotEmpty ? existing.first : null;

    showDialog(
      context: context,
      builder: (_) => DayEditorDialog(
        selectedDate: selectedDay,
        existingEvent: existingEvent,
        onSave: (newEvents) {
          setState(() {
            // Eliminar eventos previos de ese día
            _events.removeWhere((e) => isSameDay(e.date, selectedDay));
            // Si era un rango, también limpiar solo el día inicial ya que
            // el rango genera eventos nuevos para cada día
            _events.addAll(newEvents);
          });
        },
        onDelete: existingEvent != null
            ? () {
                setState(() {
                  _events.removeWhere((e) => isSameDay(e.date, selectedDay));
                });
              }
            : null,
      ),
    );
  }

  Future<void> _saveCalendar() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El nombre del calendario es obligatorio')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(calendarManagementProvider.notifier).saveCalendar(
            calendarId: widget.existingCalendar?.id,
            name: name,
            year: _selectedYear,
            events: _events,
            isActive: _isActive,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calendario "$name" guardado'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.desktop;
    final cs = Theme.of(context).colorScheme;

    return AdminLayout(
      currentRoute: AppRouter.adminCalendars,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(cs),
          AppSpacing.verticalSpaceXxl,
          isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ],
      ),
    );
  }

  Widget _buildPageHeader(ColorScheme cs) {
    final title = widget.existingCalendar == null
        ? 'Nuevo Calendario'
        : 'Editar Calendario';

    return Container(
      padding: AppSpacing.allXl,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
        boxShadow: AppShadows.subtleShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < Breakpoints.tablet;

          final titleBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.secondary,
                  size: AppSpacing.iconXl,
                ),
              ),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3),
                    AppSpacing.verticalSpaceXs,
                    Text(
                      'Configura el calendario laboral, festivos y vacaciones del año seleccionado.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.verticalSpaceMd,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _buildHeroPill(
                          icon: Icons.event_available_outlined,
                          label: '$_selectedYear',
                          color: AppColors.secondary,
                        ),
                        _buildHeroPill(
                          icon: _isActive
                              ? Icons.check_circle_outline
                              : Icons.drafts_outlined,
                          label: _isActive ? 'Activo' : 'Borrador',
                          color: _isActive ? AppColors.success : cs.outline,
                        ),
                        _buildHeroPill(
                          icon: Icons.flag_outlined,
                          label: '${_events.length} días marcados',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
            children: [
              CustomButton(
                text: 'Cancelar',
                variant: ButtonVariant.text,
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              ),
              CustomButton(
                text: 'Guardar Calendario',
                icon: Icons.save_outlined,
                variant: ButtonVariant.brand,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveCalendar,
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleBlock,
                AppSpacing.verticalSpaceLg,
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              AppSpacing.horizontalSpaceXl,
              actions,
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Desktop: Calendario a la izquierda, sidebar card independiente a la derecha
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: formulario + calendario
        Expanded(
          child: Column(
            children: [
              _buildFormFields(),
              AppSpacing.verticalSpaceXl,
              _buildCalendarSection(),
            ],
          ),
        ),
        AppSpacing.horizontalSpaceXxl,
        // Sidebar: card independiente con su propio estilo
        SizedBox(
          width: 320,
          child: _buildEventsSummary(),
        ),
      ],
    );
  }

  // Mobile: Apilado verticalmente
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormFields(),
        AppSpacing.verticalSpaceXl,
        _buildCalendarSection(),
        AppSpacing.verticalSpaceXl,
        _buildEventsSummaryMobile(),
      ],
    );
  }

  // ===========================================================================
  // SECCIÓN: FORMULARIO SUPERIOR
  // ===========================================================================

  Widget _buildFormFields() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: AppShadows.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del card
          Padding(
            padding: AppSpacing.allLg,
            child: Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  size: AppSpacing.iconLg,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                AppSpacing.horizontalSpaceSm,
                Text('Información del Calendario', style: AppTextStyles.h6),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.outline),
          Padding(
            padding: AppSpacing.allLg,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < Breakpoints.tablet;
                final nameWidth = isCompact
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 260 - AppSpacing.md * 2);

                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.lg,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    // Nombre
                    SizedBox(
                      width: nameWidth.clamp(240.0, constraints.maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOMBRE DEL CALENDARIO *',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          AppSpacing.verticalSpaceXs,
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Ej: Calendario Laboral 2026',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              contentPadding: AppSpacing.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Año
                    SizedBox(
                      width: isCompact ? constraints.maxWidth : 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AÑO',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          AppSpacing.verticalSpaceXs,
                          DropdownButtonFormField<int>(
                            key: ValueKey(_selectedYear),
                            initialValue: _selectedYear,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              contentPadding: AppSpacing.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                            ),
                            items: _availableYears.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text('$year'),
                              );
                            }).toList(),
                            onChanged: (year) {
                              if (year != null) {
                                setState(() {
                                  _selectedYear = year;
                                  _focusedDay = DateTime(year);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Estado
                    SizedBox(
                      width: isCompact ? constraints.maxWidth : 120,
                      child: Column(
                        crossAxisAlignment: isCompact
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Text(
                            'ESTADO',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          AppSpacing.verticalSpaceXs,
                          Switch(
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                            activeThumbColor: AppColors.success,
                            activeTrackColor:
                                AppColors.success.withValues(alpha: 0.4),
                          ),
                          Text(
                            _isActive ? 'ACTIVO' : 'BORRADOR',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _isActive
                                  ? AppColors.success
                                  : Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECCIÓN: CALENDARIO VISUAL
  // ===========================================================================

  Widget _buildCalendarSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: AppShadows.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leyenda
          Padding(
            padding: AppSpacing.allLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Calendario $_selectedYear', style: AppTextStyles.h6),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        'Toca un día para añadir o editar un festivo',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceSm,
                _buildLegend(),
              ],
            ),
          ),

          Divider(height: 1, color: Theme.of(context).colorScheme.outline),

          // TableCalendar — Theme neutraliza el hover circular nativo
          Theme(
            data: Theme.of(context).copyWith(
              hoverColor: AppColors.transparent,
              highlightColor: AppColors.transparent,
              splashColor: AppColors.transparent,
            ),
            child: TableCalendar<CalendarEventModel>(
              firstDay: DateTime(_selectedYear, 1, 1),
              lastDay: DateTime(_selectedYear, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _eventsForDay,
              onDaySelected: _onDaySelected,
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
              },
              rowHeight: 72,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Mes',
              },
              locale: 'es_ES',
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: AppTextStyles.h6,
                leftChevronIcon: const Icon(Icons.chevron_left),
                rightChevronIcon: const Icon(Icons.chevron_right),
                headerPadding: AppSpacing.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.transparent,
                ),
                markersMaxCount: 0,
                cellMargin: const EdgeInsets.all(2),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final events = _eventsForDay(day);
                  if (events.isNotEmpty) {
                    return _buildEventDayCell(day, events.first);
                  }
                  return _buildEmptyDayCell(day);
                },
                todayBuilder: (context, day, focusedDay) {
                  final events = _eventsForDay(day);
                  if (events.isNotEmpty) {
                    return _buildEventDayCell(day, events.first);
                  }
                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  final events = _eventsForDay(day);
                  if (events.isNotEmpty) {
                    return _buildEventDayCell(day, events.first);
                  }
                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ), // Theme
          AppSpacing.verticalSpaceMd,
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: HolidayType.values.map((type) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colorForType(type).withValues(alpha: 0.2),
                border: Border.all(color: _colorForType(type), width: 1.5),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              type.shortLabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // SECCIÓN: RESUMEN DE FESTIVOS
  // ===========================================================================

  Widget _buildEventsSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: AppShadows.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.allLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Festivos configurados',
                        style: AppTextStyles.h6,
                      ),
                    ),
                    AppSpacing.horizontalSpaceSm,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusCircular),
                      ),
                      child: Text(
                        '${_eventsForFocusedMonth.length} Días',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  DateFormat('MMMM yyyy', 'es').format(_focusedDay),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.outline),
          _buildEventsList(_eventsForFocusedMonth),
        ],
      ),
    );
  }

  Widget _buildEventsSummaryMobile() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: AppShadows.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.allLg,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Festivos configurados',
                    style: AppTextStyles.h6,
                  ),
                ),
                AppSpacing.horizontalSpaceSm,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusCircular),
                  ),
                  child: Text(
                    '${_eventsForFocusedMonth.length} Días',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).colorScheme.outline),
          _buildEventsList(_eventsForFocusedMonth),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<CalendarEventModel> events) {
    if (events.isEmpty) {
      return Padding(
        padding: AppSpacing.allXl,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.outline,
            ),
            AppSpacing.verticalSpaceMd,
            Text(
              'Sin festivos',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              'Toca un día en el calendario para añadir',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sortedEvents = List<CalendarEventModel>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final formatter = DateFormat('d MMM', 'es');

    return ListView.separated(
      padding: AppSpacing.allMd,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedEvents.length,
      separatorBuilder: (_, __) => AppSpacing.verticalSpaceXs,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        final color = _colorForType(event.type);
        final typeLabel = event.type.shortLabel.toUpperCase();
        final dateStr = formatter.format(event.date);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              left: BorderSide(color: color, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.xs,
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeLabel,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.name,
                        style: AppTextStyles.labelMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 11,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              dateStr,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 14),
                  color: Theme.of(context).colorScheme.outline,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: () {
                    setState(() {
                      _events.removeWhere((e) => e.id == event.id);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HoverableDayCell extends StatefulWidget {
  final Widget Function(bool isHovered) builder;

  const _HoverableDayCell({required this.builder});

  @override
  State<_HoverableDayCell> createState() => _HoverableDayCellState();
}

class _HoverableDayCellState extends State<_HoverableDayCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(_isHovered),
    );
  }
}
