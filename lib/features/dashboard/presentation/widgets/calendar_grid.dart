import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Grid del calendario mensual
///
/// Muestra los días del mes actual con indicadores visuales.
class CalendarGrid extends StatelessWidget {
  /// Año a mostrar
  final int year;

  /// Mes a mostrar (1-12)
  final int month;

  /// Día actual (para resaltar)
  final int currentDay;

  /// Mapa de días con estados especiales
  /// Formato: {día: 'tipo'} donde tipo puede ser:
  /// 'festivo', 'vacaciones', 'evento', 'ausencia', 'activo'
  final Map<int, String> specialDays;

  /// Callback al hacer tap en un día
  final void Function(int day)? onDayTap;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    required this.currentDay,
    required this.specialDays,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener primer día del mes y número de días
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weekdayOfFirst = firstDay.weekday; // 1 = Monday, 7 = Sunday

    // Calcular offset (días en blanco antes del primer día)
    final offset = weekdayOfFirst - 1; // Ajustar para empezar en Lunes

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Headers de días de la semana
        _buildWeekdayHeaders(),

        AppSpacing.verticalSpaceSm,

        // Grid de días
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          itemCount: offset + daysInMonth,
          itemBuilder: (context, index) {
            // Celdas vacías antes del primer día
            if (index < offset) {
              return const SizedBox();
            }

            final day = index - offset + 1;
            return _buildDayCell(day);
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Builder(
            builder: (context) {
              final colors = AppColorsHelper.of(context);
              return Center(
                child: Text(
                  day,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell(int day) {
    return Builder(
      builder: (context) {
        final colors = AppColorsHelper.of(context);
        final isCurrentDay = day == currentDay;
        final specialType = specialDays[day];
        final hasSpecialType = specialType != null;

        Color? backgroundColor;
        Color? borderColor;
        Color textColor = colors.textPrimary;

        // Determinar colores según tipo
        if (isCurrentDay) {
          backgroundColor = colors.primary;
          textColor = colors.textOnPrimary;
        } else if (hasSpecialType) {
          final typeColor = _getColorForType(context, specialType);
          backgroundColor = typeColor.withValues(alpha: 0.2);
          borderColor = typeColor;
          textColor = typeColor;
        }

        return InkWell(
          onTap: onDayTap != null ? () => onDayTap!(day) : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: isCurrentDay ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorForType(BuildContext context, String type) {
    final colors = AppColorsHelper.of(context);
    switch (type) {
      case 'festivo':
        return colors.error;
      case 'vacaciones':
        return AppColors.vacation;
      case 'evento':
        return colors.secondary;
      case 'ausencia':
        return colors.warning;
      case 'activo':
        return colors.success;
      default:
        return colors.textSecondary;
    }
  }
}
