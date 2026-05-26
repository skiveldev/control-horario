import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'navigation_items.dart';

part 'desktop_sidebar.g.dart';

/// Provider para gestionar el estado del sidebar (expandido/colapsado)
///
/// Funcionalidades:
/// - Toggle entre expandido (240px) y colapsado (64px)
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

/// Sidebar de navegación para desktop
///
/// Características:
/// - Colapsable: expandido (240px) o mini (64px)
/// - Animación suave de 200ms
/// - Tooltips en modo colapsado
/// - Item activo destacado visualmente
/// - Estado persiste entre sesiones
///
/// Estados:
/// - **Expandido**: 240px ancho, iconos + texto
/// - **Colapsado**: 64px ancho, solo iconos con tooltip
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
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final navItems = NavigationItems.items(
      canSuperviseTeam: currentUser?.canSuperviseTeam ?? false,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isExpanded ? 240 : 64,
      decoration: BoxDecoration(
        color: isDark
            ? AppColorsDark.sidebarBackground // Navy oscuro
            : Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header con botón de colapso
          _buildHeader(context, ref, isExpanded),

          // Items de navegación
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: navItems.map((item) {
                return _buildNavItem(
                  context,
                  item,
                  isExpanded,
                  isSelected: currentRoute == item.route,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el header con logo y botón de colapso
  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isExpanded) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? AppSpacing.md : 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isExpanded) ...[
            // Logo/Icono
            Icon(
              Icons.access_time,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),

            AppSpacing.horizontalSpaceSm,

            // Título
            Expanded(
              child: Text(
                'Control Horario',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Botón de colapso
            IconButton(
              icon: Icon(
                Icons.menu_open,
                size: 20,
                color: isDark
                    ? AppColorsDark.textPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () =>
                  ref.read(sidebarNotifierProvider.notifier).toggle(),
              tooltip: 'Colapsar menú',
            ),
          ] else ...[
            // Solo botón de hamburguesa cuando está colapsado
            IconButton(
              icon: Icon(
                Icons.menu,
                size: 24,
                color: isDark
                    ? AppColorsDark.textPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () =>
                  ref.read(sidebarNotifierProvider.notifier).toggle(),
              tooltip: 'Expandir menú',
            ),
          ],
        ],
      ),
    );
  }

  /// Construye un item de navegación
  Widget _buildNavItem(
    BuildContext context,
    NavigationItem item,
    bool isExpanded, {
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final widget = Container(
      height: 56,
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        // Gradiente cyan SOLO en dark mode, color sólido en light mode
        gradient: isSelected && isDark ? AppGradients.cardCyanSubtle : null,
        color: isSelected && !isDark
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : null,
        borderRadius: BorderRadius.circular(8),
        // Glow cyan sutil SOLO en dark mode
        boxShadow: isSelected && isDark ? AppShadows.cardCyanGlow : null,
      ),
      child: InkWell(
        key: ValueKey('desktop-nav-${item.route}'),
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded
                ? AppSpacing.md
                : 0, // Sin padding cuando está colapsado
          ),
          child: Row(
            mainAxisAlignment:
                isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              // Icono
              Icon(
                item.icon,
                size: 24,
                color: isSelected
                    ? (isDark
                        ? AppColorsDark.navItemSelectedIcon
                        : Theme.of(context).colorScheme.primary)
                    : (isDark
                        ? AppColorsDark.textPrimary
                        : Theme.of(context).colorScheme.onSurface),
              ),

              // Texto (solo si está expandido)
              if (isExpanded) ...[
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected
                          ? (isDark
                              ? AppColorsDark.navItemSelectedIcon
                              : Theme.of(context).colorScheme.primary)
                          : (isDark
                              ? AppColorsDark.textPrimary
                              : Theme.of(context).colorScheme.onSurface),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Tooltip cuando está colapsado
    return isExpanded ? widget : Tooltip(message: item.label, child: widget);
  }
}
