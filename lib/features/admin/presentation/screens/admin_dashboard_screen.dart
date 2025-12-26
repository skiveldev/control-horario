import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../../shared/widgets/cards/metric_card.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/recent_requests_list.dart';
import '../widgets/control_alerts_panel.dart';

/// Panel de administración - Rediseñado
///
/// Vista principal del admin con métricas, gráfico de actividad,
/// solicitudes recientes y alertas de control.
///
/// MOCK DATA: Usa MockData para todas las secciones
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockData.adminStats;

    return AdminLayout(
      currentRoute: AppRouter.admin,
      showSearch: true,
      onSearchChanged: (query) {
        // TODO [FASE-2]: Implementar búsqueda
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título
          _buildHeader(context),

          AppSpacing.verticalSpaceXxl,

          // Grid de métricas (4 cards)
          _buildMetricsGrid(context, stats),

          AppSpacing.verticalSpaceXxl,

          // Gráfico de actividad semanal
          WeeklyActivityChart(
            data: MockData.weeklyActivity,
          ),

          AppSpacing.verticalSpaceXxl,

          // Fila inferior: Solicitudes y Alertas
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: AppTextStyles.h3,
        ),
        AppSpacing.verticalSpaceXs,
        Text(
          'Bienvenido de nuevo, aquí está lo que ha pasado hoy.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, Map<String, dynamic> stats) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final columns = isMobile ? 1 : (isTablet ? 2 : 4);
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
            // Total Empleados
            SizedBox(
              width: cardWidth,
              child: MetricCard(
                icon: Icons.people,
                label: 'Total Empleados',
                value: stats['totalEmployees'].toString(),
                color: AppColors.primary,
                badgeText: '+12',
                badgeColor: AppColors.success,
              ),
            ),
            // Fichados Hoy
            SizedBox(
              width: cardWidth,
              child: MetricCard(
                icon: Icons.check_circle,
                label: 'Fichados Hoy',
                value: stats['clockedInToday'].toString(),
                color: AppColors.success,
                badgeText: '97%',
              ),
            ),
            // Ausencias
            SizedBox(
              width: cardWidth,
              child: MetricCard(
                icon: Icons.warning_amber,
                label: 'Ausencias',
                value: stats['absencesToday'].toString(),
                color: AppColors.warning,
                badgeText: '-2',
                badgeColor: AppColors.success,
              ),
            ),
            // Solicitudes
            SizedBox(
              width: cardWidth,
              child: MetricCard(
                icon: Icons.assignment,
                label: 'Solicitudes',
                value: stats['pendingRequests'].toString(),
                color: AppColors.info,
                badgeText: '+4',
                badgeColor: AppColors.info,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final isMobileOrTablet = context.isMobileOrTablet;

    if (isMobileOrTablet) {
      // En mobile/tablet: columna vertical
      return Column(
        children: [
          RecentRequestsList(
            requests: MockData.recentRequests,
          ),
          AppSpacing.verticalSpaceXxl,
          ControlAlertsPanel(
            alerts: MockData.controlAlerts,
          ),
        ],
      );
    }

    // En desktop: fila horizontal (60% - 40%)
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 24.0;
        final availableWidth = constraints.maxWidth - gap;
        final requestsWidth = availableWidth * 0.6;
        final alertsWidth = availableWidth * 0.4;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: requestsWidth,
              child: RecentRequestsList(
                requests: MockData.recentRequests,
              ),
            ),
            AppSpacing.horizontalSpaceXxl,
            SizedBox(
              width: alertsWidth,
              child: ControlAlertsPanel(
                alerts: MockData.controlAlerts,
              ),
            ),
          ],
        );
      },
    );
  }
}
