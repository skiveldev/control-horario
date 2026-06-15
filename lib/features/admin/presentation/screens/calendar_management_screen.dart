import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../models/work_calendar_model.dart';
import '../../providers/calendar_management_provider.dart';
import '../widgets/calendar_card.dart';

/// Pantalla de gestión de calendarios laborales (Admin)
///
/// Lista los calendarios creados (festivos nacionales, autonómicos y vacaciones)
/// y permite al administrador crear, editar, duplicar o eliminar calendarios.
class CalendarManagementScreen extends ConsumerWidget {
  const CalendarManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarsAsync = ref.watch(allCalendarsProvider);
    final cs = Theme.of(context).colorScheme;

    return AdminLayout(
      currentRoute: AppRouter.adminCalendars,
      child: calendarsAsync.when(
        data: (calendars) => calendars.isEmpty
            ? _EmptyState(
                cs: cs,
                ref: ref,
                onNavigateToEditor: () => _navigateToEditor(context))
            : _Content(
                cs: cs,
                ref: ref,
                calendars: calendars,
                onNavigateToEditor: (calendar) =>
                    _navigateToEditor(context, calendar: calendar),
                onDuplicateCalendar: (cal) =>
                    _duplicateCalendar(context, ref, cal),
                onConfirmDelete: (cal) => _confirmDelete(context, ref, cal)),
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(cs: cs, message: e.toString()),
      ),
    );
  }

  void _navigateToEditor(BuildContext context, {WorkCalendarModel? calendar}) {
    context.go('/admin/calendars/${calendar?.id ?? 'new'}/edit',
        extra: calendar);
  }

  Future<void> _duplicateCalendar(
    BuildContext context,
    WidgetRef ref,
    WorkCalendarModel original,
  ) async {
    try {
      await ref
          .read(calendarManagementProvider.notifier)
          .duplicateCalendar(original.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calendario "${original.name}" duplicado'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al duplicar: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WorkCalendarModel calendar,
  ) {
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(calendarManagementProvider.notifier)
                    .deleteCalendar(calendar.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calendario "${calendar.name}" eliminado'),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CONTENT STATE (calendars loaded)
// =============================================================================

class _Content extends StatelessWidget {
  final ColorScheme cs;
  final WidgetRef ref;
  final List<WorkCalendarModel> calendars;
  final void Function(WorkCalendarModel?) onNavigateToEditor;
  final void Function(WorkCalendarModel) onDuplicateCalendar;
  final void Function(WorkCalendarModel) onConfirmDelete;

  const _Content({
    required this.cs,
    required this.ref,
    required this.calendars,
    required this.onNavigateToEditor,
    required this.onDuplicateCalendar,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER INTRO ──
            _HeaderIntro(
                cs: cs,
                calendars: calendars,
                onNavigateToEditor: () => onNavigateToEditor(null)),
            AppSpacing.verticalSpaceXl,

            // ── STATS ROW ──
            _StatsRow(cs: cs, calendars: calendars),
            AppSpacing.verticalSpaceXl,

            // ── CALENDAR GRID ──
            _CalendarGrid(
              cs: cs,
              calendars: calendars,
              isDesktop: isDesktop,
              onNavigateToEditor: onNavigateToEditor,
              onDuplicateCalendar: onDuplicateCalendar,
              onConfirmDelete: onConfirmDelete,
            ),
            AppSpacing.verticalSpaceXl,

            // ── INFO CARD ──
            _InfoCard(cs: cs),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HEADER INTRO
// =============================================================================

/// Bloque superior con título, subtítulo, descripción y botón de acción.
class _HeaderIntro extends StatelessWidget {
  final ColorScheme cs;
  final List<WorkCalendarModel> calendars;
  final VoidCallback onNavigateToEditor;

  const _HeaderIntro({
    required this.cs,
    required this.calendars,
    required this.onNavigateToEditor,
  });

  @override
  Widget build(BuildContext context) {
    final total = calendars.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendarios Laborales',
                      style: AppTextStyles.h1.copyWith(color: cs.onSurface)),
                  AppSpacing.verticalSpaceSm,
                  Text('Panel de administración',
                      style: AppTextStyles.h4.copyWith(color: cs.primary)),
                  AppSpacing.verticalSpaceXs,
                  Text(
                    'Gestiona festivos nacionales, autonómicos, locales y '
                    'vacaciones. $total ${total == 1 ? 'calendario configurado' : 'calendarios configurados'}.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontalSpaceXxl,
            Flexible(
              child: CustomButton(
                text: 'Nuevo Calendario',
                icon: Icons.add,
                variant: ButtonVariant.brand,
                size: ButtonSize.large,
                onPressed: onNavigateToEditor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// STATS ROW
// =============================================================================

/// Fila de tarjetas con métricas honestas calculadas desde los datos reales.
class _StatsRow extends StatelessWidget {
  final ColorScheme cs;
  final List<WorkCalendarModel> calendars;

  const _StatsRow({required this.cs, required this.calendars});

  @override
  Widget build(BuildContext context) {
    final total = calendars.length;
    final activeCount = calendars.where((c) => c.isActive).length;
    final totalHolidays =
        calendars.fold<int>(0, (sum, c) => sum + c.totalHolidays);
    final totalVacationDays =
        calendars.fold<int>(0, (sum, c) => sum + c.totalVacationDays);

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _StatCard(
          label: 'Total',
          value: '$total',
          icon: Icons.calendar_month,
          color: cs.primary,
        ),
        _StatCard(
          label: 'Activos',
          value: '$activeCount',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        _StatCard(
          label: 'Festivos',
          value: '$totalHolidays',
          icon: Icons.flag_outlined,
          color: AppColors.error,
        ),
        _StatCard(
          label: 'Vacaciones',
          value: '$totalVacationDays días',
          icon: Icons.beach_access_outlined,
          color: AppColors.info,
        ),
      ],
    );
  }
}

/// Tarjeta individual de estadística.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allLg,
      constraints: const BoxConstraints(minWidth: 140),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(icon, size: AppSpacing.iconMd, color: color),
          ),
          AppSpacing.horizontalSpaceMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTextStyles.h5.copyWith(color: color),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CALENDAR GRID
// =============================================================================

class _CalendarGrid extends StatelessWidget {
  final ColorScheme cs;
  final List<WorkCalendarModel> calendars;
  final bool isDesktop;
  final void Function(WorkCalendarModel?) onNavigateToEditor;
  final void Function(WorkCalendarModel) onDuplicateCalendar;
  final void Function(WorkCalendarModel) onConfirmDelete;

  const _CalendarGrid({
    required this.cs,
    required this.calendars,
    required this.isDesktop,
    required this.onNavigateToEditor,
    required this.onDuplicateCalendar,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final columns = isDesktop ? 2 : 1;
    const gap = AppSpacing.lg;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGaps = (columns - 1) * gap;
        final availableWidth = constraints.maxWidth - totalGaps;
        final cardWidth = availableWidth / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: calendars.map((calendar) {
            return SizedBox(
              width: cardWidth,
              child: CalendarCard(
                calendar: calendar,
                onEdit: () => onNavigateToEditor(calendar),
                onDuplicate: () => onDuplicateCalendar(calendar),
                onDelete: () => onConfirmDelete(calendar),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// =============================================================================
// EMPTY STATE
// =============================================================================

class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  final WidgetRef ref;
  final VoidCallback onNavigateToEditor;

  const _EmptyState({
    required this.cs,
    required this.ref,
    required this.onNavigateToEditor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.giant,
            horizontal: AppSpacing.massive,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSpacing.avatarXxl,
                height: AppSpacing.avatarXxl,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: AppSpacing.iconXxl,
                  color: cs.primary,
                ),
              ),
              AppSpacing.verticalSpaceXl,
              Text(
                'No hay calendarios disponibles',
                style: AppTextStyles.h4.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Crea tu primer calendario laboral para empezar a gestionar '
                'festivos, vacaciones y jornadas especiales por región o departamento.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceXl,
              CustomButton(
                text: 'Crear Primer Calendario',
                icon: Icons.add,
                variant: ButtonVariant.brand,
                size: ButtonSize.large,
                onPressed: onNavigateToEditor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// INFO CARD
// =============================================================================

/// Tarjeta informativa sobre el uso de calendarios laborales.
class _InfoCard extends StatelessWidget {
  final ColorScheme cs;
  const _InfoCard({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allXxl,
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.15),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: cs.primaryContainer.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              Icons.info_outline,
              color: cs.primary,
              size: AppSpacing.iconLg,
            ),
          ),
          AppSpacing.horizontalSpaceLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Cómo funcionan los calendarios laborales?',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  'Cada calendario define los días festivos y jornadas especiales '
                  'de una región. Asígnelo a sus empleados para calcular '
                  'correctamente sus horas trabajadas.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LOADING STATE
// =============================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// =============================================================================
// ERROR STATE
// =============================================================================

class _ErrorState extends StatelessWidget {
  final ColorScheme cs;
  final String message;

  const _ErrorState({required this.cs, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          AppSpacing.verticalSpaceMd,
          Text(
            'Error al cargar calendarios',
            style: AppTextStyles.h4.copyWith(color: cs.onSurface),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
