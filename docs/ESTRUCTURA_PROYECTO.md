# 📁 Estructura del Proyecto - Control Horario

**Última Actualización**: Diciembre 9, 2024  
**Incluye**: Sistema Dual Theme + Navegación Responsive

---

## 🗂️ Árbol de Directorios

```
control_horario/
│
├── 📂 lib/
│   ├── main.dart                          # Entry point (init SharedPreferences)
│   ├── app.dart                           # MaterialApp con dual theme ✨ NUEVO
│   │
│   ├── 📂 core/                           # Configuración y utilidades
│   │   ├── 📂 theme/
│   │   │   ├── app_colors.dart           # Paleta light mode
│   │   │   ├── app_colors_dark.dart      # ✨ Paleta dark mode (200+ colores)
│   │   │   ├── app_colors_helper.dart    # ✨ Helper theme-aware
│   │   │   ├── app_gradients.dart        # ✨ Gradientes profesionales
│   │   │   ├── app_shadows.dart          # ✨ Sombras con glow effects
│   │   │   ├── app_text_styles.dart      # Tipografías
│   │   │   ├── app_theme.dart            # ThemeData completo ✨ ACTUALIZADO
│   │   │   └── app_spacing.dart          # Espaciados consistentes
│   │   │
│   │   ├── 📂 constants/
│   │   │   ├── app_constants.dart        # Constantes generales
│   │   │   ├── breakpoints.dart          # Responsive breakpoints
│   │   │   └── mock_schedules.dart       # Mock horarios
│   │   │
│   │   ├── 📂 router/
│   │   │   └── app_router.dart           # go_router config
│   │   │
│   │   └── 📂 providers/                 # ✨ NUEVO
│   │       ├── theme_provider.dart       # Provider de tema
│   │       └── theme_provider.g.dart     # Código generado
│   │
│   ├── 📂 features/                       # Organizado por features
│   │   │
│   │   ├── 📂 auth/
│   │   │   ├── 📂 presentation/
│   │   │   │   └── 📂 screens/
│   │   │   │       ├── login_screen.dart
│   │   │   │       └── splash_screen.dart
│   │   │   ├── 📂 providers/             # ⏳ FASE 2
│   │   │   └── 📂 models/                # ⏳ FASE 2
│   │   │
│   │   ├── 📂 dashboard/
│   │   │   ├── 📂 presentation/
│   │   │   │   ├── 📂 screens/
│   │   │   │   │   ├── dashboard_screen.dart        # ✨ Nav responsive
│   │   │   │   │   ├── calendar_screen.dart
│   │   │   │   │   ├── my_schedule_screen.dart
│   │   │   │   │   ├── profile_screen.dart
│   │   │   │   │   └── settings_screen.dart         # ✨ Toggle tema
│   │   │   │   │
│   │   │   │   └── 📂 widgets/
│   │   │   │       ├── employee_header.dart         # ✨ Dual theme
│   │   │   │       ├── clock_display.dart           # ✨ Dual theme
│   │   │   │       ├── day_summary_card.dart        # ✨ Dual theme
│   │   │   │       ├── time_clock_card.dart         # ✨ Dual theme
│   │   │   │       ├── work_hours_progress.dart     # ✨ Gradiente
│   │   │   │       ├── quick_actions_card.dart      # ✨ Dual theme
│   │   │   │       ├── weekly_summary_card.dart     # ✨ Dual theme
│   │   │   │       ├── monthly_calendar_card.dart   # ✨ Dual theme
│   │   │   │       ├── calendar_grid.dart           # ✨ Dual theme
│   │   │   │       ├── calendar_legend.dart         # ✨ Dual theme
│   │   │   │       ├── recent_records_card.dart     # ✨ Dual theme
│   │   │   │       ├── records_table.dart           # ✨ Dual theme
│   │   │   │       ├── record_status_badge.dart     # ✨ Dual theme
│   │   │   │       ├── clocking_buttons.dart        # ✨ Botones con gradientes
│   │   │   │       ├── time_info_badge.dart         # ✨ Badges con gradientes
│   │   │   │       ├── profile_edit_dialog.dart     # ✨ Dual theme
│   │   │   │       ├── edit_entrance_dialog.dart    # ✨ Dual theme
│   │   │   │       └── early_exit_dialog.dart       # ✨ Dual theme
│   │   │   │
│   │   │   ├── 📂 providers/             # ⏳ FASE 2
│   │   │   └── 📂 models/                # ⏳ FASE 2
│   │   │
│   │   └── 📂 admin/
│   │       ├── 📂 presentation/
│   │       │   ├── 📂 screens/
│   │       │   │   ├── admin_dashboard_screen.dart
│   │       │   │   ├── employee_list_screen.dart
│   │       │   │   ├── employee_detail_screen.dart
│   │       │   │   └── schedule_management_screen.dart
│   │       │   │
│   │       │   └── 📂 widgets/
│   │       │       ├── stat_card.dart
│   │       │       ├── employee_list_item.dart
│   │       │       └── week_schedule_viewer.dart
│   │       │
│   │       ├── 📂 providers/             # ⏳ FASE 2
│   │       └── 📂 models/                # ⏳ FASE 2
│   │
│   ├── 📂 shared/                        # Widgets y utilidades compartidas
│   │   ├── 📂 widgets/
│   │   │   ├── 📂 buttons/
│   │   │   │   └── custom_button.dart             # ✨ Variantes con gradientes
│   │   │   │
│   │   │   ├── 📂 cards/
│   │   │   │   ├── custom_card.dart               # ✨ Dual theme
│   │   │   │   └── schedule_card.dart
│   │   │   │
│   │   │   ├── 📂 inputs/
│   │   │   │   └── custom_text_field.dart
│   │   │   │
│   │   │   ├── 📂 layouts/
│   │   │   │   └── custom_app_bar.dart            # ✨ Leading param
│   │   │   │
│   │   │   └── 📂 navigation/            # ✨ NUEVO COMPLETO
│   │   │       ├── navigation_items.dart          # Lista de items
│   │   │       ├── desktop_sidebar.dart           # Sidebar colapsable
│   │   │       ├── mobile_drawer.dart             # Drawer temporal
│   │   │       └── responsive_navigation.dart     # Wrapper responsive
│   │   │
│   │   └── 📂 utils/
│   │       └── responsive_extensions.dart
│   │
│   └── 📂 services/                      # ⏳ FASE 2
│       ├── 📂 firebase/
│       └── 📂 api/
│
├── 📂 docs/                              # Documentación
│   ├── FASE1_SUMMARY.md                 # Resumen Fase 1
│   ├── BLOQUE_1_IMPLEMENTACION_SUMMARY.md
│   ├── BLOQUE_2_PERFIL_SUMMARY.md
│   ├── MVP_GESTION_HORARIOS.md
│   ├── DUAL_THEME_NAVIGATION_SUMMARY.md # ✨ NUEVO (este documento)
│   ├── PROJECT_STATUS.md                 # ✨ NUEVO (estado actual)
│   ├── ESTRUCTURA_PROYECTO.md           # ✨ NUEVO (este archivo)
│   │
│   └── 📂 archive/                       # Docs antiguos
│       ├── BLOQUE_1_IMPLEMENTACION_SUMMARY.md
│       └── BLOQUE_2_PERFIL_SUMMARY.md
│
├── 📂 .cursor/                           # Configuración Cursor
│   └── 📂 plans/
│       ├── bloque-1-panel.plan.md
│       ├── fase-1-ui-ux-d36c18be.plan.md
│       └── dual_theme_navigation_59ca9b2f.plan.md  # ✨ Plan dual theme
│
├── .cursorrules                          # Reglas del proyecto
├── pubspec.yaml                          # ✨ +shared_preferences
├── README.md
└── analysis_options.yaml
```

---

## 📊 Resumen de Archivos por Tipo

### **Creados en Dual Theme + Nav** ✨

| Categoría | Archivos | Descripción |
|-----------|----------|-------------|
| **Core - Theme** | 4 | `app_colors_dark.dart`, `app_gradients.dart`, `app_shadows.dart`, `app_colors_helper.dart` |
| **Core - Providers** | 2 | `theme_provider.dart`, `theme_provider.g.dart` |
| **Navigation** | 4 | `navigation_items.dart`, `desktop_sidebar.dart`, `mobile_drawer.dart`, `responsive_navigation.dart` |
| **Documentación** | 3 | `DUAL_THEME_NAVIGATION_SUMMARY.md`, `PROJECT_STATUS.md`, `ESTRUCTURA_PROYECTO.md` |
| **Total Nuevos** | **13** | - |

### **Modificados en Dual Theme + Nav** ✨

| Categoría | Archivos | Cambios Principales |
|-----------|----------|---------------------|
| **App Core** | 3 | `main.dart`, `app.dart`, `app_theme.dart` |
| **Dashboard** | 17 | Todos adaptados a dual theme |
| **Shared Widgets** | 3 | `custom_button.dart`, `custom_card.dart`, `custom_app_bar.dart` |
| **Dialogs** | 3 | `profile_edit_dialog.dart`, `edit_entrance_dialog.dart`, `early_exit_dialog.dart` |
| **Config** | 1 | `pubspec.yaml` |
| **Total Modificados** | **27+** | - |

---

## 🎨 Archivos de Sistema de Colores

### **Paletas de Colores**

```
lib/core/theme/
├── app_colors.dart              # Light mode
│   ├── Brand Colors (6)
│   ├── Functional Colors (4)
│   ├── Surfaces (4)
│   ├── Text (3)
│   └── Borders (2)
│
├── app_colors_dark.dart         # ✨ Dark mode
│   ├── Backgrounds (4)
│   ├── Surfaces (5)
│   ├── Sidebar (2)
│   ├── Text Colors (5)
│   ├── Primary Scale 50-900 (10)
│   ├── Secondary Scale 50-900 (10)
│   ├── Accent Scale 50-900 (10)
│   ├── Warning Scale 50-900 (10)
│   ├── Clocking States (4)
│   ├── Avatar Colors (3)
│   ├── Calendar Colors (9)
│   ├── Borders (2)
│   ├── Shadows (2)
│   └── Success/Error/Warning/Info (16)
│   └── Total: 200+ colores
│
└── app_colors_helper.dart       # ✨ Theme-aware
    ├── Constructor with isDark
    ├── Adaptive getters (50+)
    └── Scale getters 50-900 (40)
```

### **Efectos Visuales**

```
lib/core/theme/
├── app_gradients.dart           # ✨ Gradientes
│   ├── Button Gradients (4)
│   │   ├── buttonPrimary        # Verde (Entrada)
│   │   ├── buttonDanger         # Rojo (Salida)
│   │   ├── buttonWarning        # Naranja (Pausa)
│   │   └── buttonInfo           # Azul (Retorno)
│   │
│   ├── Card Gradients (2)
│   │   ├── cardCyanSubtle       # Menú seleccionado
│   │   └── cardOrangeSubtle
│   │
│   └── UI Gradients (2)
│       ├── progressBar          # Barra de progreso
│       └── timeClockCardGradient
│
└── app_shadows.dart             # ✨ Sombras
    ├── Button Glows (4)
    │   ├── buttonPrimaryGlow
    │   ├── buttonDangerGlow
    │   ├── buttonWarningGlow
    │   └── buttonInfoGlow
    │
    ├── Card Shadows (5)
    │   ├── cardCyanGlow
    │   ├── cardOrangeGlow
    │   ├── cardSubtle
    │   ├── cardMedium
    │   └── cardStrong
    │
    └── UI Shadows (2)
        ├── timeClockCardGlow
        └── appBarShadow
```

---

## 🧭 Archivos de Navegación

### **Sistema de Navegación Responsive**

```
lib/shared/widgets/navigation/
├── navigation_items.dart        # ✨ NUEVO
│   ├── class NavigationItem
│   │   ├── label: String
│   │   ├── icon: IconData
│   │   └── route: String
│   │
│   └── class NavigationItems
│       └── static items: List<NavigationItem>
│           ├── Inicio (/dashboard)
│           ├── Calendario (/calendar)
│           ├── Mi Control Horario (/my-schedule)
│           └── Configuración (/settings)
│
├── desktop_sidebar.dart         # ✨ NUEVO
│   ├── class DesktopSidebar (ConsumerWidget)
│   │   ├── _buildHeader()
│   │   └── _buildNavItem()
│   │
│   └── @riverpod SidebarNotifier
│       ├── bool build()
│       ├── void toggle()
│       ├── Future<void> _loadSidebarState()
│       └── Future<void> _saveSidebarState()
│
├── mobile_drawer.dart           # ✨ NUEVO
│   └── class MobileDrawer (StatelessWidget)
│       ├── _buildHeader()
│       └── _buildNavItem()
│
└── responsive_navigation.dart   # ✨ NUEVO
    └── class ResponsiveNavigation
        └── LayoutBuilder
            ├── Desktop (≥1024px): Row[Sidebar + Content]
            └── Mobile/Tablet: Content only
```

---

## 🎛️ Archivos de State Management

### **Riverpod Providers**

```
lib/core/providers/
├── theme_provider.dart          # ✨ NUEVO
│   └── @riverpod ThemeNotifier
│       ├── ThemeMode build()
│       ├── Future<void> toggleTheme()
│       ├── Future<void> setTheme(ThemeMode)
│       ├── Future<void> _loadThemeMode()
│       └── Future<void> _saveThemeMode()
│
└── theme_provider.g.dart        # ✨ Generado automáticamente

lib/shared/widgets/navigation/
└── desktop_sidebar.dart
    └── @riverpod SidebarNotifier
        ├── bool build()
        ├── void toggle()
        ├── void expand()
        ├── void collapse()
        ├── Future<void> _loadSidebarState()
        └── Future<void> _saveSidebarState()
```

---

## 🎨 Widgets Actualizados a Dual Theme

### **Dashboard Widgets** (17 archivos)

| Widget | Ubicación | Cambios |
|--------|-----------|---------|
| `employee_header.dart` | `features/dashboard/presentation/widgets/` | ✅ Theme.of(context) |
| `clock_display.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `day_summary_card.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `time_clock_card.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `work_hours_progress.dart` | `features/dashboard/presentation/widgets/` | ✅ Gradiente condicional |
| `quick_actions_card.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `weekly_summary_card.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `monthly_calendar_card.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `calendar_grid.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `calendar_legend.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `recent_records_card.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `records_table.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `record_status_badge.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `clocking_buttons.dart` | `features/dashboard/presentation/widgets/` | ✅ Variantes con gradientes |
| `time_info_badge.dart` | `features/dashboard/presentation/widgets/` | ✅ Gradientes condicionales |
| `profile_edit_dialog.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `edit_entrance_dialog.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |
| `early_exit_dialog.dart` | `features/dashboard/presentation/widgets/` | ✅ AppColorsHelper |

### **Shared Widgets** (3 archivos)

| Widget | Ubicación | Cambios |
|--------|-----------|---------|
| `custom_button.dart` | `shared/widgets/buttons/` | ✅ ButtonVariant enum ampliado<br>✅ Método genérico gradientes |
| `custom_card.dart` | `shared/widgets/cards/` | ✅ Theme.of(context) |
| `custom_app_bar.dart` | `shared/widgets/layouts/` | ✅ Parámetro leading opcional |

---

## 📋 Archivos de Configuración

### **Dependencias** (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.6.1        # ✅ Ya existía
  riverpod_annotation: ^2.6.1     # ✅ Ya existía
  
  # UI
  google_fonts: ^6.3.2            # ✅ Ya existía
  
  # Router
  go_router: ^12.1.3              # ✅ Ya existía
  
  # Utils
  intl: ^0.19.0                   # ✅ Ya existía
  
  # Persistencia
  shared_preferences: ^2.2.2      # ✨ NUEVO

dev_dependencies:
  flutter_lints: ^5.0.0           # ✅ Ya existía
  riverpod_generator: ^2.6.4      # ✅ Ya existía
  build_runner: ^2.5.4            # ✅ Ya existía
  riverpod_lint: ^2.6.3           # ✅ Ya existía
  custom_lint: ^0.7.5             # ✅ Ya existía
```

---

## 🧪 Comandos Útiles

### **Generar Código Riverpod**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### **Limpiar Cache**
```bash
flutter clean
flutter pub get
```

### **Ejecutar App**
```bash
# Chrome
flutter run -d chrome

# Windows
flutter run -d windows

# Modo verbose
flutter run -d chrome -v
```

### **Analizar Código**
```bash
# Análisis completo
dart analyze

# Análisis fatal
dart analyze --fatal-infos
```

---

## 📊 Estadísticas de Archivos

### **Por Categoría**

| Categoría | Archivos | % del Total |
|-----------|----------|-------------|
| **Features** | 40+ | 40% |
| **Shared Widgets** | 15+ | 15% |
| **Core (Theme)** | 10+ | 10% |
| **Core (Router/Constants)** | 5+ | 5% |
| **Core (Providers)** | 5+ | 5% |
| **Documentación** | 10+ | 10% |
| **Configuración** | 5+ | 5% |
| **Tests** | 10+ | 10% |
| **Total** | **100+** | 100% |

### **Líneas de Código (Estimadas)**

| Tipo | Líneas | % |
|------|--------|---|
| **Dart** | 12,000+ | 80% |
| **Documentación (MD)** | 2,500+ | 17% |
| **YAML/Config** | 500+ | 3% |
| **Total** | **15,000+** | 100% |

---

## 🗂️ Archivos Pendientes (FASE 2)

### **Autenticación**
```
lib/features/auth/
├── providers/
│   ├── auth_provider.dart       # ⏳ AuthNotifier
│   └── auth_state.dart          # ⏳ AuthState (freezed)
└── models/
    └── user.dart                # ⏳ User model (freezed)
```

### **Dashboard Lógica**
```
lib/features/dashboard/
├── providers/
│   ├── clocking_provider.dart   # ⏳ ClockingNotifier
│   ├── records_provider.dart    # ⏳ RecordsNotifier
│   └── calendar_provider.dart   # ⏳ CalendarNotifier
└── models/
    ├── clock_record.dart        # ⏳ ClockRecord model
    └── schedule.dart            # ⏳ Schedule model
```

### **Servicios Firebase**
```
lib/services/
├── firebase/
│   ├── auth_service.dart        # ⏳ Firebase Auth
│   ├── firestore_service.dart   # ⏳ Firestore CRUD
│   └── storage_service.dart     # ⏳ Cloud Storage (opcional)
└── api/
    └── api_service.dart         # ⏳ REST API (si aplica)
```

---

## 🎯 Navegación de Archivos

### **Para Empezar a Codificar**
1. `lib/main.dart` - Entry point
2. `lib/app.dart` - MaterialApp config
3. `.cursorrules` - Reglas del proyecto
4. `lib/core/theme/app_theme.dart` - Sistema de temas

### **Para Agregar Features**
1. Crear carpeta en `lib/features/nombre_feature/`
2. Estructura: `presentation/`, `providers/`, `models/`
3. Seguir patrón de dashboard/admin

### **Para Crear Widgets Compartidos**
1. Ubicación: `lib/shared/widgets/categoria/`
2. Usar `AppColorsHelper.of(context)` para colores
3. Documentar con comentarios
4. Agregar ejemplo de uso

### **Para Actualizar Tema**
1. Light: `lib/core/theme/app_colors.dart`
2. Dark: `lib/core/theme/app_colors_dark.dart`
3. Gradientes: `lib/core/theme/app_gradients.dart`
4. Sombras: `lib/core/theme/app_shadows.dart`

---

## 📖 Documentación Relacionada

### **Resúmenes de Implementación**
- [DUAL_THEME_NAVIGATION_SUMMARY.md](DUAL_THEME_NAVIGATION_SUMMARY.md) - Resumen completo dual theme
- [PROJECT_STATUS.md](PROJECT_STATUS.md) - Estado actual del proyecto
- [FASE1_SUMMARY.md](FASE1_SUMMARY.md) - Resumen Fase 1 completa

### **Reglas y Guías**
- [.cursorrules](../.cursorrules) - Reglas del proyecto
- [README.md](../README.md) - Introducción general

### **Planes Detallados**
- [dual_theme_navigation_59ca9b2f.plan.md](../.cursor/plans/dual_theme_navigation_59ca9b2f.plan.md)

---

**Última Actualización**: Diciembre 9, 2024  
**Versión**: 1.0  
**Estado**: ✅ FASE 1 Completada

*Generado automáticamente por el sistema de documentación del proyecto*

