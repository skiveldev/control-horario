# 🎵 Control Horario - Sistema de Control Horario

Sistema de control horario para escuela de música con ~500 empleados.

## 📋 Información General

- **Cliente**: Escuela de Música
- **Usuarios**: 458 empleados (docentes y no docentes)
- **Plataforma**: Web (Flutter) + Móvil (futuro)
- **Backend**: Firebase (Auth + Firestore + Functions + Storage)
- **Estado**: ✅ FASE 1 Completada | 🚧 FASE 2 Planificada

## 🎯 Objetivos del MVP

### Rol Empleado:
- ✅ Fichaje de entrada/salida/pausa/retorno
- ✅ Ver resumen del día actual
- ✅ Historial de registros recientes
- ✅ Calendario mensual de fichajes
- ✅ Ver perfil personal

### Rol Admin (Básico):
- ✅ Crear/editar usuarios
- ✅ Ver fichajes de empleados
- ✅ Corregir fichajes manualmente
- ✅ Lista de incidencias del día

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
├── Claude AI (Asistente de desarrollo)
├── Firebase Emulator Suite (Testing local)
└── Git + GitHub
```

**⚠️ IMPORTANTE**: 
- **Riverpod** es el ÚNICO state management permitido
- NO usar `setState` para estado de aplicación, `Provider`, `BLoC`, `GetX`, o similares
- `setState` SOLO permitido para UI local que no afecta otros widgets (TextField, hover, etc.)
- Todo el estado de aplicación se gestiona con Riverpod providers

## 🛡️ Sistema de Calidad de Código

Este proyecto cuenta con **3 capas de protección** para garantizar código de alta calidad:

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
│   │   ├── theme/              # Sistema de diseño
│   │   ├── constants/          # Constantes
│   │   └── router/             # Navegación
│   │
│   ├── features/               # Features por módulo
│   │   ├── auth/
│   │   ├── dashboard/
│   │   └── admin/
│   │
│   ├── shared/                 # Componentes compartidos
│   │   ├── widgets/
│   │   └── utils/
│   │
│   └── services/               # Servicios externos (Fase 2)
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

3. **Configurar Firebase** (Fase 2)
```bash
# Seguir instrucciones en docs/firebase-setup.md
```

4. **Ejecutar en modo desarrollo**
```bash
flutter run -d chrome
```

## 📅 Roadmap de Desarrollo

### ✅ Fase 1: UI/UX (COMPLETADO)
- [x] Sistema de Theme completo
- [x] 15+ Widgets reutilizables
- [x] 8 Pantallas implementadas
- [x] Navegación con go_router
- [x] Diseño responsive (mobile/tablet/desktop)
- [x] Estados loading/error/empty
- [x] ~50 archivos creados (~8,000 líneas)

**Ver**: `FASE1_COMPLETADO.md` para detalles completos

---

### 🚧 Fase 2: Backend + Lógica (PLANIFICADO - 6 semanas)
**Objetivo**: Reemplazar datos mock con Firebase funcional

**Sprint 1: MVP - Core Básico** (Semana 1)
- [ ] Configurar Firebase (Auth + Firestore)
- [ ] Login funcional con Firebase Auth
- [ ] Sistema de fichaje básico (Entrada/Salida)
- [ ] Dashboard con datos reales

**Sprint 2: Pausas + Validaciones** (Semana 2)
- [ ] Sistema de 1 pausa por día
- [ ] Máquina de estados (deshabilitar botones)
- [ ] Cálculo de horas trabajadas
- [ ] Validación de salida anticipada

**Sprint 3: Panel Admin** (Semana 3)
- [ ] Lista de 458 empleados
- [ ] Admin puede corregir fichajes
- [ ] Historial de ediciones
- [ ] Panel de anomalías

**Sprint 4: Automatización** (Semana 4)
- [ ] Cierre automático de fichajes (Cloud Function)
- [ ] Detección de horas extras (Cloud Function)
- [ ] Sistema de aprobación (RRHH/Admin)

**Sprint 5: Reportes** (Semana 5)
- [ ] Generación de reportes mensuales
- [ ] Exportación a PDF
- [ ] Archivado automático (>3 meses → Cloud Storage)

**Ver**: `docs/FASE2_PLANIFICACION.md` para especificaciones completas  
**Resumen**: `docs/FASE2_RESUMEN.md` para checklist rápido

---

### 🚀 Fase 3: Deploy & Testing (FUTURO)
- Testing completo (>70% cobertura)
- Deploy a Firebase Hosting
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

**Versión**: 1.0.0
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

**Última actualización**: Noviembre 2025
**Estado**: En desarrollo - Fase 1