import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_dark.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'navigation_items.dart';

/// Extrae las iniciales de un nombre completo.
///
/// Para nombres compuestos usa la primera letra del primer nombre y la
/// primera letra del primer apellido (segunda palabra). Para un solo
/// nombre usa una sola inicial. Si el nombre está vacío, retorna 'U'
/// como fallback (Usuario).
///
/// Ejemplos:
/// - "Juan Pérez" → "JP"
/// - "Juan Pérez López" → "JP"
/// - "María" → "M"
/// - "" → "U"
String initialsFromName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'U';
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

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

    final cs = Theme.of(context).colorScheme;

    return Drawer(
      width: 304,
      backgroundColor: cs.surface,
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.allLg,
          child: Column(
            children: [
              _buildDrawerHeader(context, currentUser),
              AppSpacing.verticalSpaceLg,
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ...navItems.map((item) {
                      return _buildNavItem(
                        context,
                        item,
                        isSelected: currentRoute == item.route,
                      );
                    }),
                    AppSpacing.verticalSpaceSm,
                    _buildAccountItem(
                      context,
                      isSelected: currentRoute == AppRouter.settings ||
                          currentRoute == AppRouter.profile,
                    ),
                  ],
                ),
              ),
              _buildLogoutItem(context, ref),
              AppSpacing.verticalSpaceSm,
              Text(
                'Control Horario v1.0.0',
                style: AppTextStyles.labelSmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el header del drawer con avatar y datos de usuario.
  ///
  /// Usa los datos reales de [currentUser] cuando están disponibles.
  /// Si [currentUser] es null, muestra "Usuario" como fallback.
  Widget _buildDrawerHeader(BuildContext context, UserModel? currentUser) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = currentUser?.fullName ?? 'Usuario';
    final role = currentUser?.position ?? 'Empleado';
    final department = currentUser?.department;
    final email = currentUser?.email;
    final initials = initialsFromName(
      currentUser?.fullName ?? '',
    ); // initialsFromName already handles empty → 'U'

    return Container(
      width: double.infinity,
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        gradient:
            isDark ? AppColorsDark.primaryGradient : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.subtleShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -32,
            top: -32,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.onPrimary.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.onPrimary.withValues(alpha: 0.18),
                    child: Text(
                      initials,
                      style: AppTextStyles.h5.copyWith(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AppSpacing.horizontalSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyles.h5.copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.verticalSpaceXs,
                        Text(
                          role,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: cs.onPrimary.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (department != null || email != null) ...[
                AppSpacing.verticalSpaceMd,
                if (department != null)
                  _buildHeaderMeta(
                    context,
                    icon: Icons.business_outlined,
                    label: department,
                  ),
                if (email != null) ...[
                  AppSpacing.verticalSpaceXs,
                  _buildHeaderMeta(
                    context,
                    icon: Icons.mail_outline,
                    label: email,
                  ),
                ],
              ],
            ],
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
    final cs = Theme.of(context).colorScheme;

    // Si está seleccionado en DARK MODE, usar Container con gradiente cyan
    if (isSelected && isDark) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isSelected ? cs.primary.withValues(alpha: 0.10) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        leading: Icon(
          item.icon,
          color: isSelected
              ? cs.primary
              : (isDark ? AppColorsDark.textPrimary : cs.onSurfaceVariant),
        ),
        title: Text(
          item.label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected
                ? cs.primary
                : (isDark ? AppColorsDark.textPrimary : cs.onSurface),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () {
          context.go(item.route);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildHeaderMeta(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 14, color: cs.onPrimary.withValues(alpha: 0.75)),
        AppSpacing.horizontalSpaceXs,
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.80),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountItem(BuildContext context, {required bool isSelected}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isSelected ? cs.primary.withValues(alpha: 0.10) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        leading: Icon(
          Icons.person_outline,
          color: isSelected ? cs.primary : cs.onSurfaceVariant,
        ),
        title: Text(
          'Mi cuenta',
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? cs.primary : cs.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: () {
          context.go(AppRouter.settings);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.error.withValues(alpha: 0.20)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        leading: Icon(Icons.logout, color: cs.error),
        title: Text(
          'Cerrar sesión',
          style: AppTextStyles.bodyMedium.copyWith(
            color: cs.error,
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: () async {
          await ref.read(authNotifierProvider.notifier).signOut();
          if (context.mounted) {
            context.go(AppRouter.login);
          }
        },
      ),
    );
  }
}
