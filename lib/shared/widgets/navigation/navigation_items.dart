import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';

/// Modelo para items de navegación
///
/// Representa un item del menú lateral o drawer con:
/// - Label: Texto a mostrar
/// - Icon: Ícono Material
/// - Route: Ruta de navegación
class NavigationItem {
  final String label;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Clase estática con todos los items de navegación
///
/// Define los items del menú principal compartidos entre:
/// - Mobile Drawer
/// - Desktop Sidebar
///
/// Ejemplo de uso:
/// ```dart
/// NavigationItems.items.map((item) {
///   return ListTile(
///     leading: Icon(item.icon),
///     title: Text(item.label),
///     onTap: () => context.go(item.route),
///   );
/// }).toList()
/// ```
class NavigationItems {
  // Prevenir instanciación
  NavigationItems._();

  /// Lista de todos los items de navegación para empleado/supervisor.
  static List<NavigationItem> items({required bool canSuperviseTeam}) {
    return [
      const NavigationItem(
        label: 'Inicio',
        icon: Icons.home_outlined,
        route: AppRouter.dashboard,
      ),
      const NavigationItem(
        label: 'Calendario',
        icon: Icons.calendar_today_outlined,
        route: AppRouter.calendar,
      ),
      const NavigationItem(
        label: 'Mi Control Horario',
        icon: Icons.access_time_outlined,
        route: AppRouter.myTimeControl,
      ),
      if (canSuperviseTeam)
        const NavigationItem(
          label: 'Equipo',
          icon: Icons.groups_outlined,
          route: AppRouter.team,
        ),
    ];
  }

  /// Obtiene un item por su ruta
  static NavigationItem? getItemByRoute(
    String route, {
    bool canSuperviseTeam = false,
  }) {
    try {
      return items(canSuperviseTeam: canSuperviseTeam)
          .firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }

  /// Verifica si una ruta es un item de navegación
  static bool isNavigationRoute(
    String route, {
    bool canSuperviseTeam = false,
  }) {
    return items(canSuperviseTeam: canSuperviseTeam)
        .any((item) => item.route == route);
  }
}
