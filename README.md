# 🎵 Control Horario - Sistema de Control Horario

Sistema de control horario para escuela de música con ~500 empleados.

## 📋 Información General

- **Cliente**: Escuela de Música
- **Usuarios**: 458 empleados (docentes y no docentes)
- **Plataforma**: Web (Flutter) + Móvil (futuro)
- **Backend**: Firebase (Auth + Firestore + Functions + Storage)
- **Estado**: ✅ FASE 1 Completada | ✅ FASE 2 Completada | 🚧 FASE 3 Planificada

## 🎯 Objetivos del MVP

### Rol Empleado:
- ✅ Fichaje de entrada/salida/pausa/retorno
- ✅ Ver resumen del día actual
- ✅ Historial de registros recientes
- ✅ Calendario mensual de fichajes
- ✅ Ver perfil personal

### Rol Admin:
- ✅ Crear/editar usuarios
- ✅ Ver fichajes de empleados
- ✅ Corregir fichajes manualmente
- ✅ Lista de incidencias del día
- ✅ Gestión de calendarios laborales
- ✅ Gestión de plantillas de horarios

## 🏗️ Stack Tecnológico
```
Frontend:
├── Flutter 3.x (Web + Mobile)
├── Riverpod (State Management) ⭐ ÚNICO Y OFICIAL
│   └── Code generation (riverpod_generator + freezed)
├── go_router (Navegación)
└── Material Design 3 (UI)

Backend:
├── Firebase Auth (Autenticación)
├── Cloud Firestore (Base de datos NoSQL)
├── Cloud Functions (Automatización)
├── Cloud Storage (Archivado)
└── Firebase Hosting (Deploy web)

Desarrollo:
├── Cursor IDE
├── Firebase Emulator Suite (Testing local)
└── Git + GitHub
```

**⚠️ IMPORTANTE**: 
- **Riverpod** es el ÚNICO state management permitido
- NO usar `setState` para estado de aplicación, `Provider`, `BLoC`, `GetX`, o similares
- `setState` SOLO permitido para UI local que no afecta otros widgets (TextField, hover, etc.)
- Todo el estado de aplicación se gestiona con Riverpod providers

## 🛡️ Sistema de Calidad de Código

Este proyecto cuenta con **4 capas de protección** para garantizar código de alta calidad:

### 1. Linter Estricto (`analysis_options.yaml`)
- ✅ Detecta errores mientras escribes en tu IDE
- ✅ Previene bugs críticos (`print()`, APIs deprecadas, etc.)
- ✅ Funciona en tiempo real

### 2. Pre-commit Hook (`.githooks/`)
- ✅ Se ejecuta automáticamente antes de cada commit
- ✅ Auto-formatea el código
- ✅ Bloquea commits con errores

**Instalación (una sola vez):**
```bash
git config core.hooksPath .githooks
```

### 3. GitHub Actions (`.github/workflows/`)
- ✅ Se ejecuta en la nube después de cada push
- ✅ Verifica código + construye la app
- ✅ Bloquea merges de Pull Requests con errores

**Ver estado:** [github.com/TU_REPO/actions](https://github.com)

### 4. Revisión Adversarial (Judgment Day)
- ✅ Revisión de código por dos jueces independientes en paralelo
- ✅ Detecta bugs, vulnerabilidades y violaciones de arquitectura
- ✅ Ejecutado sobre todos los módulos del proyecto (4 targets, múltiples rondas)

📖 **Documentación completa:**
- [📋 Guía Rápida](SETUP_COMPLETO.md) - Resumen ejecutivo
- [📚 Documentación Detallada](docs/QUALITY_SETUP.md) - Sistema completo
- [🪝 Pre-commit Hooks](/.githooks/README.md) - Configuración y uso
- [🤖 GitHub Actions](/.github/workflows/README.md) - CI/CD explicado

## 📁 Estructura del Proyecto
```
control_horario/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/                    # Configuración global
│   │   ├── theme/              # Sistema de diseño (AppColors, AppTextStyles)
│   │   ├── constants/          # Constantes
│   │   ├── providers/          # Providers globales (theme, SharedPreferences)
│   │   └── router/             # Navegación (GoRouter + AuthNotifier)
│   │
│   ├── features/               # Features por módulo
│   │   ├── auth/               # Login, modelos de usuario, providers
│   │   ├── dashboard/          # Fichaje, historial, calendario empleado
│   │   └── admin/              # Panel admin, empleados, calendarios, horarios
│   │
│   ├── shared/                 # Componentes compartidos
│   │   ├── widgets/            # 15+ widgets reutilizables
│   │   └── utils/              # Utilidades (password_utils, etc.)
│   │
│   └── services/               # Servicios externos (Fase 3)
│
├── assets/                     # Imágenes, fuentes, etc
├── test/                       # Tests unitarios
└── integration_test/           # Tests de integración
```

## 🎨 Sistema de Diseño

### Paleta de Colores:
- **Primario**: Azul profundo (#1E3A8A) - Confianza
- **Secundario**: Violeta (#7C3AED) - Creatividad
- **Acento**: Coral (#FB923C) - Calidez
- **Vacaciones**: Rosa (#EC4899)
- **Gradiente login**: Cyan → Azul → Violeta

### Tipografía:
- **Fuente**: Inter
- **Pesos**: 400, 500, 600, 700

### Espaciado:
- Sistema basado en múltiplos de 4px
- Scale: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64

## 🚀 Instalación y Setup

### Prerequisitos:
- Flutter SDK 3.19+
- Dart 3.3+
- Git
- Cursor IDE
- Cuenta de Firebase

### Pasos:

1. **Clonar repositorio**
```bash
git clone [url-repo]
cd control_horario
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Firebase**
```bash
# Seguir instrucciones en docs/firebase-setup.md
```

4. **Ejecutar en modo desarrollo**
```bash
flutter run -d chrome
```

## 📅 Roadmap de Desarrollo

### ✅ Fase 1: UI/UX (COMPLETADO)
- [x] Sistema de Theme completo (light + dark)
- [x] 15+ Widgets reutilizables
- [x] 8 Pantallas implementadas
- [x] Navegación con go_router
- [x] Diseño responsive (mobile/tablet/desktop)
- [x] Estados loading/error/empty
- [x] ~50 archivos creados (~8,000 líneas)

**Ver**: `FASE1_COMPLETADO.md` para detalles completos

---

### ✅ Fase 2: Backend + Lógica (COMPLETADO)
**Objetivo**: Reemplazar datos mock con Firebase funcional

**Sprint 1: MVP - Core Básico** ✅
- [x] Configurar Firebase (Auth + Firestore)
- [x] Login funcional con Firebase Auth
- [x] Sistema de fichaje básico (Entrada/Salida)
- [x] Dashboard con datos reales

**Sprint 2: Pausas + Validaciones** ✅
- [x] Sistema de 1 pausa por día
- [x] Máquina de estados (deshabilitar botones según estado)
- [x] Cálculo de horas trabajadas en tiempo real
- [x] Validación de salida anticipada

**Sprint 3: Panel Admin** ✅
- [x] Lista de 458 empleados con búsqueda y filtros
- [x] Admin puede corregir fichajes manualmente
- [x] Gestión de calendarios laborales y festivos
- [x] Gestión de plantillas de horarios

**Sprint 4: Automatización** 🚧
- [ ] Cierre automático de fichajes (Cloud Function — requiere plan Blaze)
- [ ] Detección de horas extras (Cloud Function)
- [ ] Sistema de aprobación (RRHH/Admin)

**Sprint 5: Reportes** 🚧
- [ ] Generación de reportes mensuales
- [ ] Exportación a PDF
- [ ] Archivado automático (>3 meses → Cloud Storage)

**Ver**: `docs/FASE2_PLANIFICACION.md` para especificaciones completas  
**Resumen**: `docs/FASE2_RESUMEN.md` para checklist rápido

---

### 🔍 Revisión de Calidad: Judgment Day (COMPLETADO)

Revisión adversarial completa sobre todos los módulos del proyecto:

| Target | Issues resueltos | Highlights |
|--------|-----------------|------------|
| Core Services + Router | 8 fixes | AdminSessionException, race condition auth guard, streams |
| Models + Serialización | 13 fixes | Null-safe casts, Timestamp serialization, enum helpers |
| Providers / Estado | 12 fixes | Role checks en admin, DI correcto, ClockingState.loading |
| Shared + Auth UI | 30 fixes | mounted checks, Flexible, AppColors, password_utils.dart |
| Dashboard UI | 32 fixes | Text overflow, hex colors, business logic, context shadows |
| Admin UI | 28 fixes | FirebaseAuth directo, tipos dinámicos, AppColors.transparent |

**Nuevas constantes**: `AppColors.vacation`, `AppColors.gradientStart/Mid/End`, `AppColors.transparent`, `AppColorsDark.navItemSelectedIcon`  
**Nuevo archivo**: `lib/shared/utils/password_utils.dart`

---

### 🚀 Fase 3: Deploy & Testing (PLANIFICADO)
- Testing completo (>70% cobertura)
- Deploy a Firebase Hosting
- Cloud Functions en plan Blaze (cierre automático, horas extras)
- Monitoreo y alertas
- Capacitación usuarios

### 📱 Fase 4: Features Avanzadas (FUTURO)
- Geolocalización GPS
- App móvil nativa (Android/iOS)
- Gestión de vacaciones/permisos
- Reconocimiento facial
- Multi-idioma

## 👥 Roles y Permisos

| Rol | Cantidad | Permisos |
|-----|----------|----------|
| **Empleado** | 456 | - Ver sus propios registros<br>- Fichar entrada/pausa/retorno/salida<br>- Editar solo entrada (mismo día) |
| **RRHH** | 1 | - Ver todos los empleados<br>- Generar reportes y exportar PDF<br>- Gestionar horarios<br>- Aprobar horas extras |
| **Admin** | 1 | - Todo lo de RRHH +<br>- Crear/eliminar usuarios<br>- Corregir cualquier fichaje<br>- Configuración del sistema |

## 📝 Convenciones de Código

Ver archivo `.cursorrules` para reglas detalladas.

**Resumen:**
- Archivos: `snake_case.dart`
- Clases: `PascalCase`
- Variables: `camelCase`
- Usar `const` constructors
- Widgets < 300 líneas
- Separar UI de lógica
- Comentar TODOs para fases futuras
- Todo `Text` en `Row`/`Column` debe estar en `Flexible` o `Expanded`
- Colores siempre con `AppColors.*` — nunca `Colors.X` ni hex literales

## 🧪 Testing
```bash
# Tests unitarios
flutter test

# Tests de widgets
flutter test test/widgets/

# Coverage
flutter test --coverage
```

## 📚 Documentación Adicional

- [Guía de Estilo](docs/style-guide.md) (Futuro)
- [API Firebase](docs/firebase-api.md) (Futuro)
- [Manual de Usuario](docs/user-manual.md) (Futuro)

## 🤝 Contribución

Este es un proyecto privado. Solo desarrolladores autorizados.

### Workflow:
1. Crear branch por feature: `feature/nombre-feature`
2. Desarrollar siguiendo `.cursorrules`
3. Pull request a `develop`
4. Code review
5. Merge a `main` cuando esté probado

## 📄 Licencia

Privado - Todos los derechos reservados

## 📞 Contacto

- **Desarrollador Principal**: [Tu nombre]
- **Cliente**: Escuela de Música
- **Soporte**: [email]

---

## 📚 Documentación del Proyecto

### Estado Actual
- **[FASE1_COMPLETADO.md](FASE1_COMPLETADO.md)** - Resumen completo de Fase 1 (UI/UX)
- **[.cursor/plans/fase-2-backend-logica.plan.md](.cursor/plans/fase-2-backend-logica.plan.md)** - 📋 Planificación completa de Fase 2 (50+ páginas)
- **[docs/FASE2_RESUMEN.md](docs/FASE2_RESUMEN.md)** - 🎯 Resumen ejecutivo de Fase 2
- **[docs/CONTEXTO_FASE2.md](docs/CONTEXTO_FASE2.md)** - Contexto para nueva sesión

### Guías de Desarrollo
- **[.cursorrules](.cursorrules)** - Reglas del proyecto y metodología de trabajo
- **[lib/shared/widgets/README.md](lib/shared/widgets/README.md)** - Documentación de componentes

---

**Versión**: 2.0.0  
**Última actualización**: Abril 2026  
**Estado**: Fase 2 completada — Revisión de calidad ejecutada
