import 'package:flutter/material.dart';
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
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
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: context.isMobile ? 24 : 28,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        size: context.isMobile
                            ? AppSpacing.iconLg
                            : AppSpacing.iconXl,
                        color: Theme.of(context).colorScheme.onPrimary,
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
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
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
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
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
