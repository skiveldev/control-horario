import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/time_record_model.dart';

/// Selector de tabs para categorías (Trabajo/Pausa)
///
/// Características:
/// - Tabs con iconos grandes
/// - Border grueso en activo
/// - Color de fondo sutil en activo
/// - Transición suave
class CategoryTabSelector extends StatelessWidget {
  final RecordCategory selectedCategory;
  final ValueChanged<RecordCategory> onCategoryChanged;

  const CategoryTabSelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Trabajo',
              icon: Icons.work_outline,
              category: RecordCategory.work,
              color: AppColors.info,
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Pausa',
              icon: Icons.coffee_outlined,
              category: RecordCategory.breakTime,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required RecordCategory category,
    required Color color,
  }) {
    final isSelected = selectedCategory == category;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () => onCategoryChanged(category),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: isSelected ? 2 : 0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppSpacing.iconXl,
                color: isSelected ? color : AppColors.textSecondary,
              ),
              AppSpacing.verticalSpaceXs,
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? color : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
