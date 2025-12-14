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

  /// Lista de todos los items de navegación
  static const List<NavigationItem> items = [
    NavigationItem(
      label: 'Inicio',
      icon: Icons.home_outlined,
      route: AppRouter.dashboard,
    ),
    NavigationItem(
      label: 'Calendario',
      icon: Icons.calendar_today_outlined,
      route: '/calendar', // TODO [FASE-2]: Definir ruta de calendario
    ),
    NavigationItem(
      label: 'Mi Control Horario',
      icon: Icons.access_time_outlined,
      route: AppRouter.myTimeControl,
    ),
    NavigationItem(
      label: 'Configuración',
      icon: Icons.settings_outlined,
      route: AppRouter.settings,
    ),
  ];

  /// Obtiene un item por su ruta
  static NavigationItem? getItemByRoute(String route) {
    try {
      return items.firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }

  /// Verifica si una ruta es un item de navegación
  static bool isNavigationRoute(String route) {
    return items.any((item) => item.route == route);
  }
}
