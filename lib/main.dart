import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

/// Punto de entrada de la aplicación Control Horario
/// 
/// Configura:
/// - WidgetsFlutterBinding
/// - Orientación de pantalla
/// - Status bar / System UI
/// - Providers globales (Riverpod)
void main() async {
  // Asegurar inicialización de Flutter
  WidgetsFlutterBinding.ensureInitialized();

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
    const ProviderScope(
      child: ControlHorarioApp(),
    ),
  );
}
