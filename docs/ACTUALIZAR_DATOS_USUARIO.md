# Actualizar Datos de Usuario en Firestore

## Nuevos Campos Añadidos

Se han añadido los siguientes campos opcionales al modelo `UserModel`:

- **position** (String): Cargo del empleado (ej: "Desarrolladora Frontend Senior")
- **department** (String): Departamento (ej: "Tecnología")
- **schedule** (String): Horario laboral (ej: "09:00 - 18:00")

## Cómo Actualizar los Usuarios Existentes

### Opción 1: Firebase Console (Manual)

1. Ve a Firebase Console: https://console.firebase.google.com
2. Selecciona tu proyecto
3. Ve a **Firestore Database**
4. Navega a la colección **users**
5. Para cada documento de usuario, añade los siguientes campos:

```json
{
  "position": "Cargo del empleado",
  "department": "Nombre del departamento",
  "schedule": "09:00 - 18:00"
}
```

### Opción 2: Datos de Ejemplo

Aquí tienes datos de ejemplo para los usuarios de prueba:

#### María García (EMP-004 / maria@escuela.com)
```json
{
  "position": "Desarrolladora Frontend Senior",
  "department": "Tecnología",
  "schedule": "09:00 - 18:00"
}
```

#### Juan Pérez (EMP-003 / empleado@escuela.com)
```json
{
  "position": "Profesor de Piano",
  "department": "Docente",
  "schedule": "10:00 - 19:00"
}
```

#### Carlos López (EMP-005 / carlos@escuela.com)
```json
{
  "position": "Profesor de Guitarra",
  "department": "Docente",
  "schedule": "15:00 - 21:00"
}
```

#### Admin Sistema (EMP-001 / admin@escuela.com)
```json
{
  "position": "Director General",
  "department": "Administración",
  "schedule": "08:00 - 17:00"
}
```

#### RRHH Responsable (EMP-002 / rrhh@escuela.com)
```json
{
  "position": "Responsable de RRHH",
  "department": "Recursos Humanos",
  "schedule": "09:00 - 18:00"
}
```

## Formato del Campo Schedule

El campo `schedule` debe seguir el formato: `"HH:mm - HH:mm"`

Ejemplos válidos:
- `"09:00 - 18:00"` (jornada completa)
- `"10:00 - 14:00"` (media jornada mañana)
- `"15:00 - 21:00"` (media jornada tarde)

## Notas

- Estos campos son **opcionales**. Si no están presentes, simplemente no se mostrarán en la UI.
- El badge de "En horario / Fuera de horario" se calcula automáticamente según:
  - La hora actual
  - El horario definido en el campo `schedule`
  - Por defecto usa "09:00 - 18:00" si no hay horario definido

## Efectos Visuales

Una vez añadidos estos campos, el header del dashboard mostrará:

1. ✅ Avatar con indicador de estado (círculo azul)
2. ✅ Nombre completo del empleado
3. ✅ Cargo con icono de maletín
4. ✅ Departamento con icono de persona
5. ✅ ID de empleado con icono de badge
6. ✅ Badge de estado: "En horario" (verde) o "Fuera de horario" (amarillo)
7. ✅ Fecha actual formateada en español
8. ✅ Botones de notificaciones y configuración

## Próximos Pasos (FASE 2)

En la Fase 2 se implementará:
- Actualización automática de estos campos desde el panel de administración
- Gestión de horarios flexibles y turnos
- Consideración de días festivos y fines de semana
- Zonas horarias
