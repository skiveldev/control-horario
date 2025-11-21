import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_schedules.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Gestión de Horarios',
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          context.responsiveValue(
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        ),
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
      ),
    );
  }

  Widget _buildHeader(int templateCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plantillas de Horario',
          style: AppTextStyles.h3,
        ),
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
      BuildContext context, List<Map<String, dynamic>> templates) {
    // Determinar número de columnas según ancho
    final columns = context.responsiveValue(
      mobile: 1,
      tablet: 2,
      desktop: 2,
    );

    final gap = context.gridGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular ancho de cada card
        final totalGaps = (columns - 1) * gap;
        final availableWidth = constraints.maxWidth - totalGaps;
        final cardWidth = availableWidth / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: templates.map((template) {
            return SizedBox(
              width: columns == 1 ? double.infinity : cardWidth,
              child: ScheduleCard(
                name: template['name'] as String,
                description: template['description'] as String,
                weeklyHours: template['weeklyHours'] as int,
                usedByCount: template['usedByCount'] as int?,
                isTemplate: true,
                createdAt: template['createdAt'] as String?,
                createdBy: template['createdBy'] as String?,
                onTap: () {
                  // TODO [FASE-2]: Abrir modal de detalle/edición
                  // Por ahora solo mostrar snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Detalle de plantilla "${template['name']}" (en desarrollo)',
                      ),
                      backgroundColor: AppColors.info,
                      duration: const Duration(seconds: 2),
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
    return Container(
      padding: AppSpacing.allXxl,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          AppSpacing.verticalSpaceLg,
          Text(
            'No hay plantillas creadas',
            style: AppTextStyles.h5,
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'Crea la primera plantilla para asignar a tus empleados',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpaceXl,
          // TODO [FASE-2]: Agregar botón para crear plantilla
          // Por ahora solo mensaje
          Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.info,
                ),
                AppSpacing.horizontalSpaceSm,
                Text(
                  'Función de creación disponible en Fase 2',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
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

