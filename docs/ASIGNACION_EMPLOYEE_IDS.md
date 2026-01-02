# Asignación de EmployeeIds - Guía

**Fecha:** 31 Diciembre 2025  
**Sprint:** Día 1 - Testing

---

## 📋 Estrategia Simplificada

Para facilitar el testing y la creación masiva de usuarios:

### Durante Testing (Día 1-5):
- ✅ Usuarios se crean **sin employeeId** (campo vacío: `""`)
- ✅ Proceso más rápido y simple
- ✅ Sin problemas de permisos o queries
- ✅ Puedes crear y eliminar usuarios libremente

### Día 6 (Antes de Producción):
- ✅ Ejecutar script que asigna IDs secuenciales a TODOS los usuarios
- ✅ En orden de fecha de creación
- ✅ Formato: EMP-001, EMP-002, ..., EMP-458

---

## 🚀 Cómo Usar el Script

### Ejecutar el Script

```bash
# Desde la raíz del proyecto
dart run scripts/assign_employee_ids.dart
```

### ¿Qué hace el script?

1. Busca todos los usuarios con `employeeId == ""`
2. Los ordena por `createdAt` (fecha de creación)
3. Les asigna IDs secuenciales:
   - Primer usuario creado → EMP-001
   - Segundo usuario → EMP-002
   - ...
   - Usuario 458 → EMP-458

4. Si ya hay usuarios con employeeId, continúa la secuencia:
   - Último ID: EMP-100
   - Nuevos usuarios: EMP-101, EMP-102, etc.

### Ejemplo de Salida

```
🚀 Iniciando asignación de employeeIds...

📋 Buscando usuarios sin employeeId...
📊 Encontrados 458 usuarios sin employeeId

🔢 Comenzando desde: EMP-001

⏳ Asignando employeeIds...

✅ EMP-001 → Juan Pérez (juan.perez@escuela.com)
✅ EMP-002 → Ana López (ana.lopez@escuela.com)
✅ EMP-003 → María García (maria.garcia@escuela.com)
...
✅ EMP-458 → Carlos Ruiz (carlos.ruiz@escuela.com)

============================================================
📊 RESUMEN:
   Procesados: 458
   Exitosos:   458 ✅
   Fallidos:   0 ❌
============================================================

🎉 Proceso completado!
```

---

## 📝 Testing Durante el Desarrollo

### Crear Usuarios de Prueba

Mientras estás en testing:

1. Crea usuarios normalmente desde el panel admin
2. El `employeeId` quedará vacío (no hay problema)
3. Puedes eliminar usuarios desde Firebase Console
4. Puedes crear múltiples usuarios sin preocuparte por la secuencia

### Cuando Quieras Asignar IDs

En cualquier momento puedes ejecutar el script:

```bash
dart run scripts/assign_employee_ids.dart
```

Esto asignará IDs a todos los usuarios que no tengan, manteniendo los IDs ya asignados.

---

## 🔍 Verificar en Firebase Console

Después de ejecutar el script:

1. Ve a **Firestore Database** → Colección `users`
2. Verifica que todos tengan `employeeId` asignado
3. Los IDs deberían ser secuenciales: EMP-001, EMP-002, etc.

---

## ⚠️ Importante

### Orden de Creación

Los IDs se asignan en orden de **fecha de creación** (`createdAt`), NO en orden alfabético.

Si quieres un orden específico, tendrías que modificar el script para ordenar por otro criterio (ej: `displayName`, `department`, etc.)

### Re-ejecutar el Script

Es **seguro** ejecutar el script múltiples veces:
- Solo asigna IDs a usuarios que NO tienen employeeId
- NO modifica usuarios que ya tienen ID asignado
- Continúa la secuencia desde el último ID existente

---

## 💡 Ventajas de Esta Estrategia

### Durante Testing:
- ✅ Creación de usuarios más rápida
- ✅ Sin problemas de permisos
- ✅ Sin race conditions
- ✅ Puedes eliminar y recrear usuarios libremente

### Día 6 (Producción):
- ✅ Asignas 458 IDs en ~1 minuto
- ✅ IDs perfectamente secuenciales
- ✅ Sin gaps
- ✅ Todo bajo control

---

## 🎯 Timeline

**Día 1-5:** 
- Crear usuarios sin employeeId
- Testing completo de funcionalidades

**Día 6 (Mañana):**
- Ejecutar script de asignación
- Verificar que todos tienen ID
- Listo para producción

**Día 7:**
- Testing final con IDs asignados
- Go live 🚀

---

**Última actualización:** 31 Diciembre 2025  
**Script:** `scripts/assign_employee_ids.dart`


