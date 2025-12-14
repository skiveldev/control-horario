import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'app.dart';

/// Punto de entrada de la aplicación Control Horario
///
/// Configura:
/// - WidgetsFlutterBinding
/// - SharedPreferences (theme persistence)
/// - Firebase
/// - Firebase Emulator (solo en debug mode)
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
  await SharedPreferences.getInstance(); // Pre-cache para mejor performance

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

    debugPrint('🔧 Modo DEBUG: Emuladores deshabilitados');
    debugPrint('   Para habilitar, descomentar líneas en main.dart');
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
    // ProviderScope de Riverpod para state management global
    const ProviderScope(child: ControlHorarioApp()),
  );
}
