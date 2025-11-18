import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';

/// Pantalla de splash (carga inicial)
/// 
/// Primera pantalla que se muestra al abrir la app.
/// Muestra el logo y nombre de la app con una animación.
/// Después de 2 segundos navega a Login.
/// 
/// TODO [FASE-2]: Agregar lógica para verificar sesión activa
/// Si hay sesión activa, ir a Dashboard directamente.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToLogin();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.durationSlow,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  Future<void> _navigateToLogin() async {
    // TODO [FASE-2]: Verificar si hay sesión activa
    // final hasSession = await ref.read(authProvider).checkSession();
    // if (hasSession) {
    //   context.go(AppRouter.dashboard);
    // } else {
    //   context.go(AppRouter.login);
    // }

    // Por ahora, siempre ir a login después de 2 segundos
    await Future.delayed(AppConstants.splashDuration);
    
    if (mounted) {
      context.go(AppRouter.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        // Gradiente sutil de fondo
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (ícono de reloj)
                  Container(
                    padding: AppSpacing.allXxl,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.access_time,
                      size: 80,
                      color: AppColors.textOnPrimary,
                    ),
                  ),

                  AppSpacing.verticalSpaceXxl,

                  // Nombre de la app
                  Text(
                    AppConstants.appName,
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  AppSpacing.verticalSpaceSm,

                  // Descripción
                  Text(
                    'Sistema de Control de Tiempo',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  AppSpacing.verticalSpaceHuge,

                  // Loading indicator
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

