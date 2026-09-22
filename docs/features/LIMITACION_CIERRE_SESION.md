# LIMITACIÓN CONOCIDA: Cierre de Sesión al Crear Usuarios

**Sprint 1.1 - 1.5**  
**Fecha:** 31 Diciembre 2025  
**Estado:** ⚠️ Limitación temporal - Solución definitiva pendiente

---

## 🐛 Problema

Al usar `FirebaseAuth.createUserWithEmailAndPassword()` desde el cliente, Firebase **automáticamente inicia sesión con el usuario recién creado**, lo que cierra la sesión del admin que está creando el usuario.

### Comportamiento Actual:
1. Admin hace clic en "Guardar" en el drawer de nuevo empleado
2. Se crea el usuario correctamente en Firebase Auth + Firestore
3. ⚠️ La sesión del admin se cierra automáticamente
4. Admin es redirigido a la pantalla de login

---

## ✅ Solución Temporal (ACTUAL)

### Para los próximos 6 días (hasta tener los 458 usuarios):

**Workflow Admin:**
1. Admin inicia sesión
2. Admin crea usuario(s)
3. Admin anota las credenciales mostradas en el diálogo
4. ⚠️ Sesión se cierra automáticamente
5. Admin vuelve a iniciar sesión
6. Repite el proceso

### Optimización para Creación Masiva (Día 6):

Para crear los 458 usuarios en lotes:

**Opción A: Persistir credenciales admin localmente**
```dart
// Guardar credenciales admin en SharedPreferences
// Antes de crear usuario:
final adminEmail = currentUser.email;
await prefs.setString('admin_email', adminEmail);

// Después de crear usuario y cerrar sesión:
// Auto-login con credenciales guardadas
```

**Opción B: Crear múltiples usuarios en una sola sesión**
- Usar "Guardar y Agregar Otro" varias veces
- Anotar todas las credenciales
- Al final se cierra sesión una sola vez
- **Estimación:** ~5-10 usuarios por sesión antes de re-login

---

## 🎯 Solución Definitiva (POST-MVP)

### Implementar Cloud Function con Firebase Admin SDK

La solución profesional y segura es usar **Firebase Cloud Functions**:

#### 1. Crear Cloud Function

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.createEmployee = functions.https.onCall(async (data, context) => {
  // Verificar que el usuario está autenticado y es admin
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Usuario no autenticado');
  }

  const callerUid = context.auth.uid;
  const callerDoc = await admin.firestore().collection('users').doc(callerUid).get();
  
  if (!callerDoc.exists || !['admin', 'rrhh'].includes(callerDoc.data().role)) {
    throw new functions.https.HttpsError('permission-denied', 'No tienes permisos');
  }

  const { email, password, nombre, apellido1, apellido2, ...userData } = data;

  try {
    // Crear usuario con Admin SDK (NO cierra sesión del admin)
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: `${nombre} ${apellido1}${apellido2 ? ' ' + apellido2 : ''}`,
    });

    // Crear documento en Firestore
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      userId: userRecord.uid,
      email: email,
      displayName: userRecord.displayName,
      ...userData,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      userId: userRecord.uid,
      employeeId: userData.employeeId,
    };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
```

#### 2. Actualizar Flutter Service

```dart
// lib/core/services/firebase_service.dart

Future<Map<String, String>> createEmployee({...}) async {
  // Llamar a la Cloud Function en lugar de createUserWithEmailAndPassword
  final callable = FirebaseFunctions.instance.httpsCallable('createEmployee');
  
  final result = await callable.call({
    'email': email,
    'password': temporaryPassword,
    'nombre': nombre,
    'apellido1': apellido1,
    'apellido2': apellido2,
    // ... resto de datos
  });

  return {
    'userId': result.data['userId'],
    'temporaryPassword': temporaryPassword,
    'employeeId': result.data['employeeId'],
  };
}
```

#### 3. Desplegar Function

```bash
firebase deploy --only functions:createEmployee
```

---

## 📊 Ventajas Solución Definitiva

✅ **No cierra sesión del admin**  
✅ **Más seguro** (validaciones en servidor)  
✅ **Permite batch operations** (crear múltiples usuarios en una llamada)  
✅ **Mejor manejo de errores**  
✅ **Logs centralizados** en Firebase Console

---

## 🗓️ Timeline Propuesto

### AHORA (Día 1-6): Solución Temporal
- [x] Documentar limitación
- [x] Implementación actual funcional
- [ ] Admin re-inicia sesión tras cada creación
- [ ] Crear los 458 usuarios con workflow temporal

### POST-MVP (Día 8+): Solución Definitiva
- [ ] Configurar Firebase Functions
- [ ] Implementar función `createEmployee`
- [ ] Actualizar `firebase_service.dart` para usar function
- [ ] Testing
- [ ] Desplegar
- [ ] Validar que no cierra sesión

---

## 💡 Alternativa Adicional (Sin Functions)

Si no quieres usar Cloud Functions, otra opción es:

### Usar Firebase Admin SDK desde un Backend Propio

- Servidor Node.js/Python/Go con Firebase Admin SDK
- API REST endpoint `/api/create-employee`
- Flutter llama a tu API en lugar de Firebase directamente
- Requiere mantener un servidor adicional

---

## 📝 Notas

- La limitación actual NO afecta la funcionalidad: los usuarios SÍ se crean correctamente
- Es solo una inconveniencia para el admin que debe re-iniciar sesión
- Para los 458 usuarios (Día 6), podemos crear ~50-60 por hora con re-logins
- Esta nota describe una solución hipotética para una futura adaptación del portfolio.

---

**Última actualización:** 31 Diciembre 2025  
**Prioridad:** Media (no bloquea MVP)  
**ETA Solución Definitiva:** Post-Día 7




