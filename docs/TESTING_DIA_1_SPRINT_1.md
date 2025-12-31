# Testing Integrado - Día 1 (Sprint 1.1 - 1.5)

**Fecha:** 31 Diciembre 2025  
**Estado:** ✅ Implementación completada - Listo para testing

---

## 📋 Resumen de Implementación

### ✅ Completado:

1. **Sprint 1.1:** FirebaseService con `createEmployee()` ✅
   - Método para crear usuario en Auth + Firestore
   - Generación automática de employeeId (EMP-XXX)
   - Generación automática de displayName
   - Contraseña temporal aleatoria

2. **Sprint 1.2:** UserManagementProvider con Riverpod ✅
   - Provider para gestión de estado de creación
   - Validaciones integradas
   - Manejo de errores

3. **Sprint 1.3:** NewEmployeeDrawer conectado con Firebase ✅
   - Formulario solo requiere 3 campos obligatorios: Nombre, Apellido1, Email
   - Campos opcionales: Apellido2, DNI, Teléfono, Cargo, Departamento
   - Auto-generación de employeeId si se deja vacío
   - Auto-generación de displayName
   - Valor por defecto weeklyHours = 40.0
   - Diálogo de éxito con credenciales temporales

4. **Sprint 1.4:** Firestore Rules actualizadas ✅
   - Admin y RRHH pueden crear usuarios
   - Admin y RRHH pueden leer todos los usuarios
   - Admin y RRHH pueden actualizar usuarios

---

## 🧪 Checklist de Testing

### Prerequisitos:
- [ ] Firebase Authentication configurado
- [ ] Firestore configurado
- [ ] Reglas de Firestore desplegadas (`firebase deploy --only firestore:rules`)
- [ ] Usuario admin creado manualmente en Firebase (para testing)

---

### Test 1: Crear Usuario con Solo Campos Obligatorios

**Objetivo:** Verificar que se puede crear usuario con mínimo de campos

**Pasos:**
1. Iniciar sesión como admin
2. Ir a "Panel Admin" → "Gestionar Empleados"
3. Click en "Nuevo Empleado" (botón azul)
4. Llenar SOLO 3 campos:
   - **Nombre:** Juan
   - **Primer Apellido:** Pérez
   - **Email:** juan.perez@escuela.com
5. Dejar todos los demás campos vacíos
6. Click "Guardar"

**Resultado Esperado:**
- [x] Drawer se cierra
- [x] Aparece diálogo "Usuario Creado" con:
  - Email: juan.perez@escuela.com
  - Contraseña temporal (8 caracteres aleatorios)
- [x] Firebase Console → Authentication muestra nuevo usuario
- [x] Firebase Console → Firestore → users/{userId} tiene documento con:
  ```
  {
    "userId": "...",
    "employeeId": "EMP-001",  // Auto-generado
    "email": "juan.perez@escuela.com",
    "displayName": "Juan Pérez",  // Auto-generado
    "role": "employee",
    "weeklyHours": 40.0,  // Valor por defecto
    "isActive": true,
    "createdAt": Timestamp
  }
  ```

---

### Test 2: Crear Usuario con Segundo Apellido

**Objetivo:** Verificar que displayName incluye segundo apellido

**Pasos:**
1. Abrir drawer "Nuevo Empleado"
2. Llenar campos:
   - **Nombre:** Ana
   - **Primer Apellido:** López
   - **Segundo Apellido:** García
   - **Email:** ana.lopez@escuela.com
3. Click "Guardar"

**Resultado Esperado:**
- [x] Usuario creado con:
  - `employeeId`: "EMP-002"
  - `displayName`: "Ana López García" (incluye segundo apellido)

---

### Test 3: Crear Usuario con Todos los Campos

**Objetivo:** Verificar que campos opcionales se guardan correctamente

**Pasos:**
1. Abrir drawer "Nuevo Empleado"
2. Llenar TODOS los campos:
   - **Nombre:** María
   - **Primer Apellido:** Sánchez
   - **Segundo Apellido:** Rodríguez
   - **DNI/NIE:** 12345678A
   - **Teléfono:** 612345678
   - **Email:** maria.sanchez@escuela.com
   - **Código empleado:** (dejar vacío - se auto-genera)
   - **Departamento:** Docente
   - **Cargo/Puesto:** Profesora de Piano
   - **Horas Semanales:** 25
   - **Rol:** employee (default)
3. Click "Guardar"

**Resultado Esperado:**
- [x] Usuario creado con todos los campos en Firestore:
  ```
  {
    "employeeId": "EMP-003",
    "displayName": "María Sánchez Rodríguez",
    "email": "maria.sanchez@escuela.com",
    "dni": "12345678A",
    "telefono": "612345678",
    "department": "Docente",
    "position": "Profesora de Piano",
    "weeklyHours": 25.0,
    "role": "employee",
    ...
  }
  ```

---

### Test 4: Crear Usuario con employeeId Manual

**Objetivo:** Verificar que se puede especificar employeeId manualmente

**Pasos:**
1. Abrir drawer "Nuevo Empleado"
2. Llenar:
   - **Nombre:** Carlos
   - **Primer Apellido:** Ruiz
   - **Email:** carlos.ruiz@escuela.com
   - **Código empleado:** EMP-042 (manual)
3. Click "Guardar"

**Resultado Esperado:**
- [x] Usuario creado con `employeeId`: "EMP-042" (el especificado)

---

### Test 5: Validación de Email Duplicado

**Objetivo:** Verificar que no se pueden crear usuarios con email existente

**Pasos:**
1. Abrir drawer "Nuevo Empleado"
2. Llenar:
   - **Nombre:** Test
   - **Primer Apellido:** Duplicate
   - **Email:** juan.perez@escuela.com (ya existe del Test 1)
3. Click "Guardar"

**Resultado Esperado:**
- [x] SnackBar rojo con mensaje: "El email ya está registrado"
- [x] Usuario NO se crea
- [x] Drawer permanece abierto

---

### Test 6: Validación de Campos Obligatorios

**Objetivo:** Verificar que valida campos obligatorios

**Pasos:**
1. Abrir drawer "Nuevo Empleado"
2. Dejar campos vacíos y click "Guardar"
3. Debería mostrar errores:
   - Nombre: "Campo obligatorio"
   - Primer Apellido: "Campo obligatorio"
   - Email: "Campo obligatorio"

**Resultado Esperado:**
- [x] SnackBar: "Por favor completa todos los campos obligatorios"
- [x] Campos obligatorios marcados en rojo
- [x] Usuario NO se crea

---

### Test 7: Validación de Email Inválido

**Objetivo:** Verificar validación de formato de email

**Pasos:**
1. Abrir drawer "Nuevo Empleado"
2. Llenar:
   - **Nombre:** Test
   - **Primer Apellido:** Email
   - **Email:** emailinvalido (sin @)
3. Click "Guardar"

**Resultado Esperado:**
- [x] Error: "Email inválido"
- [x] Usuario NO se crea

---

### Test 8: Guardar y Agregar Otro

**Objetivo:** Verificar funcionalidad "Guardar y Agregar Otro"

**Pasos:**
1. Abrir drawer "Nuevo Empleado"
2. Llenar datos válidos
3. Click "Guardar y Agregar Otro" (botón outline)
4. Verificar:
   - Usuario se crea
   - SnackBar verde con credenciales
   - Drawer permanece abierto
   - Formulario se limpia (todos los campos vacíos)

**Resultado Esperado:**
- [x] Usuario creado en Firebase
- [x] Drawer abierto con formulario limpio
- [x] Listo para crear otro usuario

---

### Test 9: Crear 3 Usuarios Adicionales

**Objetivo:** Verificar secuencia de employeeId

**Pasos:**
1. Crear 3 usuarios más con "Guardar y Agregar Otro"
2. Verificar en Firestore que employeeId se incrementa:
   - Usuario 1: EMP-004
   - Usuario 2: EMP-005
   - Usuario 3: EMP-006

**Resultado Esperado:**
- [x] EmployeeId secuencial sin gaps
- [x] Todos los usuarios en Firebase

---

### Test 10: Ver Usuario en Lista de Empleados

**Objetivo:** Verificar que usuarios creados aparecen en lista

**Pasos:**
1. Ir a "Panel Admin" → "Gestionar Empleados"
2. Verificar que todos los usuarios creados aparecen en la lista
3. Usar barra de búsqueda para buscar "Juan"

**Resultado Esperado:**
- [x] Todos los usuarios creados aparecen
- [x] Búsqueda funciona correctamente
- [x] Datos mostrados son correctos (nombre, email, cargo, etc.)

---

## 🔧 Troubleshooting

### Error: "Usuario no autorizado"
**Causa:** Usuario actual no es admin/rrhh  
**Solución:** Verificar en Firestore que el usuario tenga `role: "admin"` o `role: "rrhh"`

### Error: "Network error"
**Causa:** No hay conexión a Firebase  
**Solución:** Verificar configuración en `firebase_options.dart` y que emulator esté corriendo si se usa local

### Error: "Permission denied"
**Causa:** Firestore Rules no actualizadas  
**Solución:** Ejecutar `firebase deploy --only firestore:rules`

---

## 📊 Métricas de Éxito

Al finalizar todos los tests:
- ✅ Mínimo 6 usuarios creados en Firebase
- ✅ 0 errores en consola Flutter
- ✅ 0 warnings de seguridad en Firestore
- ✅ Todos los usuarios con datos correctos
- ✅ Secuencia de employeeId correcta

---

## 🎯 Próximos Pasos

Una vez completado el testing del Día 1:
- **DÍA 2:** Sistema de Pausas - Backend
- **DÍA 3:** Sistema de Pausas - Frontend
- **DÍA 4:** Panel Admin - Ver Todos
- **DÍA 5:** Editar Fichajes
- **DÍA 6:** Crear 458 Usuarios en Lotes
- **DÍA 7:** Testing Final y Documentación

---

**Última actualización:** 31 Diciembre 2025  
**Estado:** ✅ Listo para testing manual

