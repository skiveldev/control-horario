import 'package:flutter/material.dart';
import '../../../core/constants/breakpoints.dart';

/// Layout responsive que construye diferentes widgets según el tamaño de pantalla
/// 
/// Facilita la creación de interfaces adaptativas sin repetir código.
/// Usa los breakpoints definidos en la app.
/// 
/// Ejemplo de uso:
/// ```dart
/// ResponsiveLayout(
///   mobile: (context) => MobileHomeScreen(),
///   tablet: (context) => TabletHomeScreen(),
///   desktop: (context) => DesktopHomeScreen(),
/// )
/// 
/// // Si tablet no se especifica, usa mobile
/// ResponsiveLayout(
///   mobile: (context) => CompactView(),
///   desktop: (context) => ExpandedView(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  /// Builder para vista mobile (< 640px)
  final Widget Function(BuildContext) mobile;

  /// Builder opcional para vista tablet (640px - 1023px)
  /// Si no se especifica, usa mobile
  final Widget Function(BuildContext)? tablet;

  /// Builder opcional para vista desktop (>= 1024px)
  /// Si no se especifica, usa tablet o mobile
  final Widget Function(BuildContext)? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return Breakpoints.builder(
      context: context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Widget que ayuda a crear layouts con máximo ancho
/// 
/// Centra el contenido y aplica un ancho máximo según el breakpoint.
/// Útil para pantallas muy anchas donde el contenido no debe expandirse infinitamente.
/// 
/// Ejemplo de uso:
/// ```dart
/// MaxWidthContainer(
///   child: ListView(
///     children: [...],
///   ),
/// )
/// 
/// // Con padding personalizado
/// MaxWidthContainer(
///   maxWidth: 1200,
///   padding: EdgeInsets.all(24),
///   child: MyContent(),
/// )
/// ```
class MaxWidthContainer extends StatelessWidget {
  /// Contenido
  final Widget child;

  /// Ancho máximo personalizado
  final double? maxWidth;

  /// Padding horizontal
  final EdgeInsets? padding;

  /// Alineación del contenido
  final AlignmentGeometry alignment;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? context.maxContentWidth;
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: context.pageHorizontalPadding,
    );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: effectiveMaxWidth,
        ),
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}

/// Grid responsivo que ajusta el número de columnas según el breakpoint
/// 
/// Wrapper sobre GridView que maneja automáticamente las columnas
/// según el tamaño de pantalla.
/// 
/// Ejemplo de uso:
/// ```dart
/// ResponsiveGrid(
///   children: [
///     CustomCard(child: Text('Item 1')),
///     CustomCard(child: Text('Item 2')),
///     CustomCard(child: Text('Item 3')),
///   ],
/// )
/// 
/// // Con columnas personalizadas
/// ResponsiveGrid(
///   mobileColumns: 1,
///   tabletColumns: 2,
///   desktopColumns: 4,
///   spacing: 24,
///   children: items,
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  /// Widgets hijos
  final List<Widget> children;

  /// Número de columnas en mobile
  final int mobileColumns;

  /// Número de columnas en tablet
  final int tabletColumns;

  /// Número de columnas en desktop
  final int desktopColumns;

  /// Espaciado entre elementos (gap)
  final double? spacing;

  /// Relación de aspecto de los items
  final double childAspectRatio;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Si el grid debe ser shrinkWrap
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing,
    this.childAspectRatio = 1.0,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.responsiveValue(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    final gap = spacing ?? context.gridGap;

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: gap,
      mainAxisSpacing: gap,
      childAspectRatio: childAspectRatio,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// Wrap responsivo con espaciado consistente
/// 
/// Similar a ResponsiveGrid pero usando Wrap, ideal para elementos
/// de diferentes tamaños.
/// 
/// Ejemplo de uso:
/// ```dart
/// ResponsiveWrap(
///   children: [
///     Chip(label: Text('Tag 1')),
///     Chip(label: Text('Tag 2')),
///     Chip(label: Text('Tag 3')),
///   ],
/// )
/// ```
class ResponsiveWrap extends StatelessWidget {
  /// Widgets hijos
  final List<Widget> children;

  /// Espaciado entre elementos
  final double? spacing;

  /// Espaciado vertical entre líneas
  final double? runSpacing;

  /// Alineación de los elementos
  final WrapAlignment alignment;

  /// Alineación del contenido en el eje cruzado
  final WrapCrossAlignment crossAxisAlignment;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? context.gridGap;

    return Wrap(
      spacing: gap,
      runSpacing: runSpacing ?? gap,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

