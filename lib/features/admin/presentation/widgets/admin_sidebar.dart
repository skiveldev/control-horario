import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_provider.dart';

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
class AdminSidebar extends ConsumerWidget {
  /// Ruta actual para marcar el item activo
  final String? currentRoute;

  const AdminSidebar({
    super.key,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
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
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                  label: 'Gestionar Calendarios',
                  route: AppRouter.adminCalendars,
                  isActive: currentRoute == AppRouter.adminCalendars,
                  onTap: () => _navigate(context, AppRouter.adminCalendars),
                ),
                AppSpacing.verticalSpaceSm,
                _SidebarItem(
                  icon: Icons.warning_amber_outlined,
                  activeIcon: Icons.warning_amber,
                  label: 'Anomalías',
                  route: AppRouter.adminAnomalies,
                  isActive: currentRoute == AppRouter.adminAnomalies,
                  onTap: () => _navigate(context, AppRouter.adminAnomalies),
                ),
                AppSpacing.verticalSpaceSm,
                _SidebarItem(
                  icon: Icons.more_time_outlined,
                  activeIcon: Icons.more_time,
                  label: 'Horas Extra',
                  route: AppRouter.adminOvertime,
                  isActive: currentRoute == AppRouter.adminOvertime,
                  onTap: () => _navigate(context, AppRouter.adminOvertime),
                ),
                AppSpacing.verticalSpaceSm,
                _SidebarItem(
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'Reportes',
                  route: AppRouter.adminReports,
                  isActive: currentRoute == AppRouter.adminReports,
                  onTap: () => _navigate(context, AppRouter.adminReports),
                ),
                AppSpacing.verticalSpaceSm,
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Configuración del sistema',
                  route: AppRouter.adminSettings,
                  isActive: currentRoute == AppRouter.adminSettings,
                  onTap: () => _navigate(context, AppRouter.adminSettings),
                ),
                // PR#11: "Mi cuenta" removed from lateral sidebar.
                // Profile access is via header avatar area only.
              ],
            ),
          ),

          // Botón de cerrar sesión
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Ícono de reloj
          Icon(
            Icons.access_time,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          AppSpacing.horizontalSpaceSm,
          // Título
          Expanded(
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 18,
                color: isDark
                    ? AppColorsDark.textPrimary
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).signOut();
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
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
            ),
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
      color: AppColors.transparent,
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
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : AppColors.transparent,
            borderRadius: AppSpacing.borderRadiusSm,
            border: isActive
                ? Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
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
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              AppSpacing.horizontalSpaceMd,
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
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
