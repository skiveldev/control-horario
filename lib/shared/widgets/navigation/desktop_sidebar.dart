import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/theme/app_spacing.dart';
import 'navigation_items.dart';

part 'desktop_sidebar.g.dart';

/// Provider para gestionar el estado del sidebar (expandido/colapsado)
///
/// Funcionalidades:
/// - Toggle entre expandido y colapsado
/// - Persistencia de estado con SharedPreferences
/// - Carga automática del estado guardado
@riverpod
class SidebarNotifier extends _$SidebarNotifier {
  static const String _sidebarExpandedKey = 'sidebarExpanded';

  @override
  bool build() {
    // Cargar estado guardado de forma asíncrona
    _loadState();

    // Retornar expandido por defecto
    return true;
  }

  /// Carga el estado del sidebar desde SharedPreferences
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isExpanded = prefs.getBool(_sidebarExpandedKey) ?? true;

      // Actualizar estado solo si es diferente
      if (state != isExpanded) {
        state = isExpanded;
      }
    } catch (e) {
      debugPrint('Error al cargar estado del sidebar: $e');
    }
  }

  /// Alterna entre expandido y colapsado
  Future<void> toggle() async {
    try {
      // Cambiar estado inmediatamente
      state = !state;

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sidebarExpandedKey, state);
    } catch (e) {
      debugPrint('Error al cambiar estado del sidebar: $e');

      // Revertir estado en caso de error
      state = !state;
    }
  }
}

/// Sidebar de navegación para desktop usando NavigationRail
///
/// Implementación profesional usando Material Design 3:
/// - NavigationRail es el widget oficial de Flutter para sidebars
/// - Maneja automáticamente animaciones y constraints
/// - Responsive por diseño, sin anchos hardcodeados
/// - Accesibilidad incluida
///
/// Estados:
/// - **Expandido**: Muestra iconos + labels
/// - **Colapsado**: Solo iconos con tooltips
///
/// Uso:
/// ```dart
/// Row(
///   children: [
///     DesktopSidebar(),
///     Expanded(child: content),
///   ],
/// )
/// ```
class DesktopSidebar extends ConsumerWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sidebarNotifierProvider);
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Encontrar el índice seleccionado basado en la ruta actual
    final selectedIndex = _getSelectedIndex(currentRoute);

    // Colores según tema
    final backgroundColor = isDark
        ? AppColorsDark.sidebarBackground
        : Theme.of(context).colorScheme.surface;

    final selectedIconColor = isDark
        ? const Color(0xFF22D3EE) // Cyan brillante en dark
        : Theme.of(context).colorScheme.primary;

    final unselectedIconColor =
        isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurface;

    final selectedLabelColor = isDark
        ? const Color(0xFF22D3EE) // Cyan brillante en dark
        : Theme.of(context).colorScheme.primary;

    final unselectedLabelColor =
        isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: NavigationRail(
        extended: isExpanded,
        backgroundColor: Colors.transparent,
        minWidth: 72,
        minExtendedWidth: 220,
        selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
        labelType: NavigationRailLabelType.none,
        useIndicator: true,
        indicatorColor: isDark
            ? const Color(0xFF22D3EE).withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        selectedIconTheme: IconThemeData(
          color: selectedIconColor,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: unselectedIconColor,
          size: 24,
        ),
        selectedLabelTextStyle: TextStyle(
          color: selectedLabelColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: unselectedLabelColor,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        leading: _buildLeading(context, ref, isExpanded, isDark),
        destinations: _buildDestinations(),
      ),
    );
  }

  /// Construye el widget leading (header con logo)
  ///
  /// Cuando expandido: Logo + texto "Control Horario"
  /// Cuando colapsado: Solo logo centrado
  Widget _buildLeading(
    BuildContext context,
    WidgetRef ref,
    bool isExpanded,
    bool isDark,
  ) {
    // El leading necesita un ancho definido porque NavigationRail
    // no provee constraints de ancho al leading widget
    final leadingWidth = isExpanded ? 196.0 : 48.0;

    return SizedBox(
      width: leadingWidth,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Logo + texto (expandido) o solo logo (colapsado)
            if (isExpanded)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  AppSpacing.horizontalSpaceSm,
                  Flexible(
                    child: Text(
                      'Control Horario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else
              // Solo logo centrado cuando colapsado
              Center(
                child: Icon(
                  Icons.access_time,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),

            AppSpacing.verticalSpaceMd,
            Divider(
              color: Theme.of(context).dividerColor,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye las destinations del NavigationRail
  List<NavigationRailDestination> _buildDestinations() {
    return NavigationItems.items.map((item) {
      return NavigationRailDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.icon),
        label: Text(item.label),
      );
    }).toList();
  }

  /// Obtiene el índice seleccionado basado en la ruta actual
  int _getSelectedIndex(String currentRoute) {
    for (int i = 0; i < NavigationItems.items.length; i++) {
      if (NavigationItems.items[i].route == currentRoute) {
        return i;
      }
    }
    // Si no encuentra la ruta exacta, buscar coincidencia parcial
    for (int i = 0; i < NavigationItems.items.length; i++) {
      if (currentRoute.startsWith(NavigationItems.items[i].route)) {
        return i;
      }
    }
    return 0; // Default al primer item
  }

  /// Navega a la ruta del destination seleccionado
  void _onDestinationSelected(BuildContext context, int index) {
    if (index >= 0 && index < NavigationItems.items.length) {
      context.go(NavigationItems.items[index].route);
    }
  }
}
