# 🚀 Deployment Quickstart - Control Horario MVP

## ✅ Pre-requisitos COMPLETADOS

Todos los pre-requisitos del deployment están implementados y funcionando:

- ✅ TimeClockCard con fichaje real en Firebase
- ✅ DaySummaryCard con datos reales
- ✅ RecentRecordsCard con registros reales
- ✅ Build de producción exitoso
- ✅ Firestore rules actualizadas

---

## 🎯 Pasos para Deployment

### 1. Probar Localmente (OPCIONAL pero recomendado)

La app ya está corriendo en Chrome (terminal 4). Prueba:

1. Ir a http://localhost (el puerto que muestre en el terminal)
2. Login con: `empleado@escuela.com` / `empleado123`
3. Fichar entrada
4. Verificar que aparece en DaySummaryCard y RecentRecordsCard
5. Fichar salida
6. Logout

### 2. Deploy Reglas de Firestore

```bash
firebase deploy --only firestore:rules
```

**Resultado esperado:**
```
✔  Deploy complete!
```

### 3. Deploy a Firebase Hosting

```bash
# El build ya está listo en build/web/
firebase deploy --only hosting -m "MVP Sprint 1 - Fichaje funcional"
```

**Resultado esperado:**
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/...
Hosting URL: https://control-horario-xxxx.web.app
```

### 4. Verificar en Producción

1. Abrir la URL de Hosting en navegador
2. Login con usuarios de prueba
3. Probar fichaje entrada/salida
4. Verificar datos en tiempo real

---

## 👥 Usuarios de Prueba

**Empleado:**
- Email: `empleado@escuela.com`
- Password: `empleado123`
- Acceso: Panel de empleado

**Admin:**
- Email: `admin@escuela.com`
- Password: `admin123`
- Acceso: Panel de administración

**RRHH:**
- Email: `rrhh@escuela.com`
- Password: `rrhh123`
- Acceso: Panel de administración

---

## 📧 Enviar al Cliente

Una vez verificado, envía el email usando el template en:
`.cursor/plans/deployment-plan.md` (líneas 193-246)

**Incluir:**
- URL de la aplicación
- Credenciales de acceso
- Funcionalidades implementadas
- Solicitud de feedback

---

## 🔥 Comandos Rápidos

```bash
# Ver estado de Firebase
firebase projects:list

# Deploy completo (reglas + hosting)
firebase deploy

# Ver logs de hosting
firebase hosting:channel:list

# Rollback (si algo sale mal)
firebase hosting:clone SOURCE_SITE_ID:SOURCE_CHANNEL_ID TARGET_SITE_ID:live
```

---

## 📱 URLs Importantes

**Firebase Console:**
https://console.firebase.google.com/project/control-horario

**Hosting URL:**
Se mostrará después del `firebase deploy --only hosting`

**DevTools Local:**
http://127.0.0.1:62993/devtools/ (si app local sigue corriendo)

---

## ⚠️ Troubleshooting

### Error: "Firebase config not found"
```bash
# Verificar que firebase.json existe
dir firebase.json

# Re-inicializar si es necesario
firebase init hosting
```

### Error: "Build not found"
```bash
# Verificar que build/web existe
dir build\web

# Reconstruir si es necesario
flutter build web --release
```

### Error en reglas de Firestore
```bash
# Verificar sintaxis
firebase deploy --only firestore:rules --debug

# Ver reglas actuales en consola
# https://console.firebase.google.com/project/control-horario/firestore/rules
```

---

## ✅ Checklist Pre-Deploy

- [ ] Build de producción completado sin errores
- [ ] Firestore rules actualizadas
- [ ] Usuarios de prueba creados en Firebase
- [ ] Probado localmente (opcional)
- [ ] Firebase CLI configurado
- [ ] Proyecto correcto seleccionado: `firebase projects:list`

---

## 🎉 Post-Deploy

1. **Verificar app en producción:**
   - Login funciona
   - Fichaje guarda en Firestore
   - Datos se muestran correctamente

2. **Monitorear Firebase Console:**
   - Authentication → Verificar logins
   - Firestore → Verificar registros creados
   - Hosting → Verificar tráfico

3. **Enviar email al cliente:**
   - URL de acceso
   - Credenciales
   - Solicitar feedback

4. **Documentar feedback:**
   - Crear issues para mejoras
   - Priorizar para Sprint 2

---

**¿Listo para deployar? Ejecuta:**

```bash
firebase deploy --only firestore:rules && firebase deploy --only hosting
```

**Tiempo estimado:** 2-3 minutos

---

**Última actualización:** 23 Noviembre 2025

