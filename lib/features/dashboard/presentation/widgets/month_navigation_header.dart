import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';

/// Header de navegación de mes con resumen ejecutivo
///
/// Muestra:
/// - Navegación entre meses (flechas)
/// - Resumen del mes (horas trabajadas, planificadas, diferencia)
/// - Control de mes futuro (deshabilitar flecha →)
class MonthNavigationHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final int totalWorkedMinutes;
  final int totalPlannedMinutes;

  const MonthNavigationHeader({
    super.key,
    required this.selectedMonth,
    this.onPreviousMonth,
    this.onNextMonth,
    this.totalWorkedMinutes = 0,
    this.totalPlannedMinutes = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final monthName = DateFormat('MMMM yyyy', 'es_ES').format(selectedMonth);
    final monthNameCapitalized =
        monthName[0].toUpperCase() + monthName.substring(1);

    return Container(
      padding: EdgeInsets.all(
        isMobile ? AppSpacing.lg : AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y navegación de mes
          Row(
            children: [
              // Título
              Expanded(
                child: Text(
                  'Mi Control Horario',
                  style: isMobile ? AppTextStyles.h4 : AppTextStyles.h3,
                ),
              ),

              AppSpacing.horizontalSpaceLg,

              // Navegación de mes
              _buildMonthNavigation(context, monthNameCapitalized),
            ],
          ),

          AppSpacing.verticalSpaceLg,

          // Resumen del mes
          _buildMonthSummary(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation(BuildContext context, String monthName) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón mes anterior
          IconButton(
            onPressed: onPreviousMonth,
            icon: const Icon(Icons.chevron_left),
            iconSize: AppSpacing.iconLg,
            padding: const EdgeInsets.all(AppSpacing.sm),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: 'Mes anterior',
          ),

          AppSpacing.horizontalSpaceSm,

          // Nombre del mes
          Flexible(
            child: Text(
              monthName,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          AppSpacing.horizontalSpaceSm,

          // Botón mes siguiente
          IconButton(
            onPressed: onNextMonth,
            icon: const Icon(Icons.chevron_right),
            iconSize: AppSpacing.iconLg,
            padding: const EdgeInsets.all(AppSpacing.sm),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: 'Mes siguiente',
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(BuildContext context, bool isMobile) {
    final workedHours = totalWorkedMinutes / 60;
    final plannedHours = totalPlannedMinutes / 60;
    final differenceMinutes = totalWorkedMinutes - totalPlannedMinutes;
    final differenceHours = differenceMinutes / 60;
    final differencePercent = totalPlannedMinutes > 0
        ? (differenceMinutes / totalPlannedMinutes) * 100
        : 0.0;

    // Color según diferencia
    final differenceColor = _getDifferenceColor(differenceMinutes);
    final differenceIcon = _getDifferenceIcon(differenceMinutes);

    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(
                Icons.summarize_outlined,
                size: AppSpacing.iconMd,
                color: AppColors.textSecondary,
              ),
              AppSpacing.horizontalSpaceSm,
              Flexible(
                child: Text(
                  'Resumen del Mes',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceMd,

          // Métricas
          if (isMobile)
            _buildMetricsMobile(
              workedHours,
              plannedHours,
              differenceHours,
              differencePercent,
              differenceColor,
              differenceIcon,
            )
          else
            _buildMetricsDesktop(
              workedHours,
              plannedHours,
              differenceHours,
              differencePercent,
              differenceColor,
              differenceIcon,
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsDesktop(
    double workedHours,
    double plannedHours,
    double differenceHours,
    double differencePercent,
    Color differenceColor,
    IconData differenceIcon,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            label: 'Horas trabajadas',
            value: '${workedHours.toStringAsFixed(1)}h',
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.horizontalSpaceLg,
        Expanded(
          child: _buildMetricItem(
            label: 'Horas planificadas',
            value: '${plannedHours.toStringAsFixed(1)}h',
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.horizontalSpaceLg,
        Expanded(
          child: _buildMetricItem(
            label: 'Diferencia',
            value:
                '${differenceHours >= 0 ? '+' : ''}${differenceHours.toStringAsFixed(1)}h',
            color: differenceColor,
            subtitle:
                '${differencePercent >= 0 ? '+' : ''}${differencePercent.toStringAsFixed(1)}%',
            icon: differenceIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsMobile(
    double workedHours,
    double plannedHours,
    double differenceHours,
    double differencePercent,
    Color differenceColor,
    IconData differenceIcon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                label: 'Horas trabajadas',
                value: '${workedHours.toStringAsFixed(1)}h',
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: _buildMetricItem(
                label: 'Horas planificadas',
                value: '${plannedHours.toStringAsFixed(1)}h',
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMd,
        _buildMetricItem(
          label: 'Diferencia',
          value:
              '${differenceHours >= 0 ? '+' : ''}${differenceHours.toStringAsFixed(1)}h',
          color: differenceColor,
          subtitle:
              '${differencePercent >= 0 ? '+' : ''}${differencePercent.toStringAsFixed(1)}%',
          icon: differenceIcon,
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color color,
    String? subtitle,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.verticalSpaceXs,
        Row(
          children: [
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.h4.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) ...[
              AppSpacing.horizontalSpaceXs,
              Icon(
                icon,
                size: AppSpacing.iconMd,
                color: color,
              ),
            ],
          ],
        ),
        if (subtitle != null) ...[
          AppSpacing.verticalSpaceXs,
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Color _getDifferenceColor(int differenceMinutes) {
    if (differenceMinutes >= 120) return AppColors.success; // +2h o más
    if (differenceMinutes >= -60) return AppColors.textSecondary; // -1h a +2h
    return AppColors.error; // -2h o menos
  }

  IconData _getDifferenceIcon(int differenceMinutes) {
    if (differenceMinutes >= 120) return Icons.check_circle;
    if (differenceMinutes >= -60) return Icons.remove_circle_outline;
    return Icons.error;
  }
}
