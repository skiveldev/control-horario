import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../models/calendar_event_model.dart';
import '../../models/holiday_type.dart';
import '../../models/work_calendar_model.dart';
import '../widgets/day_editor_dialog.dart';

/// Pantalla de edición de un calendario laboral
///
/// Permite al administrador:
/// - Nombrar el calendario y elegir el año
/// - Marcar festivos nacionales, autonómicos, locales y vacaciones
/// - Usar rangos de fechas para periodos vacacionales
/// - Ver el resumen lateral de todos los días marcados
///
/// MOCK DATA: Reemplazar con Riverpod provider en Fase 2 (calendarManagementProvider)
class CalendarEditorScreen extends StatefulWidget {
  /// Calendario existente (null para crear nuevo)
  final WorkCalendarModel? existingCalendar;

  const CalendarEditorScreen({super.key, this.existingCalendar});

  @override
  State<CalendarEditorScreen> createState() => _CalendarEditorScreenState();
}

class _CalendarEditorScreenState extends State<CalendarEditorScreen> {
  late TextEditingController _nameController;
  late int _selectedYear;
  late bool _isActive;
  late List<CalendarEventModel> _events;

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

  void _saveCalendar() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El nombre del calendario es obligatorio')),
      );
      return;
    }

    // MOCK: En Fase 2 llamar a calendarManagementProvider.notifier.save(...)
    final calendar = WorkCalendarModel(
      id: widget.existingCalendar?.id ??
          'cal_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      year: _selectedYear,
      events: _events,
      isActive: _isActive,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calendario "${calendar.name}" guardado'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).pop(calendar);
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= Breakpoints.desktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.existingCalendar == null
            ? 'Nuevo Calendario'
            : 'Editar Calendario',
        style: AppTextStyles.h5,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: CustomButton(
            text: 'Guardar Calendario',
            icon: Icons.save_outlined,
            variant: ButtonVariant.brand,
            onPressed: _saveCalendar,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.border),
      ),
    );
  }

  // Desktop: Calendario a la izquierda, resumen a la derecha
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel izquierdo: formulario + calendario
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: AppSpacing.allXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormFields(),
                AppSpacing.verticalSpaceXl,
                _buildCalendarSection(),
              ],
            ),
          ),
        ),

        // Divisor
        VerticalDivider(width: 1, color: AppColors.border),

        // Panel derecho: resumen de festivos
        SizedBox(
          width: 300,
          child: _buildEventsSummary(),
        ),
      ],
    );
  }

  // Mobile: Apilado verticalmente
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: AppSpacing.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormFields(),
          AppSpacing.verticalSpaceXl,
          _buildCalendarSection(),
          AppSpacing.verticalSpaceXl,
          _buildEventsSummaryMobile(),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECCIÓN: FORMULARIO SUPERIOR
  // ===========================================================================

  Widget _buildFormFields() {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Información del Calendario', style: AppTextStyles.h6),
          AppSpacing.verticalSpaceMd,
          Row(
            children: [
              // Nombre
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del calendario *',
                    hintText: 'Ej: Madrid 2025',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    contentPadding: AppSpacing.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              AppSpacing.horizontalSpaceMd,

              // Año
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<int>(
                  key: ValueKey(_selectedYear),
                  initialValue: _selectedYear,
                  decoration: InputDecoration(
                    labelText: 'Año',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
              ),
              AppSpacing.horizontalSpaceMd,

              // Estado (Activo / Borrador)
              Row(
                children: [
                  Text(
                    _isActive ? 'Activo' : 'Borrador',
                    style: AppTextStyles.labelMedium,
                  ),
                  Switch(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    activeThumbColor: AppColors.success,
                  ),
                ],
              ),
            ],
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
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
                    Text(
                      'Toca un día para añadir o editar un festivo',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSpaceSm,
                _buildLegend(),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.border),

          // TableCalendar
          TableCalendar<CalendarEventModel>(
            firstDay: DateTime(_selectedYear, 1, 1),
            lastDay: DateTime(_selectedYear, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _eventsForDay,
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
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
                color: Colors.transparent,
              ),
              markersMaxCount: 0,
              cellMargin: const EdgeInsets.all(4),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final events = _eventsForDay(day);
                if (events.isEmpty) return null;

                final event = events.first;
                final color = _colorForType(event.type);

                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final events = _eventsForDay(day);
                if (events.isNotEmpty) {
                  final event = events.first;
                  final color = _colorForType(event.type);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
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
                color: AppColors.textSecondary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Festivos configurados', style: AppTextStyles.h6),
              AppSpacing.verticalSpaceSm,
              Text(
                '${_events.length} días marcados',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: AppColors.border),
        Expanded(
          child: _buildEventsList(),
        ),
      ],
    );
  }

  Widget _buildEventsSummaryMobile() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.allLg,
            child: Row(
              children: [
                Text('Festivos configurados', style: AppTextStyles.h6),
                const Spacer(),
                Text(
                  '${_events.length} días',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          SizedBox(
            height: 320,
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_events.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.allXl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 40,
                color: AppColors.textTertiary,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Sin festivos',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.verticalSpaceSm,
              Text(
                'Toca un día en el calendario para añadir',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Agrupar por tipo y ordenar por fecha
    final sortedEvents = List<CalendarEventModel>.from(_events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final formatter = DateFormat('d MMM', 'es');

    return ListView.separated(
      padding: AppSpacing.allMd,
      itemCount: sortedEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        final color = _colorForType(event.type);

        return ListTile(
          dense: true,
          contentPadding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: 0,
          ),
          leading: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          title: Text(
            event.name,
            style: AppTextStyles.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${formatter.format(event.date)} · ${event.type.shortLabel}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 14),
            color: AppColors.textTertiary,
            onPressed: () {
              setState(() {
                _events.removeWhere((e) => e.id == event.id);
              });
            },
          ),
        );
      },
    );
  }
}
