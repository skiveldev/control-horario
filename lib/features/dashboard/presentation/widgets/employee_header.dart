import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/buttons/icon_button_custom.dart';

/// Header del dashboard de empleado
/// 
/// Muestra información del usuario actual:
/// - Avatar
/// - Nombre completo
/// - ID de empleado
/// - Botones de notificaciones y configuración
class EmployeeHeader extends StatelessWidget {
  /// Nombre completo del empleado
  final String employeeName;
  
  /// ID del empleado (ej: EMP-003)
  final String employeeId;
  
  /// Callback al presionar notificaciones
  final VoidCallback? onNotificationsTap;

  /// Callback al presionar configuración
  final VoidCallback? onSettingsTap;

  /// Callback al presionar el avatar (ir a perfil)
  final VoidCallback? onAvatarTap;

  const EmployeeHeader({
    super.key,
    required this.employeeName,
    required this.employeeId,
    this.onNotificationsTap,
    this.onSettingsTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: context.isMobile
          ? AppSpacing.allLg
          : AppSpacing.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg,
            ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
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
          // Avatar + Info
          Expanded(
            child: Row(
              children: [
                // Avatar clickeable
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: context.isMobile ? 24 : 28,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                              Icons.person,
                              size: context.isMobile
                                  ? AppSpacing.iconLg
                                  : AppSpacing.iconXl,
                              color: AppColors.textOnPrimary,
                            ),
                    ),
                  ),
                ),

                AppSpacing.horizontalSpaceMd,

                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre
                      Text(
                        employeeName,
                        style: context.isMobile
                            ? AppTextStyles.h5
                            : AppTextStyles.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      AppSpacing.verticalSpaceXs,

                      // ID de empleado
                      Text(
                        employeeId,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botones de acción
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Notificaciones (con badge)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButtonCustom(
                    icon: Icons.notifications_outlined,
                    variant: IconButtonVariant.tonal,
                    onPressed: onNotificationsTap,
                    tooltip: 'Notificaciones',
                  ),
                  
                  // Badge de notificaciones sin leer
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: AppColors.textOnDark,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.horizontalSpaceSm,

              // Configuración
              IconButtonCustom(
                icon: Icons.settings_outlined,
                variant: IconButtonVariant.tonal,
                onPressed: onSettingsTap,
                tooltip: 'Configuración',
              ),
            ],
          ),
        ],
      ),
    );
  }

}

