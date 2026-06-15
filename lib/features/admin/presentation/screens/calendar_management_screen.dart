import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calendarios Laborales',
                      style: AppTextStyles.h1.copyWith(color: cs.primary)),
                  const SizedBox(height: 6),
                  Text(
                    'Gestiona festivos nacionales, autonómicos, locales y '
                    'vacaciones. $total ${total == 1 ? 'calendario configurado' : 'calendarios configurados'}.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontalSpaceXl,
            CustomButton(
              text: 'Nuevo Calendario',
              icon: Icons.add,
              variant: ButtonVariant.brand,
              size: ButtonSize.medium,
              onPressed: onNavigateToEditor,
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
///
/// Sigue el grid de referencia: 4 cards separadas que juntas ocupan
/// el mismo ancho visual que el área de calendarios inferior.
/// Breakpoints: 1 col (mobile), 2 cols (≥640px), 4 cols (≥1024px).
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const double gap = 16.0; // Reference: gap-4

        int columns;
        if (width >= 1024) {
          columns = 4;
        } else if (width >= 640) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cardWidth = (width - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Total Calendarios',
                value: '$total',
                icon: Icons.calendar_today,
                color: cs.primary,
                // valueColor null → default cs.onSurface (reference default)
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Activos',
                value: '$activeCount',
                icon: Icons.check_circle,
                color: AppColors.success,
                valueColor: AppColors.success, // reference: text-secondary
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Nacionales 2026',
                value: '$totalHolidays',
                icon: Icons.flag,
                color: cs.primary, // reference: text-tertiary (deep blue)
                valueColor: cs.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Vacaciones',
                value: '$totalVacationDays días',
                icon: Icons.beach_access,
                color: AppColors
                    .success, // reference: on-secondary-container (teal)
                // valueColor null → default cs.onSurface (reference default)
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tarjeta individual de estadística.
///
/// Sigue el diseño de referencia: surface card, padding 20px, rounded-2xl,
/// borde visible, sombra sutil, icono 48x48, label uppercase, valor grande.
///
/// Reference: `bg-surface-container-lowest p-5 rounded-2xl shadow-sm
/// border border-outline-variant flex items-center gap-4`
///
/// [color] controls the icon and icon-background tint.
/// [valueColor] controls the large numeric value color. When null, the value
/// inherits [cs.onSurface] (matching the reference default for Total and
/// Vacaciones cards). When provided, the value uses the semantic color
/// (matching the reference `text-secondary` / `text-tertiary` classes for
/// Activos and Nacionales cards).
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20), // reference: p-5
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius:
            AppSpacing.borderRadiusLg, // reference: rounded-2xl (16px)
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon box — reference: w-12 h-12 rounded-xl (48x48, 12px radius)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius:
                  AppSpacing.borderRadiusMd, // reference: rounded-xl (12px)
            ),
            child: Icon(icon, size: 28, color: color), // reference: text-[28px]
          ),
          const SizedBox(width: 16), // reference: gap-4
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label — reference: font-label-sm text-label-sm uppercase tracking-wider
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.6,
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                // Value — reference: text-display-time font-display-time (48px, 700).
                // Semantic color per reference: Total/Vacaciones→default,
                // Activos→secondary, Nacionales→tertiary.
                Text(
                  value,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: valueColor ?? cs.onSurface,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
// CALENDAR GRID
// =============================================================================

class _CalendarGrid extends StatelessWidget {
  final ColorScheme cs;
  final List<WorkCalendarModel> calendars;
  final void Function(WorkCalendarModel?) onNavigateToEditor;
  final void Function(WorkCalendarModel) onDuplicateCalendar;
  final void Function(WorkCalendarModel) onConfirmDelete;

  const _CalendarGrid({
    required this.cs,
    required this.calendars,
    required this.onNavigateToEditor,
    required this.onDuplicateCalendar,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: calendars.map((calendar) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: CalendarCard(
            calendar: calendar,
            onEdit: () => onNavigateToEditor(calendar),
            onDuplicate: () => onDuplicateCalendar(calendar),
            onDelete: () => onConfirmDelete(calendar),
          ),
        );
      }).toList(),
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
                size: ButtonSize.medium,
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
