/// Constantes generales de controlhorario-rega
///
/// Centraliza todos los valores constantes usados en la aplicación.
/// Incluye duraciones, límites, configuraciones, etc.
class AppConstants {
  // Prevenir instanciación
  AppConstants._();

  // ============================================================================
  // APP INFO
  // ============================================================================

  /// Nombre de la aplicación
  static const String appName = 'controlhorario-rega';

  /// Versión de la aplicación
  static const String appVersion = '1.0.0';

  /// Descripción de la aplicación
  static const String appDescription =
      'Sistema de control horario para escuela de música';

  // ============================================================================
  // ANIMATION DURATIONS (Duraciones de animaciones)
  // ============================================================================

  /// Duración muy rápida - 100ms
  /// Uso: Feedback inmediato, hover effects
  static const Duration durationFast = Duration(milliseconds: 100);

  /// Duración rápida - 200ms
  /// Uso: Transiciones simples, fades
  static const Duration durationNormal = Duration(milliseconds: 200);

  /// Duración media - 300ms (estándar Material)
  /// Uso: Transiciones de pantalla, animaciones estándar
  static const Duration durationMedium = Duration(milliseconds: 300);

  /// Duración lenta - 500ms
  /// Uso: Animaciones complejas, transiciones importantes
  static const Duration durationSlow = Duration(milliseconds: 500);

  /// Duración muy lenta - 1000ms
  /// Uso: Animaciones de splash, carga inicial
  static const Duration durationVerySlow = Duration(milliseconds: 1000);

  // ============================================================================
  // ELEVATION (Elevaciones de sombras)
  // ============================================================================

  /// Sin elevación
  static const double elevationNone = 0.0;

  /// Elevación mínima - 1dp
  /// Uso: Separación sutil
  static const double elevationXs = 1.0;

  /// Elevación pequeña - 2dp
  /// Uso: Cards en reposo, botones
  static const double elevationSm = 2.0;

  /// Elevación media - 4dp
  /// Uso: Cards elevados, FAB en reposo
  static const double elevationMd = 4.0;

  /// Elevación grande - 8dp
  /// Uso: Navigation drawers, app bars, hover states
  static const double elevationLg = 8.0;

  /// Elevación extra grande - 12dp
  /// Uso: Modales, dialogs
  static const double elevationXl = 12.0;

  /// Elevación máxima - 16dp
  /// Uso: Menús flotantes, snackbars
  static const double elevationMax = 16.0;

  // ============================================================================
  // BORDERS (Anchos de bordes)
  // ============================================================================

  /// Borde fino - 1px
  static const double borderWidthThin = 1.0;

  /// Borde normal - 2px
  static const double borderWidthNormal = 2.0;

  /// Borde grueso - 3px
  static const double borderWidthThick = 3.0;

  // ============================================================================
  // OPACITY (Opacidades)
  // ============================================================================

  /// Transparente
  static const double opacityTransparent = 0.0;

  /// Muy transparente - 10%
  static const double opacityXs = 0.1;

  /// Transparente - 20%
  static const double opacitySm = 0.2;

  /// Semi-transparente - 50%
  static const double opacityMd = 0.5;

  /// Casi opaco - 80%
  static const double opacityLg = 0.8;

  /// Opaco
  static const double opacityFull = 1.0;

  // Opacidades para overlays
  static const double overlayLight = 0.04;
  static const double overlayMedium = 0.08;
  static const double overlayHeavy = 0.12;
  static const double overlayDark = 0.6;

  // ============================================================================
  // TIMES & DATES (Configuraciones de tiempo)
  // ============================================================================

  /// Duración del splash screen
  static const Duration splashDuration = Duration(seconds: 2);

  /// Timeout para requests HTTP
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Duración de auto-logout por inactividad
  static const Duration inactivityTimeout = Duration(minutes: 30);

  /// Duración de sesión (en producción sería días)
  static const Duration sessionDuration = Duration(days: 7);

  /// Formato de fecha corto
  static const String dateFormatShort = 'dd/MM/yyyy';

  /// Formato de fecha largo
  static const String dateFormatLong = 'dd \'de\' MMMM \'de\' yyyy';

  /// Formato de hora
  static const String timeFormat = 'HH:mm';

  /// Formato de hora con segundos
  static const String timeFormatWithSeconds = 'HH:mm:ss';

  /// Formato de fecha y hora
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // ============================================================================
  // LIMITS (Límites de la aplicación)
  // ============================================================================

  /// Máximo de caracteres para nombre
  static const int maxNameLength = 100;

  /// Máximo de caracteres para email
  static const int maxEmailLength = 255;

  /// Mínimo de caracteres para contraseña
  static const int minPasswordLength = 6;

  /// Máximo de caracteres para contraseña
  static const int maxPasswordLength = 50;

  /// Máximo de registros por página
  static const int maxRecordsPerPage = 20;

  /// Máximo de días de historial a mostrar
  static const int maxHistoryDays = 90;

  // ============================================================================
  // CLOCKING (Configuraciones de fichaje)
  // ============================================================================

  /// Horas de trabajo estándar por día
  static const double standardWorkHours = 8.0;

  /// Minutos de break permitidos
  static const int standardBreakMinutes = 30;

  /// Minutos de tolerancia para entrada
  static const int toleranceMinutes = 15;

  /// Intervalo de actualización del reloj (segundos)
  static const Duration clockUpdateInterval = Duration(seconds: 1);

  // ============================================================================
  // UI CONSTRAINTS (Restricciones de UI)
  // ============================================================================

  /// Ancho mínimo de botón
  static const double minButtonWidth = 80.0;

  /// Ancho máximo de dialog
  static const double maxDialogWidth = 600.0;

  /// Ancho máximo de cards en desktop
  static const double maxCardWidth = 400.0;

  /// Ancho máximo del contenedor principal
  static const double maxContentWidth = 1440.0;

  /// Altura mínima de input field
  static const double minInputHeight = 48.0;

  /// Ancho mínimo de sidebar
  static const double minSidebarWidth = 240.0;

  /// Ancho máximo de sidebar
  static const double maxSidebarWidth = 320.0;

  // ============================================================================
  // Z-INDEX (Capas de apilamiento)
  // ============================================================================

  /// Base layer
  static const int zIndexBase = 0;

  /// Contenido normal
  static const int zIndexContent = 1;

  /// Headers fijos
  static const int zIndexHeader = 10;

  /// Overlays
  static const int zIndexOverlay = 100;

  /// Modals y dialogs
  static const int zIndexModal = 1000;

  /// Tooltips
  static const int zIndexTooltip = 10000;

  // ============================================================================
  // NOTIFICATIONS (Configuraciones de notificaciones)
  // ============================================================================

  /// Duración de snackbar
  static const Duration snackbarDuration = Duration(seconds: 3);

  /// Duración de snackbar de error
  static const Duration snackbarErrorDuration = Duration(seconds: 5);

  /// Duración de toast
  static const Duration toastDuration = Duration(seconds: 2);

  // ============================================================================
  // STORAGE KEYS (Claves para almacenamiento local)
  // ============================================================================

  /// Key para token de autenticación
  static const String storageKeyAuthToken = 'auth_token';

  /// Key para datos de usuario
  static const String storageKeyUserData = 'user_data';

  /// Key para preferencia de tema
  static const String storageKeyTheme = 'theme_mode';

  /// Key para idioma
  static const String storageKeyLanguage = 'language';

  /// Key para "recordarme"
  static const String storageKeyRememberMe = 'remember_me';

  // ============================================================================
  // ROLES (Roles de usuario)
  // ============================================================================

  /// Rol de empleado
  static const String roleEmployee = 'empleado';

  /// Rol de administrador
  static const String roleAdmin = 'admin';

  /// Rol de RRHH
  static const String roleHR = 'rrhh';

  // ============================================================================
  // CLOCKING TYPES (Tipos de fichaje)
  // ============================================================================

  /// Tipo: Entrada
  static const String clockingTypeEntry = 'entrada';

  /// Tipo: Salida
  static const String clockingTypeExit = 'salida';

  /// Tipo: Pausa
  static const String clockingTypePause = 'pausa';

  /// Tipo: Retorno
  static const String clockingTypeReturn = 'retorno';

  // ============================================================================
  // STATUS (Estados)
  // ============================================================================

  /// Estado: Completo
  static const String statusComplete = 'completo';

  /// Estado: Incompleto
  static const String statusIncomplete = 'incompleto';

  /// Estado: Sin fichar
  static const String statusNotClocked = 'sin_fichar';

  /// Estado: Activo
  static const String statusActive = 'activo';

  /// Estado: Inactivo
  static const String statusInactive = 'inactivo';

  // ============================================================================
  // ERRORS (Mensajes de error comunes)
  // ============================================================================

  /// Error genérico
  static const String errorGeneric =
      'Ha ocurrido un error. Por favor, intenta de nuevo.';

  /// Error de red
  static const String errorNetwork = 'Error de conexión. Verifica tu internet.';

  /// Error de autenticación
  static const String errorAuth = 'Credenciales inválidas.';

  /// Error de timeout
  static const String errorTimeout = 'La operación ha tardado demasiado.';

  /// Campo requerido
  static const String errorFieldRequired = 'Este campo es requerido.';

  /// Email inválido
  static const String errorEmailInvalid = 'Email inválido.';

  /// Contraseña corta
  static const String errorPasswordShort =
      'La contraseña debe tener al menos 6 caracteres.';

  // ============================================================================
  // SUCCESS MESSAGES (Mensajes de éxito)
  // ============================================================================

  /// Login exitoso
  static const String successLogin = '¡Bienvenido!';

  /// Logout exitoso
  static const String successLogout = 'Sesión cerrada correctamente.';

  /// Guardado exitoso
  static const String successSaved = 'Guardado correctamente.';

  /// Eliminado exitoso
  static const String successDeleted = 'Eliminado correctamente.';

  // ============================================================================
  // PLACEHOLDER TEXTS
  // ============================================================================

  /// Placeholder de búsqueda
  static const String placeholderSearch = 'Buscar...';

  /// Placeholder de email
  static const String placeholderEmail = 'tu@empresa.com';

  /// Placeholder de contraseña
  static const String placeholderPassword = '••••••••';

  /// Texto de carga
  static const String textLoading = 'Cargando...';

  /// Texto sin datos
  static const String textNoData = 'No hay datos disponibles';

  /// Texto sin resultados
  static const String textNoResults = 'No se encontraron resultados';
}
