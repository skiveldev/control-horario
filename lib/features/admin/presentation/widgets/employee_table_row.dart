import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../auth/models/user_model.dart';

/// Fila de tabla para empleado
///
/// Muestra información del empleado en formato tabla con columnas:
/// - Avatar + Nombre + Email
/// - Departamento
/// - Empresa
/// - Estado (badge)
/// - Último fichaje
///
/// Incluye hover effect y navegación al detalle.
///
/// Ejemplo:
/// ```dart
/// EmployeeTableRow(
///   employee: userModel,
///   onTap: () => navigateToDetail(),
/// )
/// ```
class EmployeeTableRow extends StatefulWidget {
  /// Modelo del empleado
  final UserModel employee;

  /// Callback al hacer tap en la fila
  final VoidCallback? onTap;

  const EmployeeTableRow({
    super.key,
    required this.employee,
    this.onTap,
  });

  @override
  State<EmployeeTableRow> createState() => _EmployeeTableRowState();
}

class _EmployeeTableRowState extends State<EmployeeTableRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.02)
                : Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // NOMBRE Y PERFIL (40% en desktop, 50% en tablet)
              Expanded(
                flex: isDesktop ? 40 : 50,
                child: _buildNameAndProfile(),
              ),

              // DEPARTAMENTO (20%)
              Expanded(
                flex: 20,
                child: _buildDepartment(),
              ),

              // EMPRESA (15% - solo desktop)
              if (isDesktop)
                Expanded(
                  flex: 15,
                  child: _buildCompany(),
                ),

              // ESTADO (15%)
              Expanded(
                flex: 15,
                child: _buildStatusBadge(),
              ),

              // ÚLTIMO FICHAJE (15%)
              Expanded(
                flex: 15,
                child: _buildLastClockIn(),
              ),

              // Flecha de navegación
              Icon(
                Icons.arrow_forward_ios,
                size: AppSpacing.iconSm,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndProfile() {
    return Row(
      children: [
        // Avatar con iniciales y color variado
        CircleAvatar(
          radius: 20,
          backgroundColor: _getAvatarColor(),
          child: Text(
            _getInitials(widget.employee.displayName),
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        AppSpacing.horizontalSpaceMd,

        // Nombre y email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.employee.displayName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.employee.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDepartment() {
    final department = widget.employee.department ?? 'Sin asignar';

    return Row(
      children: [
        Icon(
          Icons.business,
          size: 14,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            department,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCompany() {
    final company = widget.employee.empresa ?? 'Sin asignar';

    return Row(
      children: [
        Icon(
          Icons.domain,
          size: 14,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            company,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    // Determinar estado y color
    Color color;
    String label;
    IconData? icon;

    if (!widget.employee.isActive) {
      color = Theme.of(context).colorScheme.outline;
      label = 'Inactivo';
      icon = Icons.block;
    } else {
      // Activo: mostrar rol o estado mock
      switch (widget.employee.role) {
        case UserRole.admin:
          color = AppColors.error;
          label = 'Admin';
          icon = Icons.admin_panel_settings;
          break;
        case UserRole.rrhh:
          color = AppColors.warning;
          label = 'RRHH';
          icon = Icons.people;
          break;
        case UserRole.employee:
          color = AppColors.success;
          label = 'Activo';
          icon = Icons.check_circle;
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
        borderRadius: AppSpacing.borderRadiusXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastClockIn() {
    // Placeholder honesto — pendiente integrar con Firestore timeRecords
    return Text(
      '—',
      style: AppTextStyles.bodySmall.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.right,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
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
    // Rotar entre 6 colores del sistema según userId
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
    ];

    final hash = widget.employee.userId.hashCode.abs();
    return colors[hash % colors.length];
  }
}
