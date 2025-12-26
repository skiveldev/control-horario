import 'package:flutter/material.dart';
import '../../../core/constants/breakpoints.dart';
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
          // Desktop: Mostrar sidebar + contenido
          return Row(
            children: [
              const DesktopSidebar(),
              Expanded(child: child),
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
