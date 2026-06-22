import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../../shared/widgets/cards/metric_card.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/recent_requests_list.dart';
import '../widgets/control_alerts_panel.dart';
import '../../providers/admin_provider.dart';

/// Panel de administración - Rediseñado
///
/// Vista principal del admin con métricas, gráfico de actividad,
/// solicitudes recientes y alertas de control.
///
/// DÍA 4 - SPRINT 4.2: Conectado con Firestore via employeesCountProvider
/// - Total Empleados: dato real desde Firestore
/// - Otras métricas: placeholder "—" (pendiente de Firestore)
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // DÍA 4 - SPRINT 4.2: Obtener total de empleados desde Firestore
    final employeesCountAsync = ref.watch(employeesCountProvider);

    return AdminLayout(
      currentRoute: AppRouter.admin,
      // showSearch deshabilitado: búsqueda global aún no implementada.
      // Se muestra un aviso no interactivo en el cuerpo del dashboard.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título
          _buildHeader(context),

          // Aviso honesto: búsqueda global en construcción (no interactivo)
          _buildConstructionNotice(context, 'Búsqueda global — Más adelante'),

          AppSpacing.verticalSpaceXxl,

          // Grid de métricas (4 cards)
          employeesCountAsync.when(
            data: (employeesCount) => _buildMetricsGrid(
              context,
              employeesCount: employeesCount,
            ),
            loading: () => _buildMetricsGrid(
              context,
              employeesCount: null, // Mostrar loading
            ),
            error: (err, stack) => Center(
              child: Text(
                'Error al cargar métricas',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
            ),
          ),

          AppSpacing.verticalSpaceXxl,

          // Gráfico de actividad semanal
          // TODO [DÍA-5+]: Conectar con datos reales de fichajes
          const WeeklyActivityChart(
            data: {}, // Sin datos — pendiente de Firestore
          ),

          AppSpacing.verticalSpaceXxl,

          // Fila inferior: Solicitudes y Alertas
          // TODO [DÍA-5+]: Conectar con datos reales
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  /// Aviso no interactivo para features en construcción.
  ///
  /// Muestra un chip sutil indicando que la funcionalidad estará disponible
  /// en el futuro. No tiene interacción táctil ni callbacks.
  Widget _buildConstructionNotice(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(top: AppSpacing.md),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 14,
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context, {
    required int? employeesCount, // null = loading
  }) {
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
            // Total Empleados - DATO REAL desde Firestore
            SizedBox(
              width: cardWidth,
              child: MetricCard(
                icon: Icons.people,
                label: 'Total Empleados',
                value: employeesCount == null
                    ? '...' // Loading
                    : employeesCount.toString(), // Dato real
                color: AppColors.primary,
                badgeText: null, // Sin badge — no hay dato real de cambio
                badgeColor: AppColors.success,
              ),
            ),
            // Fichados Hoy — Pendiente de Firestore
            SizedBox(
              width: cardWidth,
              child: const MetricCard(
                icon: Icons.check_circle,
                label: 'Fichados Hoy',
                value: '—',
                color: AppColors.success,
              ),
            ),
            // Ausencias — Pendiente de Firestore
            SizedBox(
              width: cardWidth,
              child: const MetricCard(
                icon: Icons.warning_amber,
                label: 'Ausencias',
                value: '—',
                color: AppColors.warning,
              ),
            ),
            // Solicitudes — Pendiente de Firestore
            SizedBox(
              width: cardWidth,
              child: const MetricCard(
                icon: Icons.assignment,
                label: 'Solicitudes',
                value: '—',
                color: AppColors.info,
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
      return const Column(
        children: [
          RecentRequestsList(requests: []),
          AppSpacing.verticalSpaceXxl,
          ControlAlertsPanel(alerts: []),
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
              child: const RecentRequestsList(requests: []),
            ),
            AppSpacing.horizontalSpaceXxl,
            SizedBox(
              width: alertsWidth,
              child: const ControlAlertsPanel(alerts: []),
            ),
          ],
        );
      },
    );
  }
}
