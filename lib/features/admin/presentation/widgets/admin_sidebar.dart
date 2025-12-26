import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';

/// Sidebar de navegación del panel administrador
///
/// Muestra el logo, menú de navegación y botón de cerrar sesión.
/// Se usa tanto en desktop (fijo) como en mobile (drawer).
///
/// Ejemplo:
/// ```dart
/// AdminSidebar(
///   currentRoute: AppRouter.admin,
/// )
/// ```
class AdminSidebar extends StatelessWidget {
  /// Ruta actual para marcar el item activo
  final String? currentRoute;

  const AdminSidebar({
    super.key,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          // Logo y título
          _buildHeader(context),

          AppSpacing.verticalSpaceXxl,

          // Items de navegación
          Expanded(
            child: ListView(
              padding: AppSpacing.horizontalLg,
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Panel Principal',
                  route: AppRouter.admin,
                  isActive: currentRoute == AppRouter.admin,
                  onTap: () => _navigate(context, AppRouter.admin),
                ),
                AppSpacing.verticalSpaceSm,
                _SidebarItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Gestionar Empleados',
                  route: AppRouter.adminEmployees,
                  isActive: currentRoute == AppRouter.adminEmployees,
                  onTap: () => _navigate(context, AppRouter.adminEmployees),
                ),
                AppSpacing.verticalSpaceSm,
                _SidebarItem(
                  icon: Icons.schedule_outlined,
                  activeIcon: Icons.schedule,
                  label: 'Gestión de Horarios',
                  route: AppRouter.adminSchedules,
                  isActive: currentRoute == AppRouter.adminSchedules,
                  onTap: () => _navigate(context, AppRouter.adminSchedules),
                ),
                AppSpacing.verticalSpaceSm,
                _SidebarItem(
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'Reportes Detallados',
                  route: null, // TODO [FASE-2]: Implementar ruta
                  isActive: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función en desarrollo'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                AppSpacing.verticalSpaceSm,
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Configuración',
                  route: AppRouter.settings,
                  isActive: currentRoute == AppRouter.settings,
                  onTap: () => _navigate(context, AppRouter.settings),
                ),
              ],
            ),
          ),

          // Botón de cerrar sesión
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.allXxl,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Row(
        children: [
          // Ícono de reloj
          Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(
              Icons.access_time,
              size: AppSpacing.iconXl,
              color: AppColors.textOnPrimary,
            ),
          ),
          AppSpacing.horizontalSpaceMd,
          // Título
          Expanded(
            child: Text(
              AppConstants.appName,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            // Cerrar sesión de Firebase
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              context.go(AppRouter.login);
            }
          },
          icon: const Icon(
            Icons.logout,
            size: AppSpacing.iconMd,
          ),
          label: const Text('Cerrar Sesión'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    // Cerrar drawer si está abierto (mobile)
    try {
      if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Ignorar si no hay Scaffold
    }

    // Navegar a la ruta
    context.go(route);
  }
}

/// Item individual del sidebar
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? route;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Container(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: AppSpacing.borderRadiusSm,
            border: isActive
                ? Border(
                    left: BorderSide(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: AppSpacing.iconLg,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
