# 🎵 Control Horario - Sistema de Control Horario

Sistema de control horario para escuela de música con ~500 empleados.

## 📋 Información General

- **Cliente**: Escuela de Música
- **Usuarios**: ~500 empleados (docentes y no docentes)
- **Plataforma**: Web (Flutter) + Móvil (futuro)
- **Backend**: Firebase (Auth + Firestore + Hosting)
- **Estado**: FASE 1 - UI/UX Design

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
├── Riverpod (State Management)
└── go_router (Navegación)

Backend:
├── Firebase Auth (Autenticación)
├── Cloud Firestore (Base de datos)
└── Firebase Hosting (Deploy web)

Desarrollo:
├── Cursor IDE
├── Claude AI (Asistente de desarrollo)
└── Git + GitHub
```

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

### ✅ Fase 0: Planificación (COMPLETADO)
- Definición de requisitos
- Diseño de arquitectura
- Configuración de Cursor

### 🔄 Fase 1: UI/UX (EN PROGRESO)
**Sprint 1: Fundamentos** (2-3 días)
- [ ] Sistema de Theme completo
- [ ] Widgets base (botones, inputs, cards)
- [ ] Layout principal

**Sprint 2: Autenticación** (2 días)
- [ ] Pantalla de Login
- [ ] Splash Screen
- [ ] Navegación básica

**Sprint 3: Dashboard Empleado** (3-4 días)
- [ ] Dashboard principal
- [ ] Componentes de fichaje
- [ ] Resumen del día
- [ ] Registros recientes
- [ ] Calendario

**Sprint 4: Otras Pantallas** (2-3 días)
- [ ] Perfil empleado
- [ ] Configuración
- [ ] Panel admin básico

**Sprint 5: Polish** (1-2 días)
- [ ] Animaciones
- [ ] Responsive
- [ ] Testing visual

### 📦 Fase 2: Lógica & Backend (FUTURO)
- Integración con Firebase
- Riverpod providers funcionales
- Autenticación real
- CRUD de fichajes
- Validaciones

### 🚀 Fase 3: Deploy & Testing (FUTURO)
- Testing completo
- Deploy a Firebase Hosting
- Capacitación usuarios
- Soporte post-lanzamiento

### 📱 Fase 4: App Móvil (FUTURO)
- Adaptación UI para móvil
- Build Android/iOS
- Publicación en stores

## 👥 Roles y Permisos

| Rol | Descripción | Permisos |
|-----|-------------|----------|
| **Empleado** | Usuario final | Ver propio registro, fichar |
| **Admin** | Administrador IT | Crear usuarios, corregir fichajes, reportes |
| **RRHH** | Recursos Humanos | Gestión horarios, permisos (Fase 2+) |

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
**Última actualización**: Noviembre 2025
**Estado**: En desarrollo - Fase 1