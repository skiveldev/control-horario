import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../features/admin/presentation/widgets/admin_sidebar.dart';

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
class AdminLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isMobileOrTablet = context.isMobileOrTablet;

    return Scaffold(
      backgroundColor: AppColors.background,
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
              width: 250,
              height: double.infinity,
              child: AdminSidebar(currentRoute: currentRoute),
            ),

          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Header superior
                _AdminHeader(
                  showMenuButton: isMobileOrTablet,
                  showSearch: showSearch,
                  onSearchChanged: onSearchChanged,
                  title: title,
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

  const _AdminHeader({
    required this.showMenuButton,
    this.showSearch = false,
    this.onSearchChanged,
    this.title,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: AppSpacing.horizontalXxl,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
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
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
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
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
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

          // Notificaciones
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO [FASE-2]: Mostrar panel de notificaciones
                },
                tooltip: 'Notificaciones',
              ),
              // Badge de notificaciones
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.horizontalSpaceSm,

          // Avatar y nombre
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  'AD',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              if (!context.isMobile)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administrador',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Gestión de RRHH',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
