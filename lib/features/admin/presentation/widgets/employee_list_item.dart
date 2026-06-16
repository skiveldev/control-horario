import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/models/user_model.dart';

/// Item de empleado en lista (vista mobile).
///
/// Muestra información resumida de un empleado con avatar, nombre, cargo,
/// departamento y badge de estado.
class EmployeeListItem extends StatelessWidget {
  /// Modelo del empleado
  final UserModel employee;

  /// Callback al hacer tap
  final VoidCallback? onTap;

  const EmployeeListItem({super.key, required this.employee, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: cs.outline),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getAvatarColor(),
              child: Text(
                _getInitials(employee.displayName),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre completo
                  Text(
                    employee.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  AppSpacing.verticalSpaceXs,
                  // Cargo
                  Text(
                    employee.position ?? 'Sin cargo',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.verticalSpaceXs,
                  // Departamento
                  Row(
                    children: [
                      Icon(Icons.business, size: 12, color: cs.outline),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          employee.department ?? 'Sin asignar',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: cs.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Estado y flecha
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(cs),
                AppSpacing.verticalSpaceXs,
                Icon(Icons.arrow_forward_ios, size: 16, color: cs.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  Color _getAvatarColor() {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];

    final hash = employee.userId.hashCode.abs();
    return colors[hash % colors.length];
  }

  Widget _buildStatusBadge(ColorScheme cs) {
    Color color;
    String label;

    if (!employee.isActive) {
      color = cs.outline;
      label = 'Inactivo';
    } else {
      switch (employee.role) {
        case UserRole.admin:
          color = AppColors.error;
          label = 'Admin';
          break;
        case UserRole.rrhh:
          color = AppColors.warning;
          label = 'RRHH';
          break;
        case UserRole.employee:
          color = AppColors.success;
          label = 'Activo';
          break;
      }
    }

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
