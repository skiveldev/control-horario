import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../widgets/login_footer.dart';
import '../widgets/login_info_panel.dart';

/// Pantalla de Login
///
/// Permite a los usuarios iniciar sesión con email y contraseña.
/// Diseño responsivo con panel lateral en desktop.
///
/// Usa Firebase Authentication + Riverpod para el estado.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar cambios en el usuario actual (con datos completos)
    ref.listen(currentUserProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Esperar un frame para asegurar que el contexto es válido
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // TODO: Move to router redirect — el router debería manejar la
              // redirección por rol desde un redirect centralizado.
              final targetRoute =
                  (user.role == UserRole.admin || user.role == UserRole.rrhh)
                      ? AppRouter.admin
                      : AppRouter.dashboard;

              context.go(targetRoute);
            }
          });
        }
      });
    });

    // Observar el estado del AuthNotifier para mostrar errores de login
    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          // Mostrar error en snackbar
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error de autenticación: ${error.toString()}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.surface,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= Breakpoints.desktop;

            if (isDesktop) {
              // Layout desktop: Panel lateral + Formulario
              return Row(
                children: [
                  // Panel lateral informativo (50% del ancho)
                  Expanded(
                    flex: 1,
                    child: const LoginInfoPanel(),
                  ),

                  // Formulario de login (50% del ancho)
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.huge,
                          vertical: AppSpacing.xxl,
                        ),
                        child: _buildLoginCard(context, ref),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Layout móvil/tablet: Solo formulario centrado
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? AppSpacing.lg : AppSpacing.xxl,
                  vertical: AppSpacing.xxl,
                ),
                child: _buildLoginCard(context, ref),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Construye el card de login con diseño limpio
  Widget _buildLoginCard(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 480,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con gradiente
            const LoginHeader(),

            // Sección de bienvenida
            Padding(
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.xxxl,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  // Título de bienvenida
                  Text(
                    'Bienvenido de nuevo',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalSpaceSm,

                  // Descripción
                  Text(
                    'Inicia sesión para acceder a tu panel de control',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Formulario
            LoginForm(
              onLogin: (email, password) async {
                await ref
                    .read(authNotifierProvider.notifier)
                    .signIn(email, password);
              },
            ),

            // Footer con links
            const LoginFooter(),
          ],
        ),
      ),
    );
  }
}
