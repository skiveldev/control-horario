import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

/// AppBar personalizado del Control Horario
/// 
/// Barra superior consistente con el diseño de la app.
/// Incluye soporte para avatar, notificaciones y acciones.
/// 
/// Ejemplo de uso:
/// ```dart
/// Scaffold(
///   appBar: CustomAppBar(
///     title: 'Dashboard',
///     showAvatar: true,
///     onAvatarTap: () {
///       // Ir a perfil
///     },
///     actions: [
///       IconButtonCustom(
///         icon: Icons.notifications,
///         onPressed: () {},
///       ),
///     ],
///   ),
///   body: MyContent(),
/// )
/// 
/// // Con búsqueda
/// CustomAppBar(
///   title: 'Empleados',
///   showSearch: true,
///   onSearchChanged: (query) {
///     print('Búsqueda: $query');
///   },
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título del AppBar
  final String? title;

  /// Widget de título personalizado
  final Widget? titleWidget;

  /// Widget de leading personalizado (izquierda)
  final Widget? leading;

  /// Si se muestra el botón de retroceso automático
  final bool automaticallyImplyLeading;

  /// Acciones (botones a la derecha)
  final List<Widget>? actions;

  /// Si se muestra el avatar del usuario
  final bool showAvatar;

  /// URL de la imagen del avatar
  final String? avatarUrl;

  /// Callback al tocar el avatar
  final VoidCallback? onAvatarTap;

  /// Si se muestra el campo de búsqueda
  final bool showSearch;

  /// Hint text para el campo de búsqueda
  final String? searchHint;

  /// Callback cuando cambia el texto de búsqueda
  final ValueChanged<String>? onSearchChanged;

  /// Color de fondo personalizado
  final Color? backgroundColor;

  /// Elevación personalizada
  final double? elevation;

  /// Si el AppBar es transparente
  final bool transparent;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.showAvatar = false,
    this.avatarUrl,
    this.onAvatarTap,
    this.showSearch = false,
    this.searchHint,
    this.onSearchChanged,
    this.backgroundColor,
    this.elevation,
    this.transparent = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    showSearch ? 120.0 : kToolbarHeight,
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent
          ? Colors.transparent
          : backgroundColor ?? AppColors.surface,
      elevation: transparent ? 0 : (elevation ?? 1),
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: titleWidget ?? (title != null
          ? Text(
              title!,
              style: AppTextStyles.h4,
            )
          : null),
      actions: _buildActions(),
      flexibleSpace: showSearch ? _buildSearchBar() : null,
    );
  }

  List<Widget>? _buildActions() {
    final actionWidgets = <Widget>[];

    // Acciones personalizadas
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    // Avatar
    if (showAvatar) {
      actionWidgets.add(
        Padding(
          padding: AppSpacing.horizontalSm,
          child: GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.textOnPrimary,
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  Widget? _buildSearchBar() {
    if (!showSearch) return null;

    return Container(
      alignment: Alignment.bottomCenter,
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: searchHint ?? 'Buscar...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            borderSide: BorderSide.none,
          ),
          contentPadding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}

