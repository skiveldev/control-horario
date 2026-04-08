import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/providers/theme_provider.dart';

/// Punto de entrada de la aplicación Control Horario
///
/// Configura:
/// - WidgetsFlutterBinding
/// - SharedPreferences (theme persistence)
/// - Firebase
/// - Firebase Emulator (solo en debug mode)
/// - Google Fonts (pre-carga)
/// - Orientación de pantalla
/// - Status bar / System UI
/// - Providers globales (Riverpod)
void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================================
  // INICIALIZAR LOCALIZACIÓN (intl)
  // ============================================================================
  await initializeDateFormatting('es_ES', null);

  // ============================================================================
  // INICIALIZAR SHARED PREFERENCES (para persistencia de tema)
  // ============================================================================
  final prefs = await SharedPreferences.getInstance();

  // ============================================================================
  // PRE-CARGAR GOOGLE FONTS
  // ============================================================================
  // Esto descarga la fuente Inter antes de mostrar la UI
  // Evita el "salto" visual cuando la fuente se carga después
  try {
    await _preloadGoogleFonts();
  } catch (e) {
    // Si falla la carga de fuentes, continuar con fuente de respaldo
    if (kDebugMode) {
      print('⚠️ Error al pre-cargar Google Fonts: $e');
    }
  }

  // ============================================================================
  // INICIALIZAR FIREBASE
  // ============================================================================
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ============================================================================
  // CONFIGURAR EMULATOR EN DEBUG MODE
  // ============================================================================
  if (kDebugMode) {
    // Descomentar las siguientes líneas para usar el emulator local
    // NOTA: Ejecutar primero `firebase emulators:start`

    // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  // ============================================================================
  // CONFIGURACIÓN DE ORIENTACIÓN
  // ============================================================================
  // Por ahora solo portrait para mobile, en web/tablet se permite todo
  // TODO [FASE-4]: Ajustar orientaciones para app móvil
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ============================================================================
  // CONFIGURACIÓN DE SYSTEM UI (Status Bar, Navigation Bar)
  // ============================================================================
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ============================================================================
  // INICIALIZAR APP CON RIVERPOD
  // ============================================================================
  runApp(
    // ProviderScope de Riverpod para state management global.
    // Se inyecta la instancia pre-inicializada de SharedPreferences para que
    // ThemeNotifier pueda leer el tema guardado de forma síncrona (sin flash).
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ControlHorarioApp(),
    ),
  );
}

/// Pre-carga las fuentes de Google Fonts utilizadas en la app
///
/// Esto descarga la fuente Inter en todos los pesos necesarios
/// antes de mostrar cualquier contenido, evitando el cambio visual
/// cuando la fuente se carga de forma asíncrona.
Future<void> _preloadGoogleFonts() async {
  // Lista de todos los pesos de Inter que usamos en la app
  // según app_text_styles.dart
  final fontsToLoad = [
    GoogleFonts.inter(fontWeight: FontWeight.w400), // Regular - Body text
    GoogleFonts.inter(fontWeight: FontWeight.w500), // Medium - Labels
    GoogleFonts.inter(fontWeight: FontWeight.w600), // SemiBold - Headings
    GoogleFonts.inter(
        fontWeight: FontWeight.w700), // Bold - Títulos principales
  ];

  // Forzar la carga de todas las fuentes
  final futures = fontsToLoad.map((font) {
    return Future.value(font.fontFamily);
  }).toList();

  await Future.wait(futures);

  // Esperar a que todas las fuentes pendientes se descarguen
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(fontWeight: FontWeight.w400),
    GoogleFonts.inter(fontWeight: FontWeight.w500),
    GoogleFonts.inter(fontWeight: FontWeight.w600),
    GoogleFonts.inter(fontWeight: FontWeight.w700),
  ]);
}
