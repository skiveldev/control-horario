# Navegación Responsive - Control Horario

Sistema de navegación adaptativo que proporciona una experiencia óptima en todos los dispositivos.

## Componentes

### 1. NavigationItems
**Archivo:** `navigation_items.dart`

Define los items del menú compartidos entre todas las navegaciones.

```dart
NavigationItems.items // Lista de todos los items
NavigationItems.getItemByRoute(String route) // Obtener item por ruta
NavigationItems.isNavigationRoute(String route) // Verificar si es ruta de navegación
```

### 2. MobileDrawer
**Archivo:** `mobile_drawer.dart`

Drawer slide-in para mobile y tablet.

**Características:**
- Ancho: 280px
- Animación nativa de Flutter (250ms ease-out)
- Header con avatar y datos de usuario
- Items de navegación con estado activo
- Cierre automático al navegar
- Backdrop oscuro 50% opacity
- Gesture swipe-right para cerrar

**Uso:**
```dart
Scaffold(
  drawer: MobileDrawer(),
  body: content,
)
```

### 3. DesktopSidebar
**Archivo:** `desktop_sidebar.dart`

Sidebar colapsable para desktop.

**Estados:**
- **Expandido**: 240px ancho, iconos + texto
- **Colapsado**: 64px ancho, solo iconos con tooltip

**Características:**
- Animación suave de 200ms
- Tooltips en modo colapsado
- Item activo destacado visualmente
- Estado persiste entre sesiones
- Provider de estado con Riverpod

**Uso:**
```dart
Row(
  children: [
    DesktopSidebar(),
    Expanded(child: content),
  ],
)
```

**Provider:**
```dart
// Toggle sidebar
ref.read(sidebarNotifierProvider.notifier).toggle()

// Observar estado
final isExpanded = ref.watch(sidebarNotifierProvider)
```

### 4. ResponsiveNavigation
**Archivo:** `responsive_navigation.dart`

Wrapper que decide qué navegación mostrar según el tamaño de pantalla.

**Lógica:**
- **Desktop (>1024px)**: `DesktopSidebar` visible
- **Mobile/Tablet (<1024px)**: Solo contenido, drawer vía `Scaffold.drawer`

**Uso:**
```dart
Scaffold(
  drawer: isMobile ? MobileDrawer() : null,
  body: ResponsiveNavigation(
    child: content,
  ),
)
```

## Arquitectura

```
ResponsiveNavigation
├─ Desktop: [DesktopSidebar] + [Content]
└─ Mobile: [Content] (Drawer via Scaffold)

NavigationItems (compartidos)
├─ MobileDrawer
└─ DesktopSidebar
```

## Breakpoints

Definidos en `lib/core/constants/breakpoints.dart`:

- **Mobile**: < 768px
- **Tablet**: 768px - 1024px
- **Desktop**: > 1024px

## Persistencia

- **Tema**: `isDarkMode` (SharedPreferences)
- **Sidebar**: `sidebarExpanded` (SharedPreferences)

## TODO para Fase 2

- [ ] Conectar header con user provider real
- [ ] Implementar rutas pendientes (/calendar, /my-hours)
- [ ] Agregar badge de notificaciones en drawer
- [ ] Animaciones avanzadas (parallax, hero transitions)

## Testing

Verificar en:
- Mobile (375px)
- Tablet (768px)
- Desktop (1280px, 1920px)

Ambos temas:
- ✅ Claro
- ✅ Oscuro

## Notas Técnicas

- Usar Riverpod code generation para providers
- Persistencia con SharedPreferences
- Animaciones con AnimatedContainer y Duration
- Responsive con LayoutBuilder y extensiones de Breakpoints
- Mantener separación UI/Lógica (providers solo gestionan estado)

