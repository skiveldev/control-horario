import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/router/app_router.dart';
import '../../../features/admin/presentation/widgets/admin_sidebar.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../widgets/floating_card.dart';
import '../../widgets/navigation/mobile_drawer.dart'; // initialsFromName

/// Layout base para pantallas de administrador
///
/// Incluye sidebar lateral fijo con navegación y área de contenido principal.
/// El sidebar se convierte en drawer en mobile/tablet.
///
/// Ejemplo:
/// ```dart
/// AdminLayout(
///   currentRoute: '/admin',
///   child: Column(
///     children: [
///       // Contenido del dashboard
///     ],
///   ),
/// )
/// ```
class AdminLayout extends ConsumerWidget {
  /// Contenido principal a mostrar
  final Widget child;

  /// Ruta actual para marcar item activo en sidebar
  final String? currentRoute;

  /// Si se muestra el campo de búsqueda en el header
  final bool showSearch;

  /// Callback cuando cambia el texto de búsqueda
  final ValueChanged<String>? onSearchChanged;

  /// Título opcional para el header
  final String? title;

  const AdminLayout({
    super.key,
    required this.child,
    this.currentRoute,
    this.showSearch = false,
    this.onSearchChanged,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobileOrTablet = context.isMobileOrTablet;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // En mobile/tablet: mostrar drawer
      drawer: isMobileOrTablet
          ? Drawer(
              child: AdminSidebar(currentRoute: currentRoute),
            )
          : null,
      body: Row(
        children: [
          // Sidebar fijo en desktop
          if (!isMobileOrTablet)
            SizedBox(
              width: 270,
              height: double.infinity,
              child: AdminSidebar(currentRoute: currentRoute),
            ),

          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Header superior — floating-card style on desktop
                if (isMobileOrTablet)
                  _AdminHeader(
                    showMenuButton: true,
                    showSearch: showSearch,
                    onSearchChanged: onSearchChanged,
                    title: title,
                    currentUser: currentUser,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxxl, // left — gap from sidebar
                      0, // top — FloatingCard provides its own shadow breathing
                      AppSpacing.xxxl, // right — gap from screen edge
                      0, // bottom — content padding handles the gap
                    ),
                    child: _AdminHeader(
                      showMenuButton: false,
                      showSearch: showSearch,
                      onSearchChanged: onSearchChanged,
                      title: title,
                      currentUser: currentUser,
                    ),
                  ),

                // Contenido scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      context.responsiveValue(
                        mobile: AppSpacing.lg,
                        tablet: AppSpacing.xxl,
                        desktop: AppSpacing.xxxl,
                      ),
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Header superior del layout admin
class _AdminHeader extends StatefulWidget {
  final bool showMenuButton;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  final String? title;
  final UserModel? currentUser;

  const _AdminHeader({
    required this.showMenuButton,
    this.showSearch = false,
    this.onSearchChanged,
    this.title,
    this.currentUser,
  });

  @override
  State<_AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<_AdminHeader> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Header row content — shared between mobile and desktop wrappers.
  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      children: [
        // Botón de menú (solo mobile/tablet)
        if (widget.showMenuButton) ...[
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Menú',
          ),
          AppSpacing.horizontalSpaceMd,
        ],

        // Título (si existe)
        if (widget.title != null) ...[
          Flexible(
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          AppSpacing.horizontalSpaceXxl,
        ],

        // Campo de búsqueda
        if (widget.showSearch)
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar reportes, empleados...',
                  prefixIcon: Icon(
                    Icons.search,
                    size: AppSpacing.iconMd,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusSm,
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: AppSpacing.horizontalMd,
                  isDense: true,
                ),
              ),
            ),
          )
        else
          const Spacer(),

        AppSpacing.horizontalSpaceLg,

        // Notificaciones (disabled — no backend yet)
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).disabledColor,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Próximamente'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Notificaciones no disponibles',
        ),

        AppSpacing.horizontalSpaceSm,

        // Avatar y nombre (clickeable)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              context.push(AppRouter.adminProfile);
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Padding(
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      initialsFromName(
                        widget.currentUser?.fullName ?? '',
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  AppSpacing.horizontalSpaceSm,
                  if (!context.isMobile)
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentUser?.fullName ?? 'Usuario',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.currentUser?.position ??
                                widget.currentUser?.department ??
                                'Admin',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.showMenuButton;
    final cs = Theme.of(context).colorScheme;

    if (isMobile) {
      // Mobile/tablet: full-width header with SafeArea and subtle depth
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: _buildHeaderRow(context),
            ),
          ),
        ),
      );
    }

    // Desktop: floating-card header (matches employee panel FloatingPageHeader)
    return SizedBox(
      height: 64,
      child: FloatingCard(
        child: Padding(
          padding: AppSpacing.horizontalLg,
          child: _buildHeaderRow(context),
        ),
      ),
    );
  }
}
