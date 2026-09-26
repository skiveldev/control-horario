# Checklist de Deployment: Mi Control Horario

> ⚠️ **Portfolio codebase.** This document is future reference only. No deployment
> has occurred. Publication gates (license, history cleanup, Firebase Console
> hardening) are pending.

## 📋 Pre-Deployment

### Código y Compilación

- [x] Código analizado sin errores (`flutter analyze`)
- [x] Build runner ejecutado (`dart run build_runner build`)
- [x] Todos los imports correctos
- [x] Comentarios y documentación añadidos
- [ ] Tests ejecutados (cuando se creen)

### Firebase Configuration

- [ ] **Firestore Rules desplegadas**
  ```bash
  firebase deploy --only firestore:rules
  ```

- [ ] **Índices compuestos creados**
  - Opción A: Ejecutar app y seguir enlaces de error (automático)
  - Opción B: Desplegar `firestore.indexes.json`
  ```bash
  firebase deploy --only firestore:indexes
  ```

- [ ] **Verificar permisos de lectura/escritura**
  - Probar como empleado autenticado
  - Verificar que no puede acceder a registros de otros usuarios

### Configuración de Ubicaciones

- [ ] **Crear documento de configuración de ubicaciones**
  
  En Firestore, crear:
  ```
  Collection: system_config
  Document: locations
  
  Data:
  {
    "locations": [
      {
        "id": "oficina",
        "name": "Oficina",
        "icon": "business",
        "isActive": true
      },
      {
        "id": "delegacion_madrid",
        "name": "Delegación Madrid",
        "icon": "location_city",
        "isActive": true
      },
      {
        "id": "remoto",
        "name": "Remoto",
        "icon": "home",
        "isActive": true
      },
      {
        "id": "cliente",
        "name": "Cliente",
        "icon": "business_center",
        "isActive": true
      }
    ]
  }
  ```

---

## 🧪 Testing Manual

### Test 1: Navegación Básica

- [ ] Login como empleado
- [ ] Abrir menú (hamburger en mobile, sidebar en desktop)
- [ ] Click en "Mi Control Horario"
- [ ] Verificar que carga la pantalla correctamente
- [ ] Verificar que muestra el mes actual

### Test 2: Navegación de Meses

- [ ] Click en flecha ← (mes anterior)
- [ ] Verificar que cambia al mes anterior
- [ ] Click en flecha → (mes siguiente)
- [ ] Navegar hasta mes futuro
- [ ] Verificar que muestra empty state "No se ha activado..."
- [ ] Click en "Volver al mes actual"
- [ ] Verificar que vuelve al mes actual

### Test 3: Añadir Registro

- [ ] Expandir día actual
- [ ] Click en "+ Añadir"
- [ ] Verificar que abre modal
- [ ] Seleccionar "Trabajo"
- [ ] Ingresar hora inicio: 09:00
- [ ] Ingresar hora fin: 17:00
- [ ] Verificar duración: 8h 00m
- [ ] Seleccionar ubicación "Oficina"
- [ ] Click en "Guardar Registro"
- [ ] Verificar Snackbar "✓ Registro guardado"
- [ ] Verificar que el registro aparece en la lista

### Test 4: Editar Registro

- [ ] Click en ✏️ de un registro
- [ ] Verificar que abre modal con datos pre-llenados
- [ ] Cambiar hora fin a 18:00
- [ ] Verificar nueva duración: 9h 00m
- [ ] Click en "Actualizar Registro"
- [ ] Verificar Snackbar "✓ Registro actualizado"
- [ ] Verificar cambios en la lista

### Test 5: Copiar Registro

- [ ] Click en 📋 de un registro
- [ ] Seleccionar día destino (ej: mañana)
- [ ] Click en "Aceptar"
- [ ] Verificar Snackbar "✓ Registro copiado..."
- [ ] Navegar al día destino
- [ ] Verificar que el registro copiado está allí

### Test 6: Eliminar Registro

- [ ] Click en 🗑️ de un registro
- [ ] Verificar que muestra confirmación
- [ ] Click en "Eliminar"
- [ ] Verificar Snackbar "✓ Registro eliminado"
- [ ] Verificar que el registro desaparece

### Test 7: Estado Validado

- [ ] Crear registro con `validationStatus: "validated"` en Firestore
- [ ] Refrescar pantalla
- [ ] Verificar badge verde "✅ Validado"
- [ ] Click en ✏️ editar
- [ ] Verificar aviso azul "Este registro fue validado..."
- [ ] Editar y guardar
- [ ] Verificar que badge cambia a "✏️ Modificado" (ámbar)

### Test 8: Estado Bloqueado

- [ ] Crear registro con `validationStatus: "blocked"` en Firestore
- [ ] Refrescar pantalla
- [ ] Verificar badge rojo "🔒 Bloqueado"
- [ ] Click en ✏️ editar (debería estar deshabilitado/gris)
- [ ] Si no está deshabilitado, verificar que muestra modal "Registro Bloqueado"
- [ ] Verificar que no se puede editar ni eliminar

### Test 9: Responsive

- [ ] **Desktop (>1024px):**
  - Verificar vista tabla completa
  - Verificar modal de 600px centrado
  - Verificar navegación fluida

- [ ] **Tablet (768-1024px):**
  - Verificar adaptación de layout
  - Verificar drawer lateral

- [ ] **Mobile (<768px):**
  - Verificar vista compacta
  - Verificar drawer hamburger
  - Verificar acciones en columna
  - Verificar touch targets grandes (44x44px)

### Test 10: Estados Especiales

- [ ] **Día sin registros:**
  - Expandir día vacío
  - Verificar mensaje "Sin registros"

- [ ] **Loading state:**
  - Refrescar pantalla
  - Verificar spinner mientras carga

- [ ] **Error state:**
  - Desconectar internet o Firebase
  - Verificar mensaje de error
  - Reconectar y verificar recuperación

---

## 🚀 Deployment Steps

### 1. Commit de Código

```bash
git add .
git commit -m "feat: Implementar pantalla Mi Control Horario

- Vista mensual completa con navegación
- Sistema CRUD de registros (añadir, editar, copiar, eliminar)
- Sistema de validación/bloqueo (editable, validado, bloqueado)
- Control de meses futuros con empty state
- Modal profesional con validaciones en tiempo real
- Diseño tabla-like responsive
- Reglas de seguridad Firestore
- Documentación completa"
```

### 2. Deploy a Firebase

```bash
# Desplegar reglas de Firestore
firebase deploy --only firestore:rules

# Desplegar índices (si creaste firestore.indexes.json)
firebase deploy --only firestore:indexes

# Desplegar hosting (si es necesario)
firebase deploy --only hosting
```

### 3. Build y Deploy Web

```bash
# Build producción
flutter build web --release

# Deploy a Firebase Hosting
firebase deploy --only hosting
```

### 4. Verificación Post-Deploy

- [ ] Acceder a la URL de producción
- [ ] Login como empleado
- [ ] Verificar que "Mi Control Horario" aparece en menú
- [ ] Realizar test completo de funcionalidad
- [ ] Verificar que no hay errores en consola del navegador
- [ ] Verificar que reglas de Firestore funcionan correctamente

---

## 📊 Métricas de Éxito

### KPIs a Monitorear

1. **Uso de la Feature:**
   - % de empleados que acceden a "Mi Control Horario"
   - Frecuencia de uso (diaria, semanal, mensual)

2. **Operaciones:**
   - Número de registros añadidos manualmente
   - Número de registros editados
   - Número de registros copiados
   - Número de registros eliminados

3. **Performance:**
   - Tiempo de carga inicial de la pantalla
   - Tiempo de respuesta de operaciones CRUD
   - Número de queries a Firestore por sesión

4. **Errores:**
   - Tasa de errores en operaciones CRUD
   - Errores de permisos (debería ser 0%)
   - Errores de validación

### Objetivos

- ✅ Carga inicial < 2 segundos
- ✅ Operaciones CRUD < 1 segundo
- ✅ 0 errores de permisos
- ✅ Responsive en todos los breakpoints
- ✅ Accesible (contraste, touch targets)

---

## 🔒 Seguridad

### Reglas Implementadas

1. **Lectura:** Solo registros propios
2. **Creación:** Solo con estado "editable"
3. **Actualización:** Solo si no está bloqueado
4. **Eliminación:** Solo si no está bloqueado
5. **Bloqueo:** Solo admin puede bloquear/desbloquear

### Validaciones Backend

- ✅ Usuario solo puede modificar sus propios registros
- ✅ No se pueden editar registros bloqueados
- ✅ Solo admin puede cambiar validationStatus a "blocked"
- ✅ Timestamps de creación/actualización automáticos

---

## 📞 Soporte

### Problemas Comunes

**P: No veo la opción "Mi Control Horario" en el menú**  
R: Asegúrate de estar logueado como empleado y que la ruta está registrada en el router.

**P: No puedo editar un registro**  
R: Verifica el estado del registro. Si está bloqueado (🔒), solo un admin puede desbloquearlo.

**P: El resumen del mes muestra 0 horas**  
R: Añade registros usando el botón "+ Añadir" en cada día.

**P: No puedo navegar a meses futuros**  
R: Esto es intencional. Los meses futuros se activan automáticamente cuando llegue el período.

### Contacto

Para dudas técnicas o reportar bugs, contactar con el equipo de desarrollo.

---

**✅ LISTO PARA DEPLOYMENT**

Fecha: 14 Diciembre 2025  
Versión: 1.0.0  
Autor: Control Horario Team













