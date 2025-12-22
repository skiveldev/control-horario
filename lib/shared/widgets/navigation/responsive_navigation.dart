import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/app_spacing.dart';
import 'desktop_sidebar.dart';

/// Wrapper de navegación responsive
///
/// Decide qué navegación mostrar según el tamaño de pantalla:
/// - **Desktop (>1024px)**: Sidebar fijo + contenido
/// - **Mobile/Tablet (<1024px)**: Solo contenido (drawer via Scaffold)
///
/// El sidebar colapsable solo está visible en desktop.
/// En mobile/tablet, la navegación se maneja con MobileDrawer
/// que se muestra en el Scaffold.drawer.
///
/// Uso:
/// ```dart
/// Scaffold(
///   drawer: isMobile ? MobileDrawer() : null,
///   body: ResponsiveNavigation(
///     child: contentWidget,
///   ),
/// )
/// ```
class ResponsiveNavigation extends StatelessWidget {
  final Widget child;

  const ResponsiveNavigation({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= Breakpoints.desktop;

        if (isDesktop) {
          // Desktop: Mostrar sidebar + contenido + botón flotante
          // Stack permite posicionar el botón sobre la línea divisoria
          return Stack(
            children: [
              // Sidebar + contenido
              Row(
                children: [
                  const DesktopSidebar(),
                  Expanded(child: child),
                ],
              ),
              // Botón flotante sobre el divider
              const _FloatingToggleButton(),
            ],
          );
        } else {
          // Mobile/Tablet: Solo contenido
          // El drawer se maneja en el Scaffold
          return child;
        }
      },
    );
  }
}

/// Botón flotante para expandir/colapsar el sidebar
///
/// Widget interno que se posiciona sobre la línea divisoria vertical
/// entre el sidebar y el contenido principal.
///
/// Características:
/// - Posicionado dinámicamente según el estado del sidebar
/// - Animación suave al moverse
/// - Estilo circular con sombra (Material Design 3)
/// - Solo visible en desktop (≥1024px)
class _FloatingToggleButton extends ConsumerWidget {
  const _FloatingToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sidebarNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Anchos del sidebar según su estado
    // NavigationRail usa minWidth=72 y minExtendedWidth=220
    final sidebarWidth = isExpanded ? 220.0 : 72.0;

    // Posición del botón: centrado en la línea divisoria
    // Se resta 20px para centrar el botón de 40px en el divider de 1px
    final buttonLeft = sidebarWidth - 20.0;

    // Altura del header (padding vertical * 2 + icono + spacing + divider)
    // AppSpacing.md (16) * 2 + 28 (icono) + 16 (spacing) + 1 (divider) ≈ 77px
    const headerHeight = 77.0;

    // Posición vertical: debajo del header
    final buttonTop = headerHeight + AppSpacing.md;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      left: buttonLeft,
      top: buttonTop,
      child: Material(
        elevation: 4,
        shape: const CircleBorder(),
        color: Colors.transparent,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              isExpanded ? Icons.menu_open : Icons.menu,
              size: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () =>
                ref.read(sidebarNotifierProvider.notifier).toggle(),
            tooltip: isExpanded ? 'Colapsar menú' : 'Expandir menú',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ),
      ),
    );
  }
}
