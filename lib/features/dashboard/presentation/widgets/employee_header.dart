import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/buttons/icon_button_custom.dart';

/// Header del dashboard de empleado
/// 
/// Muestra información del usuario actual:
/// - Avatar
/// - Nombre completo
/// - Puesto de trabajo
/// - Badge de estado
/// - Botones de notificaciones y configuración
/// 
/// MOCK DATA: Usa datos de MockData.currentUser
class EmployeeHeader extends StatelessWidget {
  /// Callback al presionar notificaciones
  final VoidCallback? onNotificationsTap;

  /// Callback al presionar configuración
  final VoidCallback? onSettingsTap;

  /// Callback al presionar el avatar (ir a perfil)
  final VoidCallback? onAvatarTap;

  const EmployeeHeader({
    super.key,
    this.onNotificationsTap,
    this.onSettingsTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    // Datos mock del usuario actual
    final user = MockData.currentUser;
    final clockingStatus = MockData.currentClockingStatus;

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
            color: AppColors.shadow.withOpacity(0.05),
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
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: context.isMobile ? 24 : 28,
                      backgroundColor: AppColors.primary,
                      backgroundImage: user['avatarUrl'] != null
                          ? NetworkImage(user['avatarUrl'] as String)
                          : null,
                      child: user['avatarUrl'] == null
                          ? Icon(
                              Icons.person,
                              size: context.isMobile
                                  ? AppSpacing.iconLg
                                  : AppSpacing.iconXl,
                              color: AppColors.textOnPrimary,
                            )
                          : null,
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
                      // Nombre + Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user['name'] as String,
                              style: context.isMobile
                                  ? AppTextStyles.h5
                                  : AppTextStyles.h4,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          AppSpacing.horizontalSpaceSm,
                          
                          // Badge de estado
                          _buildStatusBadge(clockingStatus['status'] as String),
                        ],
                      ),

                      AppSpacing.verticalSpaceXs,

                      // Puesto + ID
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user['position'] as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          if (!context.isMobile) ...[
                            AppSpacing.horizontalSpaceSm,
                            Text(
                              '•',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            AppSpacing.horizontalSpaceSm,
                            Text(
                              user['id'] as String,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
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

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'activo':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'Activo';
        icon = Icons.access_time;
        break;
      case 'en_pausa':
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'En pausa';
        icon = Icons.pause_circle_outline;
        break;
      case 'completo':
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        label = 'Completo';
        icon = Icons.check_circle_outline;
        break;
      case 'sin_fichar':
      default:
        backgroundColor = AppColors.textTertiary.withOpacity(0.1);
        textColor = AppColors.textTertiary;
        label = 'Fuera de horario';
        icon = Icons.access_time_outlined;
        break;
    }

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

