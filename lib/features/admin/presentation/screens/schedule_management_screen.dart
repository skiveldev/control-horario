import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../../shared/widgets/cards/schedule_card.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_management_provider.dart';
import '../widgets/schedule_template_modal.dart';

/// Pantalla de gestión de horarios (Admin/RRHH) — rediseño visual.
///
/// Muestra plantillas de horarios predefinidas desde Firebase con cards
/// bento-style y creación/edición vía modal.
///
/// ✅ Conectado a Firebase via allScheduleTemplatesProvider
class ScheduleManagementScreen extends ConsumerStatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  ConsumerState<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState
    extends ConsumerState<ScheduleManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(allScheduleTemplatesProvider);

    return AdminLayout(
      currentRoute: AppRouter.adminSchedules,
      child: templatesAsync.when(
        data: (templates) => _Content(
          templates: templates,
          onOpenModal: (template) =>
              _showTemplateModal(context, existingTemplate: template),
        ),
        loading: () => const _LoadingState(),
        error: (error, _) => _ErrorState(message: error.toString()),
      ),
    );
  }

  /// Mostrar modal de crear/editar plantilla
  void _showTemplateModal(
    BuildContext context, {
    required ScheduleModel? existingTemplate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScheduleTemplateModal(
        existingTemplate: existingTemplate,
      ),
    );
  }
}

// ============================================================================
// CONTENT (templates loaded)
// ============================================================================

class _Content extends StatefulWidget {
  final List<ScheduleModel> templates;
  final void Function(ScheduleModel?) onOpenModal;

  const _Content({
    required this.templates,
    required this.onOpenModal,
  });

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              _Header(
                activeTemplateCount: widget.templates
                    .where((template) => template.isActive)
                    .length,
                onOpenModal: widget.onOpenModal,
              ),

              AppSpacing.verticalSpaceXxl,

              // ── CARD GRID or EMPTY ──
              if (widget.templates.isEmpty)
                _EmptyState(
                  onOpenModal: widget.onOpenModal,
                )
              else
                _CardGrid(
                  templates: widget.templates,
                  onOpenModal: widget.onOpenModal,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

/// Bloque superior con título, subtítulo, contador y botón CTA.
///
/// Preserva el componente [CustomButton] existente de "Nueva Plantilla"
/// sin reemplazarlo por un estilo custom.
class _Header extends StatelessWidget {
  final int activeTemplateCount;
  final void Function(ScheduleModel?) onOpenModal;

  const _Header({
    required this.activeTemplateCount,
    required this.onOpenModal,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plantillas de Horario',
                style: AppTextStyles.h1.copyWith(color: cs.primary),
              ),
              const SizedBox(height: 6),
              Text(
                'Gestiona los esquemas de tiempo predefinidos que puedes '
                'asignar a tus empleados. Dispones de $activeTemplateCount '
                '${activeTemplateCount == 1 ? 'plantilla activa' : 'plantillas activas'}.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.horizontalSpaceXl,
        CustomButton(
          text: 'Nueva Plantilla',
          icon: Icons.add,
          variant: ButtonVariant.brand,
          size: ButtonSize.large,
          onPressed: () => onOpenModal(null),
        ),
      ],
    );
  }
}

// ============================================================================
// EMPTY STATE (no templates)
// ============================================================================

/// Estado vacío cuando no hay plantillas disponibles.
///
/// Muestra un CTA para crear la primera plantilla.
class _EmptyState extends StatelessWidget {
  final void Function(ScheduleModel?) onOpenModal;

  const _EmptyState({required this.onOpenModal});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
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
                  Icons.schedule_outlined,
                  size: AppSpacing.iconXxl,
                  color: cs.primary,
                ),
              ),
              AppSpacing.verticalSpaceXl,
              Text(
                'No hay plantillas disponibles',
                style: AppTextStyles.h4.copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Crea tu primera plantilla de horario para comenzar '
                'a gestionar los turnos de tus empleados.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceXl,
              CustomButton(
                text: 'Crear Plantilla',
                icon: Icons.add,
                variant: ButtonVariant.brand,
                size: ButtonSize.medium,
                onPressed: () => onOpenModal(null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CARD GRID
// ============================================================================

/// Grid responsive de tarjetas de plantilla.
///
/// Desktop (>= 1024px): 2 columnas.
/// Tablet/mobile: 1 columna.
class _CardGrid extends StatelessWidget {
  final List<ScheduleModel> templates;
  final void Function(ScheduleModel) onOpenModal;

  const _CardGrid({
    required this.templates,
    required this.onOpenModal,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= Breakpoints.desktop;

    // In our 1200px max-width container, 2 columns works best for cards.
    final columns = isDesktop ? 2 : 1;
    const double gap = AppSpacing.xl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGaps = (columns - 1) * gap;
        final cardWidth =
            columns > 1 ? (constraints.maxWidth - totalGaps) / columns : null;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: templates.map((template) {
            final w = cardWidth;
            return SizedBox(
              width: w,
              child: ScheduleCard(
                name: template.name,
                description: template.description,
                weeklyHours: template.totalWeeklyHours,
                usedByCount: template.usedByCount,
                isTemplate: template.isTemplate,
                createdBy: template.createdBy,
                onTap: () => onOpenModal(template),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================================
// LOADING STATE
// ============================================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.massive),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ============================================================================
// ERROR STATE
// ============================================================================

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.massive),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            AppSpacing.verticalSpaceMd,
            Text(
              'Error al cargar plantillas',
              style: AppTextStyles.h4.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: cs.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
