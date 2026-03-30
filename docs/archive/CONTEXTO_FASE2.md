# 📋 Contexto para Nueva Sesión: Inicio Fase 2

**Proyecto: Sistema de Control Horario (Escuela de Música)**  
**Estado:** Fin de FASE 1 (UI/UX) / Inicio de FASE 2 (Lógica & Firebase)  
**Stack:** Flutter Web/Mobile + **Riverpod (State Management único)** + GoRouter + Firebase

**⚠️ CRÍTICO**: TODO el estado se gestiona con **Riverpod**  
(No setState para estado de app, no BLoC, no GetX. setState solo para UI local)

## ✅ 1. Resumen de lo Completado (Fase 1 - UI Only)
Se ha finalizado la implementación visual completa con datos mock.
*   **Estructura Core:**
    *   Arquitectura por features (`auth`, `dashboard`, `admin`).
    *   Sistema de diseño completo: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppTheme`.
    *   Navegación configurada con `go_router`.
*   **Pantallas Implementadas:**
    *   **Auth:** Splash Screen, Login Screen (UI final).
    *   **Empleado:** Dashboard (Fichaje, Resumen, Calendario, Tabla registros), Perfil, Configuración.
    *   **Admin:** Dashboard Admin, Lista de Empleados, Detalle Empleado.
*   **Refactorización de Layout (Fase 1.5):**
    *   Se eliminó el sidebar sticky ("Acciones Rápidas") por problemas de espacio.
    *   **Nuevo Layout Desktop:** Columna única. Fila superior (Reloj + Resumen), Fila media (Tabla Registros), Fila inferior (Calendario + Semanal + Acciones).
    *   **Responsive:** Definidos breakpoints y proporciones exactas en `LayoutProportions` (Desktop, Tablet, Mobile).

## 🛠️ 2. Estado Técnico y Correcciones Recientes
*   **Fixes Críticos:**
    *   **Overflows:** Se corrigieron múltiples errores de `RenderFlex overflowed` envolviendo textos en `Flexible`/`Expanded` dentro de Rows.
    *   **APIs Deprecadas:** Se migró todo el código a Flutter 3.18+:
        *   `.withOpacity()` ➝ `.withValues(alpha:)`
        *   `MaterialStateProperty` ➝ `WidgetStateProperty`
        *   `CardTheme` ➝ `CardThemeData`
    *   **Linter:** Código limpio sin errores de análisis estáticos graves.
*   **Configuración:**
    *   Se añadió `cspell.json` para manejar el diccionario español/técnico.
    *   Se actualizó `.cursorrules` con reglas estrictas de Git workflow.

## 🚧 3. Limitaciones Conocidas
*   **Datos:** Toda la aplicación usa **MOCK DATA** hardcodeada. No hay conexión real a backend.
*   **Lógica:** Los botones de fichaje y formularios solo imprimen en consola o validan visualmente.
*   **Emulador Android:** Configurado y funcional, pero con rendimiento bajo (se recomienda probar UI en Chrome Mobile View para rapidez).

## 📜 4. Reglas de Desarrollo (Estrictas)
1.  **Workflow de Git:**
    *   1. Modificar código -> 2. `flutter run` (Chrome) -> 3. Verificar 0 errores/overflows -> 4. `dart analyze` -> 5. Commit.
    *   *NUNCA hacer commit sin probar primero.*
2.  **UI:**
    *   Siempre usar `Flexible` en textos dentro de `Row`.
    *   No usar colores hardcoded (usar `AppColors`).
    *   Layouts responsivos calculando `(AnchoTotal - Gaps) * Proporción`.

## 🎯 5. Objetivo Inmediato (Fase 2)

### ✅ Planificación Completada
Se ha generado el documento completo de planificación: `.cursor/plans/fase-2-backend-logica.plan.md`

**Incluye**:
- Estructura completa de Firebase (colecciones, documentos, campos)
- Especificaciones detalladas de 5 Sprints
- Reglas de seguridad completas
- Índices compuestos necesarios
- Estrategia de optimización de costos (plan gratuito)
- Checklist completo de implementación
- 35+ archivos nuevos a crear

### 🚀 Próximo Paso
Iniciar **Sprint 1: MVP - Core Básico**:
1.  Configuración de Firebase (Auth, Firestore)
2.  Implementar AuthProvider y ClockingProvider (Riverpod)
3.  Conectar Login con Firebase Auth real
4.  Conectar botones de fichaje con Firestore
5.  Dashboard mostrando registros del mes actual

---

### Archivos Clave para Contexto
*   `lib/core/constants/breakpoints.dart` (Lógica de proporciones responsive)
*   `lib/features/dashboard/presentation/screens/dashboard_screen.dart` (Ejemplo principal de layout complejo)
*   `lib/core/theme/app_theme.dart` (Configuración de tema actual)
*   `.cursorrules` (Reglas de proyecto)

