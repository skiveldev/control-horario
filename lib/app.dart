import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// Aplicación principal del Control Horario
/// 
/// Punto de entrada de la app después de main.dart.
/// Configura el tema, router y providers globales.
class ControlHorarioApp extends ConsumerWidget {
  const ControlHorarioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // ========================================================================
      // APP CONFIG
      // ========================================================================
      title: 'Control Horario',
      debugShowCheckedModeBanner: false,
      
      // ========================================================================
      // THEME
      // ========================================================================
      theme: AppTheme.lightTheme,
      // TODO [FASE-2]: Implementar darkTheme cuando esté listo
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system, // o usar provider para persistir preferencia
      
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

