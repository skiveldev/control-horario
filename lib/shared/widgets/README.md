# Widgets Compartidos - Control Horario

Librería de componentes reutilizables para la aplicación Control Horario.

## 📦 Estructura

```
shared/widgets/
├── buttons/          # Botones y controles
├── cards/            # Cards y contenedores
├── inputs/           # Campos de texto y formularios
├── layouts/          # Layouts y estructuras
├── loading_spinner.dart
├── empty_state.dart
└── error_state.dart
```

---

## 🎨 Botones

### CustomButton

Botón principal con 4 variantes: `primary`, `secondary`, `outline`, `text`.

**Uso:**

```dart
CustomButton(
  text: 'Guardar',
  icon: Icons.save,
  variant: ButtonVariant.primary,
  size: ButtonSize.medium,
  onPressed: () {},
)
```

**Propiedades:**
- `text`: Texto del botón
- `icon`: Ícono opcional (izquierda)
- `variant`: Estilo visual
- `size`: Tamaño (small, medium, large)
- `fullWidth`: Ocupar todo el ancho
- `isLoading`: Mostrar spinner
- `isDisabled`: Deshabilitar botón
- `onPressed`: Callback al presionar

### IconButtonCustom

Botón de solo ícono.

```dart
IconButtonCustom(
  icon: Icons.notifications,
  variant: IconButtonVariant.filled,
  onPressed: () {},
)
```

---

## 📝 Inputs

### CustomTextField

Campo de texto con validación visual.

**Uso:**

```dart
CustomTextField(
  controller: _controller,
  label: 'Email',
  hintText: 'usuario@ejemplo.com',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value?.isEmpty == true ? 'Requerido' : null,
  onChanged: (value) => print(value),
)
```

**Propiedades:**
- `controller`: TextEditingController
- `label`: Etiqueta flotante
- `hintText`: Placeholder
- `prefixIcon` / `suffixIcon`: Íconos
- `keyboardType`: Tipo de teclado
- `validator`: Función de validación
- `onChanged`: Callback al cambiar
- `obscureText`: Ocultar texto (contraseñas)
- `maxLines`: Líneas máximas
- `isDisabled`: Deshabilitar campo

### CustomPasswordField

Campo especializado para contraseñas con toggle de visibilidad.

```dart
CustomPasswordField(
  controller: _passwordController,
  label: 'Contraseña',
  validator: (value) => value?.length < 6 ? 'Mínimo 6 caracteres' : null,
)
```

---

## 🎴 Cards

### CustomCard

Card base con elevación y bordes personalizables.

**Uso:**

```dart
CustomCard(
  elevation: CardElevation.medium,
  hasBorder: true,
  padding: AppSpacing.cardMedium,
  child: Text('Contenido'),
)
```

**Propiedades:**
- `elevation`: Nivel de elevación (none, low, medium, high)
- `hasBorder`: Mostrar borde
- `padding`: Padding interno
- `onTap`: Hacer clickeable el card
- `child`: Widget interno

### InfoCard

Card para métricas con ícono y valor destacado.

```dart
InfoCard(
  icon: Icons.timer,
  iconColor: AppColors.primary,
  title: 'Horas trabajadas',
  value: '8:45',
  subtitle: 'De 9 horas',
)
```

### StatCard

Card horizontal con ícono, título y valor.

```dart
StatCard(
  icon: Icons.check_circle,
  iconColor: AppColors.success,
  title: 'Días completos',
  value: '18',
)
```

---

## 🏗️ Layouts

### ResponsiveLayout

Wrapper para layouts adaptativos según breakpoints.

**Uso:**

```dart
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

**Breakpoints:**
- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px

### CustomAppBar

AppBar personalizada con soporte para avatar y notificaciones.

```dart
CustomAppBar(
  title: 'Dashboard',
  showAvatar: true,
  showNotifications: true,
  avatarUrl: 'https://...',
  onAvatarTap: () {},
  onNotificationsTap: () {},
  automaticallyImplyLeading: true,
)
```

**Propiedades:**
- `title`: Título del AppBar
- `showAvatar`: Mostrar avatar del usuario
- `showNotifications`: Mostrar ícono de notificaciones
- `avatarUrl`: URL de la imagen del avatar
- `notificationCount`: Número de notificaciones
- `actions`: Widgets adicionales
- `automaticallyImplyLeading`: Mostrar botón back

---

## 🔄 Estados

### LoadingSpinner

Indicador de carga circular con mensaje opcional.

```dart
LoadingSpinner(
  message: 'Cargando datos...',
  size: LoadingSize.large,
)
```

**Propiedades:**
- `message`: Texto opcional debajo del spinner
- `size`: Tamaño del spinner (small, medium, large)
- `color`: Color del spinner

### EmptyState

Widget para mostrar estados vacíos con ícono y mensaje.

```dart
EmptyState(
  icon: Icons.inbox,
  title: 'No hay registros',
  message: 'Aún no has fichado hoy',
  actionLabel: 'Fichar ahora',
  onAction: () {},
)
```

**Propiedades:**
- `icon`: Ícono del estado vacío
- `title`: Título del mensaje
- `message`: Descripción
- `actionLabel`: Texto del botón (opcional)
- `onAction`: Callback del botón

### ErrorState

Widget para mostrar errores con opción de reintento.

```dart
ErrorState(
  title: 'Error al cargar',
  message: 'No se pudieron obtener los datos',
  onRetry: () => _loadData(),
)
```

**Propiedades:**
- `title`: Título del error
- `message`: Descripción del error
- `onRetry`: Callback para reintentar

---

## 🎯 Best Practices

### 1. Usa const constructors siempre que sea posible

```dart
✅ const CustomButton(text: 'Ok', onPressed: null)
❌ CustomButton(text: 'Ok', onPressed: null)
```

### 2. Extrae widgets complejos

```dart
// ✅ Bueno
Widget _buildHeader() {
  return CustomCard(
    child: Text('Header'),
  );
}

// ❌ Evitar widgets inline muy largos
```

### 3. Usa los espaciados de AppSpacing

```dart
✅ padding: AppSpacing.allMd
❌ padding: const EdgeInsets.all(16)
```

### 4. Aprovecha los tamaños responsive

```dart
// ✅ Adapta según dispositivo
final cardSize = context.responsiveValue(
  mobile: 100.0,
  tablet: 150.0,
  desktop: 200.0,
);
```

### 5. Validación de formularios

```dart
CustomTextField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Campo requerido';
    }
    return null;
  },
)
```

---

## 🚀 Próximas mejoras (Fase 2+)

- [ ] Integrar validación de formularios con Riverpod
- [ ] Añadir más variantes de cards (gradient, glassmorphism)
- [ ] Crear DatePicker y TimePicker personalizados
- [ ] Tooltips personalizados
- [ ] Modales y dialogs avanzados
- [ ] Snackbars con variantes

---

## 📚 Referencias

- **Theme System**: `lib/core/theme/`
- **Breakpoints**: `lib/core/constants/breakpoints.dart`
- **Animaciones**: `lib/shared/utils/animations.dart`
- **Mock Data**: `lib/core/constants/mock_data.dart`

---

**Versión**: 1.0 - Fase 1 (UI Only)  
**Última actualización**: Noviembre 2025

