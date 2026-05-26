import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Gráfico de actividad semanal para dashboard admin
///
/// Muestra un gráfico de área con los fichajes de los últimos 7 días.
/// FASE 1: Visualización mock con datos estáticos.
///
/// Ejemplo:
/// ```dart
/// WeeklyActivityChart(
///   data: {
///     'Lun': 420,
///     'Mar': 450,
///     'Mie': 480,
///     'Jue': 470,
///     'Vie': 490,
///     'Sab': 410,
///     'Dom': 380,
///   },
/// )
/// ```
class WeeklyActivityChart extends StatefulWidget {
  /// Datos de actividad por día
  final Map<String, int> data;

  /// Valor máximo del eje Y
  final int maxValue;

  const WeeklyActivityChart({
    super.key,
    required this.data,
    this.maxValue = 600,
  });

  @override
  State<WeeklyActivityChart> createState() => _WeeklyActivityChartState();
}

class _WeeklyActivityChartState extends State<WeeklyActivityChart> {
  String _selectedPeriod = 'Esta semana';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y selector
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actividad Semanal',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalSpaceXs,
                    Text(
                      'Fichajes registrados los últimos 7 días',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Selector de período
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outline),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  underline: const SizedBox(),
                  isDense: true,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: AppSpacing.iconMd,
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurface,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Esta semana',
                      child: Text('Esta semana'),
                    ),
                    DropdownMenuItem(
                      value: 'Última semana',
                      child: Text('Última semana'),
                    ),
                    DropdownMenuItem(
                      value: 'Últimos 30 días',
                      child: Text('Últimos 30 días'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                      // TODO [FASE-2]: Cargar datos según período
                    }
                  },
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceXxl,

          // Gráfico o placeholder si no hay datos
          if (widget.data.isEmpty)
            SizedBox(
              height: 250,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: cs.outline.withValues(alpha: 0.5),
                    ),
                    AppSpacing.verticalSpaceMd,
                    Text(
                      'Sin datos',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.verticalSpaceXs,
                    Text(
                      'Los datos de actividad estarán disponibles próximamente',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 250,
              child: _ChartPainter(
                data: widget.data,
                maxValue: widget.maxValue,
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget que dibuja el gráfico de área
class _ChartPainter extends StatelessWidget {
  final Map<String, int> data;
  final int maxValue;

  const _ChartPainter({
    required this.data,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final days = data.keys.toList();
    final values = data.values.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final chartHeight = height - 30; // Espacio para etiquetas
        final columnWidth = width / days.length;

        return Column(
          children: [
            // Área del gráfico
            Expanded(
              child: Stack(
                children: [
                  // Líneas horizontales de guía
                  ...List.generate(5, (index) {
                    final y = (chartHeight / 4) * index;
                    final value = maxValue - (maxValue / 4 * index).round();
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: y,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              value.toString(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: cs.outline,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          AppSpacing.horizontalSpaceSm,
                          Expanded(
                            child: Container(
                              height: 1,
                              color: cs.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Barras del gráfico
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(days.length, (index) {
                        final value = values[index];
                        final barHeight = (value / maxValue) * chartHeight;

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: columnWidth * 0.1,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Valor sobre la barra
                                Text(
                                  value.toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                                AppSpacing.verticalSpaceXs,
                                // Barra con gradiente
                                Container(
                                  height: barHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary
                                            .withValues(alpha: 0.6),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Etiquetas de días
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 8),
              child: Row(
                children: days.map((day) {
                  return Expanded(
                    child: Text(
                      day,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
