# Índices de Firestore Requeridos

Este documento describe los índices compuestos necesarios en Firestore para la funcionalidad "Mi Control Horario".

## Índices Compuestos

### 1. Registros de Tiempo por Mes

**Colección:** `users/{userId}/time_records`

**Campos:**
- `date` (Ascending)
- `startTime` (Ascending)

**Descripción:** Permite consultar registros de un rango de fechas (mes) ordenados por fecha y hora de inicio.

**Query usada:**
```dart
_firestore
  .collection('users/$userId/time_records')
  .where('date', isGreaterThanOrEqualTo: startDateStr)
  .where('date', isLessThanOrEqualTo: endDateStr)
  .orderBy('date')
  .orderBy('startTime')
```

### 2. Registros de un Día Específico

**Colección:** `users/{userId}/time_records`

**Campos:**
- `date` (Ascending)
- `startTime` (Ascending)

**Descripción:** Permite consultar todos los registros de un día específico ordenados por hora de inicio.

**Query usada:**
```dart
_firestore
  .collection('users/$userId/time_records')
  .where('date', isEqualTo: dateStr)
  .orderBy('startTime')
```

## Cómo Crear los Índices

### Opción 1: Crear Automáticamente (Recomendado)

1. Ejecuta la aplicación en modo desarrollo
2. Realiza una consulta que requiera el índice
3. Firebase mostrará un error con un enlace directo para crear el índice
4. Haz clic en el enlace y Firebase creará el índice automáticamente

### Opción 2: Crear Manualmente

1. Ve a la consola de Firebase: https://console.firebase.google.com/
2. Selecciona tu proyecto
3. Ve a Firestore Database > Índices
4. Haz clic en "Crear índice"
5. Configura los campos según lo especificado arriba

### Opción 3: Usar Firebase CLI

Crea un archivo `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "time_records",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "date",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "startTime",
          "order": "ASCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

Luego ejecuta:
```bash
firebase deploy --only firestore:indexes
```

## Estimación de Costos

**Operaciones de lectura:** 
- Consulta mensual: ~30-31 documentos (uno por día)
- Consulta diaria: ~1-10 documentos (registros del día)

**Almacenamiento de índices:**
- Cada índice añade ~100 bytes por documento
- Para 1000 registros: ~0.1 MB adicionales (costo insignificante)

**Optimización:**
- Los índices son necesarios pero tienen un costo de almacenamiento mínimo
- Mejoran drásticamente el rendimiento de las queries
- Son esenciales para una buena experiencia de usuario

## Notas Adicionales

- Los índices se crean por colección, no por subcolección individual
- Firebase crea automáticamente índices de campo único
- Solo necesitas crear índices compuestos manualmente
- Los índices tardan unos minutos en construirse la primera vez
- Una vez creados, se aplican a todas las subcolecciones `time_records` de todos los usuarios












