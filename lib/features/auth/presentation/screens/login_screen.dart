import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../widgets/login_footer.dart';

/// Pantalla de Login
///
/// Permite a los usuarios iniciar sesión con email y contraseña.
/// Diseño centrado y responsivo con max-width de 400px.
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
          // Redirigir según el rol del usuario
          switch (user.role) {
            case UserRole.admin:
            case UserRole.rrhh:
              context.go(AppRouter.admin);
              break;
            case UserRole.employee:
              context.go(AppRouter.dashboard);
              break;
          }
        }
      });
    });

    // Observar el estado del AuthNotifier para mostrar errores
    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          // Mostrar error en snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        // Gradiente sutil de fondo
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.isMobile ? AppSpacing.lg : AppSpacing.xxl,
              vertical: AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400, // Ancho máximo del card de login
              ),
              child: Card(
                elevation: AppSpacing.xs,
                shadowColor: AppColors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header con gradiente
                    const LoginHeader(),

                    // Formulario
                    LoginForm(
                      onLogin: (email, password) async {
                        // Llamar a AuthNotifier para autenticar
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
            ),
          ),
        ),
      ),
    );
  }
}
