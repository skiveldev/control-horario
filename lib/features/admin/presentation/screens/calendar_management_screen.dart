import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../models/work_calendar_model.dart';
import '../widgets/calendar_card.dart';
import 'calendar_editor_screen.dart';

/// Pantalla de gestión de calendarios laborales (Admin)
///
/// Lista los calendarios creados (festivos nacionales, autonómicos y vacaciones)
/// y permite al administrador crear, editar, duplicar o eliminar calendarios.
///
/// MOCK DATA: Reemplazar con Riverpod provider en Fase 2 (calendarManagementProvider)
class CalendarManagementScreen extends StatefulWidget {
  const CalendarManagementScreen({super.key});

  @override
  State<CalendarManagementScreen> createState() =>
      _CalendarManagementScreenState();
}

class _CalendarManagementScreenState extends State<CalendarManagementScreen> {
  // MOCK DATA: Reemplazar con Riverpod provider en Fase 2
  late List<WorkCalendarModel> _calendars;

  @override
  void initState() {
    super.initState();
    _calendars = List.from(mockWorkCalendars);
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRouter.adminCalendars,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              AppSpacing.verticalSpaceXl,
              _calendars.isEmpty
                  ? _buildEmptyState(context)
                  : _buildCalendarList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < Breakpoints.tablet;
    final count = _calendars.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calendarios Laborales', style: AppTextStyles.h3),
              AppSpacing.verticalSpaceSm,
              Text(
                'Gestiona festivos y vacaciones por región. '
                'Tienes $count ${count == 1 ? 'calendario disponible' : 'calendarios disponibles'}.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.horizontalSpaceLg,
        CustomButton(
          text: isMobile ? '' : 'Nuevo Calendario',
          icon: Icons.add,
          variant: ButtonVariant.brand,
          size: ButtonSize.large,
          onPressed: () => _navigateToEditor(context),
        ),
      ],
    );
  }

  Widget _buildCalendarList(BuildContext context) {
    final columns = MediaQuery.of(context).size.width >= Breakpoints.desktop
        ? 2
        : MediaQuery.of(context).size.width >= Breakpoints.tablet
            ? 2
            : 1;
    final gap = AppSpacing.lg;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGaps = (columns - 1) * gap;
        final availableWidth = constraints.maxWidth - totalGaps;
        final cardWidth = availableWidth / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _calendars.map((calendar) {
            return SizedBox(
              width: cardWidth,
              child: CalendarCard(
                calendar: calendar,
                onEdit: () => _navigateToEditor(context, calendar: calendar),
                onDuplicate: () => _duplicateCalendar(calendar),
                onDelete: () => _confirmDelete(context, calendar),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.allHuge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.verticalSpaceLg,
            Text(
              'No hay calendarios disponibles',
              style: AppTextStyles.h4,
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              'Crea tu primer calendario laboral para gestionar festivos y vacaciones',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceLg,
            CustomButton(
              text: 'Crear Calendario',
              icon: Icons.add,
              variant: ButtonVariant.brand,
              onPressed: () => _navigateToEditor(context),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context,
      {WorkCalendarModel? calendar}) async {
    final result = await Navigator.of(context).push<WorkCalendarModel>(
      MaterialPageRoute(
        builder: (_) => CalendarEditorScreen(existingCalendar: calendar),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _calendars.indexWhere((c) => c.id == result.id);
        if (index >= 0) {
          _calendars[index] = result;
        } else {
          _calendars.add(result);
        }
      });
    }
  }

  void _duplicateCalendar(WorkCalendarModel original) {
    // MOCK: Reemplazar con provider en Fase 2
    final duplicate = original.copyWith(
      id: '${original.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
      name: '${original.name} (copia)',
      isActive: false,
    );
    setState(() => _calendars.add(duplicate));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calendario "${original.name}" duplicado'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WorkCalendarModel calendar) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar calendario'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${calendar.name}"?\n\n'
          'Los empleados asignados a este calendario quedarán sin calendario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(
                  () => _calendars.removeWhere((c) => c.id == calendar.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calendario "${calendar.name}" eliminado'),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
