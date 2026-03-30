# 📦 Planificación Detallada: BLOQUE 2 - Perfil y Configuración

**Objetivo Principal:** Completar la experiencia de gestión de usuario, permitiendo la edición de datos personales y seguridad (cambio de contraseña) mediante interfaces modales consistentes.

---

## 1. 👤 Pantalla de Perfil (`ProfileScreen`)

**Archivo:** `lib/features/dashboard/presentation/screens/profile_screen.dart`

### 1.1. Ajustes de Contenido (Texto)
*   **Cambio:** Modificar la etiqueta de la sección de información laboral.
*   **Actual:** "Horas diarias"
*   **Nuevo:** **"Horas semanales"** (ej. "40 horas/semana").
    *   *Motivo:* Refleja mejor la realidad contractual en escuelas de música donde los horarios diarios varían.

### 1.2. Integración de Edición
*   **Acción:** El botón flotante (FAB) o botón de acción en la AppBar debe abrir el nuevo `ProfileEditDialog`.

---

## 2. 🧩 Nuevos Componentes (Modales)

### 2.1. `ProfileEditDialog` (Edición de Datos)
Un formulario modal para actualizar información personal permitida.

*   **Ubicación:** `lib/features/dashboard/presentation/widgets/profile_edit_dialog.dart`
*   **Props:**
    *   `UserProfile user` (Datos actuales).
    *   `Function(UserProfile) onSave`.
*   **Especificaciones UI:**
    *   **Header:** Título "Editar Perfil".
    *   **Avatar:**
        *   Mostrar avatar actual grande (80px).
        *   Botón superpuesto de "Cámara/Subir" (Mock UI por ahora).
    *   **Formulario (Campos Editables):**
        *   `CustomTextField` - Nombre Completo.
        *   `CustomTextField` - Teléfono.
        *   `SwitchListTile` - "Recibir notificaciones por email".
    *   **Campos de Solo Lectura (Visualmente distinguidos):**
        *   Email, ID Empleado, Departamento (Fondo grisáceo o texto `textSecondary`).
    *   **Acciones:**
        *   "Cancelar" (Outline).
        *   "Guardar Cambios" (Primary).

### 2.2. `ChangePasswordDialog` (Seguridad)
**Recomendación:** Modal centrado para cambio de contraseña seguro.

*   **Ubicación:** `lib/features/auth/presentation/widgets/change_password_dialog.dart`
*   **Contexto:** Se invoca desde `SettingsScreen` -> Sección "Cuenta".
*   **Especificaciones UI:**
    *   **Header:** Icono `Lock` + Título "Cambiar Contraseña".
    *   **Formulario:**
        1.  **Contraseña Actual:** Input con `obscureText` + toggle visibility.
        2.  **Nueva Contraseña:** Input con `obscureText`.
        3.  **Confirmar Nueva:** Input con `obscureText`.
    *   **Feedback Visual (Validación):**
        *   Indicador de fortaleza de contraseña (barra de color: Rojo/Amarillo/Verde) debajo del campo "Nueva Contraseña".
        *   Mensaje de error si "Confirmar" no coincide en tiempo real.
    *   **Acciones:**
        *   "Cancelar".
        *   "Actualizar Contraseña" (Deshabilitado si no coinciden o requisitos no cumplidos).

---

## 3. ⚙️ Pantalla de Configuración (`SettingsScreen`)

**Archivo:** `lib/features/dashboard/presentation/screens/settings_screen.dart`

### 3.1. Sección "Cuenta"
*   **Mejora:** Agregar opción clara para cambiar contraseña.
*   **Diseño Row:**
    *   Icono: `Icons.lock_outline`.
    *   Texto: "Contraseña y Seguridad".
    *   Subtexto: "Último cambio hace 3 meses" (Mock).
    *   Acción: `ChevronRight` o botón "Cambiar".
    *   **Interacción:** Abre `ChangePasswordDialog`.

---

## ✅ Checklist de Ejecución - Bloque 2

1.  [ ] **Profile Screen:** Renombrar label "Horas diarias" a "Horas semanales".
2.  [ ] **Feature:** Crear `ProfileEditDialog` con validación de campos.
3.  [ ] **Feature:** Crear `ChangePasswordDialog` con lógica visual de validación.
4.  [ ] **Settings:** Integrar botón de cambio de contraseña en la lista de opciones.
5.  [ ] **Navegación:** Conectar los botones "Editar" en Perfil y Configuración para abrir los diálogos.

