# Testing: Corrección Campos Drawer

## ✅ Cambios Implementados

Se han completado exitosamente los siguientes cambios:

### 1. UserModel Actualizado
- ✅ Agregados 3 campos: `nombre`, `apellido1`, `apellido2`
- ✅ Actualizados comentarios de `fechaInicio` y `fechaFin` para aclarar que son ALTAS EN LA APLICACIÓN
- ✅ Actualizado `fromFirestore()` para parsear los 3 campos nuevos

### 2. FirebaseService Actualizado
- ✅ Parámetros `nombre`, `apellido1`, `apellido2` agregados
- ✅ Documentación actualizada con ejemplos claros de `fechaInicio` y `fechaFin`
- ✅ Guardado en Firestore incluye los 7 campos:
  - nombre, apellido1, apellido2 (nuevos)
  - empresa, scheduleId, fechaInicio, fechaFin (ya existían pero no se enviaban)

### 3. UserManagementProvider Actualizado
- ✅ Propagando todos los parámetros al servicio
- ✅ Documentación actualizada

### 4. NewEmployeeDrawer Actualizado
- ✅ Enviando los 7 campos al provider:
  - nombre, apellido1, apellido2
  - empresa, scheduleId, fechaInicio, fechaFin

### 5. Código Freezed Regenerado
- ✅ Build runner ejecutado sin errores
- ✅ Sin errores de linter

---

## 🧪 Instrucciones de Testing Manual

### TEST 1: Crear Empleado con TODOS los campos

**La aplicación ya está corriendo en Chrome.** Sigue estos pasos:

#### Paso 1: Navegar al Drawer
1. Inicia sesión como admin
2. Ve a **"Gestión de Empleados"** (Dashboard Admin)
3. Click en botón **"Nuevo"** (arriba a la derecha)
4. Debe abrirse el drawer desde la derecha

#### Paso 2: Llenar TODOS los campos

```
📋 Información Personal:
- Nombre: María
- Primer Apellido: García
- Segundo Apellido: López
- DNI: 12345678A
- Teléfono: 600123456
- Email: maria.garcia@test.com

🏢 Información Laboral:
- Código empleado: (dejar vacío para auto-generar)
- Empresa: Escuela Música (pre-filled, dejar como está)
- Departamento: Docente
- Cargo: Profesora Piano

⏰ Control Horario:
- Rol: Empleado (seleccionado por defecto)
- Fecha inicio: (hoy, ya seleccionada)
- Fecha fin: (dejar vacío)
- Horario: Jornada Completa 40h
- Horas semanales: 40 (o dejar vacío)
- Estado: Activo (toggle activado)
```

#### Paso 3: Guardar
1. Click en **"Guardar"**
2. Debe aparecer un diálogo con las credenciales:
   - Email: maria.garcia@test.com
   - Password: (8 caracteres generados)
3. Click en **"CERRAR"**
4. El drawer debe cerrarse
5. **IMPORTANTE:** Deberás volver a iniciar sesión como admin (limitación conocida de Sprint 1.3)

---

### TEST 2: Verificar en Firestore Console

#### Paso 1: Abrir Firestore Console
1. Ve a: https://console.firebase.google.com
2. Selecciona tu proyecto: **control-horario-xxxxx**
3. Ve a **Firestore Database** en el menú lateral
4. Click en la colección **`users`**

#### Paso 2: Buscar el empleado creado
1. Busca el documento con email: **maria.garcia@test.com**
2. Click en el documento para ver todos los campos

#### Paso 3: Verificar que TODOS los campos están guardados

**Campos esperados:**

```javascript
✅ userId: (generado automáticamente)
✅ employeeId: "" (vacío, se asignará en DÍA 6)
✅ email: "maria.garcia@test.com"
✅ displayName: "María García López"

// ✅ Los 3 campos nuevos de nombre
✅ nombre: "María"
✅ apellido1: "García"
✅ apellido2: "López"

// ✅ Información personal
✅ dni: "12345678A"
✅ telefono: "600123456"

// ✅ Información laboral
✅ position: "Profesora Piano"
✅ department: "Docente"
✅ empresa: "Escuela Música"

// ✅ Control horario
✅ scheduleId: "template_40h_001"
✅ fechaInicio: (timestamp de hoy)
✅ fechaFin: (no debe existir o ser null)
✅ weeklyHours: 40
✅ role: "employee"
✅ isActive: true
✅ createdAt: (timestamp de hoy)
```

**CRÍTICO:** Verifica que los campos que antes NO se guardaban ahora SÍ existen:
- ✅ `nombre`, `apellido1`, `apellido2`
- ✅ `empresa`
- ✅ `scheduleId`
- ✅ `fechaInicio`

---

### TEST 3: Verificar Compatibilidad hacia Atrás

#### Paso 1: Verificar empleados existentes
1. En Firestore Console, busca estos empleados:
   - **Paulo** (paulo@test.com)
   - **Admin Sistema** (admin@sistema.com)

2. Estos empleados NO tienen los campos nuevos (nombre, apellido1, apellido2, etc.)

#### Paso 2: Verificar que la app NO se rompe
1. Vuelve a la aplicación
2. Inicia sesión como admin
3. Ve a **"Gestión de Empleados"**
4. Verifica que:
   - ✅ La lista de empleados se muestra correctamente
   - ✅ Los empleados antiguos (Paulo, Admin) aparecen en la lista
   - ✅ Sus `displayName` se muestran correctamente
   - ✅ NO hay errores en la consola de Chrome (F12 → Console)

---

## 📝 Reporte de Resultados

Una vez completadas las pruebas, responde:

### ✅ TEST 1: Crear empleado
- [ ] El drawer se abrió correctamente
- [ ] Todos los campos se llenaron sin problemas
- [ ] El diálogo de credenciales apareció
- [ ] El empleado se guardó exitosamente

### ✅ TEST 2: Verificar Firestore
- [ ] El documento se creó en Firestore
- [ ] TODOS los 7 campos faltantes ahora están presentes
- [ ] Los valores son correctos

### ✅ TEST 3: Compatibilidad
- [ ] Los empleados antiguos se muestran correctamente
- [ ] No hay errores en consola
- [ ] La aplicación funciona normalmente

---

## 🐛 Si Encuentras Errores

**Reporta:**
1. ¿En qué paso ocurrió el error?
2. ¿Qué mensaje de error apareció?
3. Screenshot de Firestore Console (si es relevante)
4. Screenshot de la consola de Chrome (F12 → Console)

---

## 🎉 Si Todo Funciona Correctamente

Responde con:
```
✅ TEST 1: Completado
✅ TEST 2: Completado - Todos los campos presentes en Firestore
✅ TEST 3: Completado - Compatibilidad OK
```

Y podré marcar los TODOs de testing como completados.


