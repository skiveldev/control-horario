import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_provider.dart';

/// Aplicación principal del Control Horario
/// 
/// Punto de entrada de la app después de main.dart.
/// Configura el tema, router y providers globales.
class ControlHorarioApp extends ConsumerWidget {
  const ControlHorarioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar el modo de tema actual
    final themeMode = ref.watch(themeNotifierProvider);
    
    return MaterialApp.router(
      // ========================================================================
      // APP CONFIG
      // ========================================================================
      title: 'Control Horario',
      debugShowCheckedModeBanner: false,
      
      // ========================================================================
      // THEME - Dual Theme System
      // ========================================================================
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      
      // ========================================================================
      // ROUTER
      // ========================================================================
      routerConfig: AppRouter.router,
      
      // ========================================================================
      // LOCALIZATION (Futuro)
      // ========================================================================
      // TODO [FASE-2+]: Configurar localizaciones cuando se implementen
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('es', 'ES'), // Español
      //   Locale('en', 'US'), // Inglés
      // ],
    );
  }
}

