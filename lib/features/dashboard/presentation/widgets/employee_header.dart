import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/buttons/icon_button_custom.dart';
import '../../../../shared/widgets/badges/work_schedule_status_badge.dart';

/// Header del dashboard de empleado
///
/// Muestra información completa del usuario actual:
/// - Avatar con indicador de estado
/// - Nombre completo
/// - Cargo del empleado
/// - Departamento
/// - ID de empleado
/// - Badge de estado horario (en horario/fuera de horario)
/// - Fecha actual
/// - Botones de notificaciones y configuración
class EmployeeHeader extends StatelessWidget {
  /// Nombre completo del empleado
  final String employeeName;

  /// ID del empleado (ej: EMP-2024-001)
  final String employeeId;

  /// Cargo del empleado (ej: "Desarrolladora Frontend Senior")
  final String? position;

  /// Departamento del empleado (ej: "Tecnología")
  final String? department;

  /// Si el empleado está activo/online
  final bool isActive;

  /// Si está dentro del horario laboral
  final bool isInWorkSchedule;

  /// Fecha actual formateada
  final String currentDate;

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
    this.position,
    this.department,
    this.isActive = true,
    required this.isInWorkSchedule,
    required this.currentDate,
    this.onNotificationsTap,
    this.onSettingsTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;
    final screenWidth = MediaQuery.of(context).size.width;

    // En pantallas muy pequeñas (<360px), ocultar botones para evitar overflow
    final showActionButtons = screenWidth >= 360;
    final isVerySmall = screenWidth < 400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar con indicador de estado
        _buildAvatar(context, isMobile || isTablet),

        SizedBox(width: isMobile ? AppSpacing.sm : AppSpacing.md),

        // Información del empleado (expandible)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nombre
              Text(
                employeeName,
                style: isMobile ? AppTextStyles.h5 : AppTextStyles.h4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              AppSpacing.verticalSpaceXs,

              // Información adicional (cargo, departamento, ID)
              if (!isMobile && !isTablet) _buildDesktopInfo(context),
              if (isMobile || isTablet) _buildMobileInfo(context),

              AppSpacing.verticalSpaceSm,

              // Badge de estado horario + fecha - ENVUELTO EN FLEXIBLE
              Flexible(
                child: WorkScheduleStatusBadge(
                  isInWorkSchedule: isInWorkSchedule,
                  currentDate: currentDate,
                ),
              ),
            ],
          ),
        ),

        // Espaciado solo si hay botones
        if (showActionButtons)
          SizedBox(width: isMobile ? AppSpacing.sm : AppSpacing.md),

        // Botones de acción - solo si hay espacio suficiente (>=360px)
        if (showActionButtons) _buildActionButtons(context, isVerySmall),
      ],
    );
  }

  /// Avatar con indicador de estado (online/offline)
  Widget _buildAvatar(BuildContext context, bool isMobile) {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Stack(
        children: [
          // Avatar principal
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: isMobile ? 28 : 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                size: isMobile ? AppSpacing.iconXl : 28,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),

          // Indicador de estado (círculo azul/verde)
          if (isActive)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: isMobile ? 14 : 16,
                height: isMobile ? 14 : 16,
                decoration: BoxDecoration(
                  color: AppColors.info,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Información en desktop (3 líneas: cargo, departamento, ID)
  Widget _buildDesktopInfo(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        // Cargo
        if (position != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: _buildInfoChip(
              context,
              icon: Icons.work_outline,
              label: position!,
            ),
          ),

        // Departamento
        if (department != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: _buildInfoChip(
              context,
              icon: Icons.person_outline,
              label: department!,
            ),
          ),

        // ID de empleado
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: _buildInfoChip(
            context,
            icon: Icons.badge_outlined,
            label: employeeId,
          ),
        ),
      ],
    );
  }

  /// Información en mobile (solo ID, cargo y departamento reducidos)
  Widget _buildMobileInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ID de empleado - siempre visible
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.badge_outlined,
              size: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                employeeId,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Cargo y departamento SOLO si existe - más compacto
        if (position != null || department != null) ...[
          const SizedBox(height: 2),

          // Mostrar solo uno en mobile para ahorrar espacio
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                position != null ? Icons.work_outline : Icons.person_outline,
                size: 12,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  position ?? department ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Chip de información (icono + texto)
  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color
              ?.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Botones de acción (notificaciones y configuración)
  Widget _buildActionButtons(BuildContext context, bool isCompact) {
    // En mobile muy pequeño, usar IconButtons normales sin padding extra
    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Notificaciones (disabled — no backend yet)
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Notificaciones no disponibles',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),

          // Configuración
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: onSettingsTap,
            tooltip: 'Configuración',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      );
    }

    // Botones normales para pantallas más grandes
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Notificaciones (disabled — no backend yet)
        IconButtonCustom(
          icon: Icons.notifications_outlined,
          variant: IconButtonVariant.tonal,
          iconColor: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withValues(alpha: 0.5),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Próximamente'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Notificaciones no disponibles',
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
    );
  }
}
