# 📦 Planificación Detallada: BLOQUE 1 - Panel Empleado

**Objetivo Principal:** Refinar la interfaz del empleado para soportar la lógica avanzada de fichajes (pausas, estados, anomalías y alertas) manteniendo la consistencia visual.

---

## 1. 🎨 Actualización de Sistema de Colores (Semántica)

**Archivo:** `lib/core/theme/app_colors.dart`
**Acción:** Implementar getters estáticos para estados de fichaje.

| Estado Lógico | Color Base (`AppColors`) | Uso Visual |
| :--- | :--- | :--- |
| **Completado / OK** | `success` (#10B981) | Badge "Completo", Botón "Entrada" (activo). |
| **En Pausa** | `info` (#3B82F6) | Badge "En Pausa", Botón "Retorno" (activo). |
| **Incompleto / Alerta** | `warning` (#F59E0B) | Badge "Incompleto" (sin salida), Iconos de alerta. |
| **Salida Anticipada** | `error` (#EF4444) | Badge "Salida Anticipada", Botón confirmación salida. |
| **Editado / Manual** | `secondary` (#7C3AED) | Badge "Editado" (lápiz), diferenciador de intervención admin. |
| **Auto-Cierre** | `textSecondary` (#64748B) | Badge "Auto-cerrado" (engranaje), fichajes del sistema. |

---

## 2. 🧩 Nuevos Componentes

### 2.1. `ClockingStatusBadge`
Un "pill" visual para mostrar el estado de un registro en tablas y listados.

*   **Ubicación:** `lib/shared/widgets/cards/clocking_status_badge.dart`
*   **Props:**
    *   `ClockingStatus status` (Enum: complete, incomplete, autoClosed, edited, ongoing)
    *   `bool small` (opcional, default false)
*   **Especificaciones UI:**
    *   **Contenedor:** `Container` con `BoxDecoration`.
    *   **Color de Fondo:** Color base del estado con `.withValues(alpha: 0.1)`.
    *   **Borde:** Color base con `.withValues(alpha: 0.2)`.
    *   **Radio:** `BorderRadius.circular(20)` (forma de píldora).
    *   **Contenido:** Row con Icono (tamaño 14/16) + Gap + Texto (tamaño 12, peso Medium).
    *   **Tooltips:**
        *   AutoClosed: "Cierre automático por sistema"
        *   Edited: "Registro modificado manualmente"
        *   Incomplete: "Fichaje sin cierre registrado"

### 2.2. `EarlyExitDialog`
Modal de advertencia crítica cuando el usuario intenta salir antes de completar su jornada.

*   **Ubicación:** `lib/features/dashboard/presentation/widgets/early_exit_dialog.dart`
*   **Props:**
    *   `Duration remainingTime` (Tiempo faltante calculado)
    *   `VoidCallback onConfirm`
    *   `VoidCallback onCancel`
*   **Especificaciones UI:**
    *   **Icono Header:** `Icons.warning_rounded` tamaño 48, color `AppColors.warning`.
    *   **Título:** "Salida Anticipada" (`HeadlineSmall`).
    *   **Cuerpo:**
        *   "Aún te faltan **[2h 15min]** para completar tu jornada laboral." (Negrita en el tiempo).
        *   "¿Estás seguro de que deseas fichar la salida? Esto generará una incidencia." (`BodyMedium`, color `textSecondary`).
    *   **Botones:**
        *   "Cancelar": `CustomButton(variant: secondary, outline: true)`
        *   "Confirmar Salida": `CustomButton(variant: primary, backgroundColor: AppColors.error)` (Rojo para indicar acción con consecuencias).
    *   **Layout:**
        *   Desktop: `Dialog` estándar, ancho max 400px.
        *   Mobile: `ModalBottomSheet` con bordes redondeados superiores.

---

## 3. 🛠️ Modificaciones a Componentes Existentes

### 3.1. `RecordsTable` (Tabla de Registros)
*   **Archivo:** `lib/features/dashboard/presentation/widgets/records_table.dart`
*   **Cambios:**
    1.  **Columnas:** Agregar columna "Estado" después de "Salida".
    2.  **Celdas:** Renderizar el widget `ClockingStatusBadge` en la nueva columna.
    3.  **Lógica de Visualización (Mock temporal):**
        *   Registro hoy sin salida → Badge `Ongoing` (Azul).
        *   Registro pasado sin salida → Badge `Incomplete` (Naranja).
        *   Registro con flag `isAutoClosed` → Badge `AutoClosed` (Gris).
        *   Registro normal → Badge `Complete` (Verde).

### 3.2. `ClockingButtons` (Botonera Principal)
*   **Archivo:** `lib/features/dashboard/presentation/widgets/clocking_buttons.dart`
*   **Cambios:**
    1.  **Estados Deshabilitados:**
        *   Asegurar `opacity: 0.5` o `0.4` para botones no clicables.
        *   Cursor `SystemMouseCursors.forbidden` o `basic`.
    2.  **Feedback Visual:**
        *   Al estar en estado `WORKING`: Botón "Entrada" deshabilitado, "Pausa" y "Salida" activos (Colores Naranja/Rojo suaves).
        *   Al estar en estado `ON_BREAK`: Solo "Retorno" activo (Azul vibrante).

---

## ✅ Checklist de Ejecución - Bloque 1

1.  [ ] **Core:** Actualizar `AppColors` con la lógica semántica.
2.  [ ] **Shared:** Crear `ClockingStatusBadge`.
3.  [ ] **Feature:** Crear `EarlyExitDialog`.
4.  [ ] **Feature:** Actualizar `RecordsTable` con la nueva columna y badges.
5.  [ ] **Feature:** Refinar estilos de estados en `ClockingButtons`.
6.  [ ] **QA:** Verificar responsive (Mobile/Desktop) y contrastes.

