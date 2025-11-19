import 'package:flutter/material.dart';

/// Breakpoints para diseño responsive del Control Horario
/// 
/// Define los puntos de quiebre para adaptar la UI a diferentes tamaños de pantalla.
/// Basado en estándares comunes de diseño web.
/// 
/// Ejemplo:
/// ```dart
/// final isMobile = MediaQuery.of(context).size.width < Breakpoints.tablet;
/// if (isMobile) {
///   return MobileLayout();
/// } else {
///   return DesktopLayout();
/// }
/// ```
class Breakpoints {
  // Prevenir instanciación
  Breakpoints._();

  // ============================================================================
  // BREAKPOINT VALUES (Anchos en pixels)
  // ============================================================================

  /// Mobile pequeño - 0-639px
  /// Uso: Teléfonos en modo portrait
  static const double mobile = 640.0;

  /// Tablet - 640-767px  
  /// Uso: Teléfonos grandes, tablets pequeñas en portrait
  static const double tablet = 768.0;

  /// Desktop - 768-1023px
  /// Uso: Tablets en landscape, pantallas pequeñas
  static const double desktop = 1024.0;

  /// Desktop ancho - 1024-1279px
  /// Uso: Laptops, monitores estándar
  static const double wide = 1280.0;

  /// Ultra ancho - 1280px+
  /// Uso: Monitores grandes, 4K
  static const double ultraWide = 1920.0;

  // ============================================================================
  // DEVICE TYPE CHECKS (Helpers para determinar tipo de dispositivo)
  // ============================================================================

  /// Verifica si el ancho es de dispositivo móvil (< 640px)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Verifica si el ancho es de tablet (640px - 1023px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// Verifica si el ancho es de desktop (>= 1024px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Verifica si el ancho es desktop ancho (>= 1280px)
  static bool isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= wide;
  }

  /// Verifica si el ancho es ultra ancho (>= 1920px)
  static bool isUltraWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= ultraWide;
  }

  /// Verifica si NO es desktop (< 1024px) - Mobile o Tablet
  static bool isMobileOrTablet(BuildContext context) {
    return MediaQuery.of(context).size.width < desktop;
  }

  // ============================================================================
  // RESPONSIVE VALUES (Valores según breakpoint)
  // ============================================================================

  /// Obtiene un valor según el breakpoint actual
  /// 
  /// Ejemplo:
  /// ```dart
  /// final columns = Breakpoints.valueFor(
  ///   context: context,
  ///   mobile: 1,
  ///   tablet: 2,
  ///   desktop: 3,
  /// );
  /// ```
  static T valueFor<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
    T? ultraWide,
  }) {
    final width = MediaQuery.of(context).size.width;

    if (width >= Breakpoints.ultraWide && ultraWide != null) {
      return ultraWide;
    } else if (width >= Breakpoints.wide && wide != null) {
      return wide;
    } else if (width >= Breakpoints.desktop && desktop != null) {
      return desktop;
    } else if (width >= Breakpoints.tablet && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // ============================================================================
  // LAYOUT CONFIGURATIONS (Configuraciones por breakpoint)
  // ============================================================================

  /// Número de columnas según breakpoint
  static int columnsFor(BuildContext context) {
    return valueFor(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
      wide: 4,
    );
  }

  /// Padding horizontal de página según breakpoint
  static double pageHorizontalPadding(BuildContext context) {
    return valueFor(
      context: context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 40.0,
      wide: 64.0,
    );
  }

  /// Ancho máximo del contenido según breakpoint
  static double maxContentWidth(BuildContext context) {
    return valueFor(
      context: context,
      mobile: double.infinity,
      tablet: 720.0,
      desktop: 960.0,
      wide: 1200.0,
      ultraWide: 1440.0,
    );
  }

  /// Gap entre cards/elementos según breakpoint
  static double gridGap(BuildContext context) {
    return valueFor(
      context: context,
      mobile: 12.0,
      tablet: 16.0,
      desktop: 24.0,
      wide: 32.0,
    );
  }

  // ============================================================================
  // WIDGET BUILDERS (Constructores responsivos)
  // ============================================================================

  /// Construye diferentes widgets según el breakpoint
  /// 
  /// Ejemplo:
  /// ```dart
  /// Breakpoints.builder(
  ///   context: context,
  ///   mobile: (context) => MobileView(),
  ///   tablet: (context) => TabletView(),
  ///   desktop: (context) => DesktopView(),
  /// )
  /// ```
  static Widget builder({
    required BuildContext context,
    required Widget Function(BuildContext) mobile,
    Widget Function(BuildContext)? tablet,
    Widget Function(BuildContext)? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop(context);
    } else if (isTablet(context) && tablet != null) {
      return tablet(context);
    } else {
      return mobile(context);
    }
  }
}

/// Extensión de BuildContext para facilitar el uso de breakpoints
extension BreakpointsExtension on BuildContext {
  /// Verifica si es mobile
  bool get isMobile => Breakpoints.isMobile(this);

  /// Verifica si es tablet
  bool get isTablet => Breakpoints.isTablet(this);

  /// Verifica si es desktop
  bool get isDesktop => Breakpoints.isDesktop(this);

  /// Verifica si es desktop ancho
  bool get isWide => Breakpoints.isWide(this);

  /// Verifica si es ultra ancho
  bool get isUltraWide => Breakpoints.isUltraWide(this);

  /// Verifica si es mobile o tablet
  bool get isMobileOrTablet => Breakpoints.isMobileOrTablet(this);

  /// Obtiene el número de columnas según breakpoint
  int get columns => Breakpoints.columnsFor(this);

  /// Obtiene el padding horizontal de página
  double get pageHorizontalPadding => Breakpoints.pageHorizontalPadding(this);

  /// Obtiene el ancho máximo del contenido
  double get maxContentWidth => Breakpoints.maxContentWidth(this);

  /// Obtiene el gap del grid
  double get gridGap => Breakpoints.gridGap(this);

  /// Obtiene un valor según el breakpoint
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
    T? ultraWide,
  }) {
    return Breakpoints.valueFor(
      context: this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      wide: wide,
      ultraWide: ultraWide,
    );
  }
}

/// Enum para tipos de dispositivo
enum DeviceType {
  mobile,
  tablet,
  desktop,
  wide,
  ultraWide,
}

/// Extensión para obtener el tipo de dispositivo actual
extension DeviceTypeExtension on BuildContext {
  DeviceType get deviceType {
    final width = MediaQuery.of(this).size.width;
    
    if (width >= Breakpoints.ultraWide) {
      return DeviceType.ultraWide;
    } else if (width >= Breakpoints.wide) {
      return DeviceType.wide;
    } else if (width >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
}

// ==============================================================================
// LAYOUT PROPORTIONS (Proporciones para Dashboard Layout - Fase 1.5)
// ==============================================================================

/// Proporciones específicas para el layout del dashboard
/// 
/// Define los anchos relativos de cada componente del dashboard según el breakpoint.
/// Usado en dashboard_screen.dart para crear layouts flexibles y balanceados.
/// 
/// Ejemplo:
/// ```dart
/// final clockWidth = totalWidth * LayoutProportions.desktopTimeClockWidth;
/// ```
class LayoutProportions {
  // Prevenir instanciación
  LayoutProportions._();

  // ============================================================================
  // DESKTOP PROPORTIONS (>1024px)
  // ============================================================================
  
  /// Ancho del card de fichaje (Time Clock) en desktop
  /// 60% - Es el componente principal, necesita espacio para reloj y botones
  static const double desktopTimeClockWidth = 0.60;
  
  /// Ancho del card de resumen del día (Summary) en desktop
  /// 25% - Información complementaria, importante pero secundaria
  static const double desktopSummaryWidth = 0.25;
  
  /// Ancho de la tabla de registros recientes en desktop
  /// 100% - Ocupa todo el ancho en su propia fila (Fase 1.5)
  static const double desktopRecordsWidth = 1.0;
  
  /// Ancho del calendario mensual en desktop
  /// 30% - Tamaño compacto pero legible (Fase 1.5.1)
  static const double desktopCalendarWidth = 0.30;
  
  /// Ancho del gráfico de resumen semanal en desktop
  /// 35% - Balanceado para 7 barras verticales (Fase 1.5.1)
  static const double desktopWeeklyWidth = 0.35;
  
  /// Ancho del card de acciones rápidas en desktop
  /// 35% - Integrado en Row 3 para mejor uso del espacio (Fase 1.5.1)
  static const double desktopActionsWidth = 0.35;

  // ============================================================================
  // TABLET PROPORTIONS (768-1024px)
  // ============================================================================
  
  /// Ancho primario en tablet (columna izquierda)
  /// 60% - Para componentes principales (fichaje)
  static const double tabletPrimaryWidth = 0.60;
  
  /// Ancho secundario en tablet (columna derecha)
  /// 40% - Para componentes complementarios (resumen)
  static const double tabletSecondaryWidth = 0.40;

  // ============================================================================
  // GAPS (Espaciado entre elementos)
  // ============================================================================
  
  /// Gap entre elementos en desktop
  /// 24px - Espaciado generoso para pantallas grandes
  static const double desktopGap = 24.0;
  
  /// Gap entre elementos en tablet
  /// 20px - Espaciado moderado
  static const double tabletGap = 20.0;
  
  /// Gap entre elementos en mobile
  /// 16px - Espaciado compacto para aprovechar espacio
  static const double mobileGap = 16.0;

  // ============================================================================
  // HELPERS
  // ============================================================================
  
  /// Obtiene el gap apropiado según el breakpoint
  static double gapFor(BuildContext context) {
    if (context.isDesktop) {
      return desktopGap;
    } else if (context.isTablet) {
      return tabletGap;
    } else {
      return mobileGap;
    }
  }
}

