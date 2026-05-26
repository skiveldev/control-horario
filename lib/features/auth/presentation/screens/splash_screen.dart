import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_dark.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

/// Pantalla de splash (carga inicial)
///
/// Primera pantalla que se muestra al abrir la app.
/// Muestra el logo y nombre de la app con una animación.
/// Verifica el estado de autenticación y navega al destino apropiado
/// sin demora artificial cuando ya hay una sesión activa.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.durationSlow,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      if (_hasNavigated) return;
      next.whenData((userModel) {
        _hasNavigated = true;
        if (!mounted) return;
        if (userModel == null) {
          context.go(AppRouter.login);
        } else if (userModel.role == UserRole.admin) {
          context.go(AppRouter.admin);
        } else {
          context.go(AppRouter.dashboard);
        }
      });
    });

    return _buildSplashContent();
  }

  Widget _buildSplashContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColorsDark.backgroundGradient
              : AppColors.backgroundGradient,
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
                          color: AppColors.primary.withValues(alpha: 0.3),
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
                    style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                  ),

                  AppSpacing.verticalSpaceSm,

                  // Descripción
                  Text(
                    'Sistema de Control de Tiempo',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
