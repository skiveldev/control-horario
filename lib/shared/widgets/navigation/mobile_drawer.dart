import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'navigation_items.dart';

/// Drawer de navegación para mobile y tablet
///
/// Características:
/// - Slide-in desde la izquierda
/// - Header con avatar y datos de usuario
/// - Lista de items de navegación
/// - Cierre automático al navegar
/// - Backdrop oscuro 50% opacity
/// - Gesture swipe-right para cerrar
///
/// Especificaciones:
/// - Ancho: 280px
/// - Animación: 250ms ease-out (nativa de Flutter)
/// - Se cierra con: tap backdrop, swipe, o al seleccionar item
///
/// Uso:
/// ```dart
/// Scaffold(
///   drawer: MobileDrawer(),
///   body: content,
/// )
/// ```
class MobileDrawer extends ConsumerWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final navItems = NavigationItems.items(
      canSuperviseTeam: currentUser?.canSuperviseTeam ?? false,
    );

    return Drawer(
      width: 280,
      child: Column(
        children: [
          // Header con avatar y datos de usuario
          _buildDrawerHeader(context),

          // Lista de items de navegación
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: navItems.map((item) {
                return _buildNavItem(
                  context,
                  item,
                  isSelected: currentRoute == item.route,
                );
              }).toList(),
            ),
          ),

          // Divider y versión
          const Divider(),
          Padding(
            padding: AppSpacing.allMd,
            child: Text(
              'Control Horario v1.0.0',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el header del drawer con avatar y datos de usuario
  Widget _buildDrawerHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.textOnPrimary.withValues(alpha: 0.2),
            child: Text(
              'MG',
              style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
            ),
          ),

          AppSpacing.verticalSpaceMd,

          // Nombre - Información principal
          Text(
            'María García López', // TODO [FASE-2]: Conectar con user provider
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2, // Permitir 2 líneas para nombres largos
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Construye un item de navegación (con gradiente cyan en dark mode)
  Widget _buildNavItem(
    BuildContext context,
    NavigationItem item, {
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Si está seleccionado en DARK MODE, usar Container con gradiente cyan
    if (isSelected && isDark) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs / 2,
        ),
        decoration: BoxDecoration(
          gradient: AppGradients.cardCyanSubtle, // Gradiente cyan (dark mode)
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppShadows.cardCyanGlow, // Glow cyan
        ),
        child: ListTile(
          leading: Icon(
            item.icon,
            color: AppColorsDark.navItemSelectedIcon,
          ),
          title: Text(
            item.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColorsDark.navItemSelectedIcon,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            context.go(item.route);
            Navigator.pop(context);
          },
        ),
      );
    }

    // Item normal (seleccionado en light mode o no seleccionado)
    return ListTile(
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      leading: Icon(
        item.icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : (isDark
                ? AppColorsDark.textPrimary // Blanco en dark
                : Theme.of(context).colorScheme.onSurface), // Negro en light
      ),
      title: Text(
        item.label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isDark
                  ? AppColorsDark.textPrimary // Blanco en dark
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface), // Negro en light
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        context.go(item.route);
        Navigator.pop(context);
      },
    );
  }
}
