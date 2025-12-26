import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_schedules.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../../shared/widgets/cards/schedule_card.dart';

/// Pantalla de gestión de horarios (Admin/RRHH)
///
/// Muestra lista de plantillas de horarios predefinidas.
/// En el MVP solo visualización, sin modales de edición.
///
/// MOCK DATA: Usa MockSchedules.templates
class ScheduleManagementScreen extends StatelessWidget {
  const ScheduleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // MOCK DATA: Obtener plantillas
    final templates = MockSchedules.templates;

    return AdminLayout(
      currentRoute: AppRouter.adminSchedules,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y descripción
              _buildHeader(templates.length),

              AppSpacing.verticalSpaceXl,

              // Lista de plantillas
              templates.isEmpty
                  ? _buildEmptyState()
                  : _buildTemplatesList(context, templates),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int templateCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plantillas de Horario', style: AppTextStyles.h3),
        AppSpacing.verticalSpaceSm,
        Text(
          'Plantillas predefinidas que puedes asignar a tus empleados. Tienes $templateCount ${templateCount == 1 ? 'plantilla disponible' : 'plantillas disponibles'}.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatesList(
    BuildContext context,
    List<Map<String, dynamic>> templates,
  ) {
    final columns = context.responsiveValue(
      mobile: 1,
      tablet: 2,
      desktop: 2,
    );
    final gap = context.gridGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGaps = (columns - 1) * gap;
        final availableWidth = constraints.maxWidth - totalGaps;
        final cardWidth = availableWidth / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: templates.map((template) {
            return SizedBox(
              width: cardWidth,
              child: ScheduleCard(
                name: template['name'] as String,
                description: template['description'] as String,
                weeklyHours: template['weeklyHours'] as int,
                usedByCount: template['usedByCount'] as int?,
                isTemplate: template['isTemplate'] as bool? ?? true,
                onTap: () {
                  // TODO [FASE-2]: Abrir modal de ver/editar plantilla
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ver detalles de: ${template['name']}',
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.allHuge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.verticalSpaceLg,
            Text(
              'No hay plantillas disponibles',
              style: AppTextStyles.h4,
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              'Crea tu primera plantilla de horario',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
