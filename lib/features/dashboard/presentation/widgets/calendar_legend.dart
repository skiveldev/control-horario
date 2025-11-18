import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Leyenda del calendario
/// 
/// Muestra los colores y sus significados para el calendario.
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _buildLegendItem(
          color: AppColors.error,
          label: 'Festivos',
          icon: Icons.event_busy,
        ),
        _buildLegendItem(
          color: const Color(0xFFEC4899), // Rosa
          label: 'Vacaciones',
          icon: Icons.beach_access,
        ),
        _buildLegendItem(
          color: AppColors.secondary,
          label: 'Eventos',
          icon: Icons.event,
        ),
        _buildLegendItem(
          color: AppColors.warning,
          label: 'Ausencias',
          icon: Icons.warning,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(
              color: color,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

