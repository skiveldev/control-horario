import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';
import '../../../../shared/widgets/cards/stat_card.dart';

/// Panel de administración
/// 
/// Vista principal del admin con estadísticas y accesos rápidos.
/// 
/// MOCK DATA: Usa MockData.adminStats
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockData.adminStats;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Panel de Administración',
        showAvatar: true,
        onAvatarTap: () => context.push(AppRouter.profile),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          context.responsiveValue(
            mobile: AppSpacing.lg,
            tablet: AppSpacing.xxl,
            desktop: AppSpacing.xxxl,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Resumen General',
              style: AppTextStyles.h3,
            ),

            AppSpacing.verticalSpaceLg,

            // Grid de estadísticas
            _buildStatsGrid(context, stats),

            AppSpacing.verticalSpaceXxl,

            // Accesos rápidos
            Text(
              'Accesos Rápidos',
              style: AppTextStyles.h4,
            ),

            AppSpacing.verticalSpaceLg,

            _buildQuickAccessGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    final columns = context.columns;
    final gap = context.gridGap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGaps = (columns - 1) * gap;
        final availableWidth = constraints.maxWidth - totalGaps;
        final cardWidth = availableWidth / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.people,
                label: 'Total Empleados',
                value: stats['totalEmployees'].toString(),
                color: AppColors.primary,
                onTap: () => context.push(AppRouter.adminEmployees),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.check_circle,
                label: 'Fichados Hoy',
                value: stats['clockedInToday'].toString(),
                color: AppColors.success,
                trend: '+${stats['clockedInToday']}',
                trendPositive: true,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.warning,
                label: 'Ausencias',
                value: stats['absencesToday'].toString(),
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.pending,
                label: 'Solicitudes',
                value: stats['pendingRequests'].toString(),
                color: AppColors.info,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    final quickAccess = [
      {
        'icon': Icons.people,
        'title': 'Gestionar Empleados',
        'subtitle': 'Ver, crear y editar empleados',
        'color': AppColors.primary,
        'route': AppRouter.adminEmployees,
      },
      {
        'icon': Icons.schedule,
        'title': 'Gestión de Horarios',
        'subtitle': 'Plantillas y horarios personalizados',
        'color': AppColors.info,
        'route': AppRouter.adminSchedules,
      },
      {
        'icon': Icons.assignment,
        'title': 'Reportes',
        'subtitle': 'Informes y estadísticas',
        'color': AppColors.secondary,
        'route': null, // No implementado aún
      },
      {
        'icon': Icons.settings,
        'title': 'Configuración',
        'subtitle': 'Ajustes del sistema',
        'color': AppColors.accent,
        'route': AppRouter.settings,
      },
    ];

    return Column(
      children: quickAccess.map((item) {
        return Padding(
          padding: AppSpacing.verticalSm,
          child: _buildQuickAccessCard(context, item),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    return InkWell(
      onTap: item['route'] != null
          ? () => context.push(item['route'] as String)
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función en desarrollo')),
              );
            },
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: AppSpacing.allLg,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.allMd,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                item['icon'] as IconData,
                size: AppSpacing.iconXl,
                color: item['color'] as Color,
              ),
            ),

            AppSpacing.horizontalSpaceLg,

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: AppTextStyles.h5,
                  ),
                  AppSpacing.verticalSpaceXs,
                  Text(
                    item['subtitle'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

