import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/breakpoints.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../widgets/login_footer.dart';

/// Pantalla de Login
/// 
/// Permite a los usuarios iniciar sesión con email y contraseña.
/// Diseño centrado y responsivo con max-width de 400px.
/// 
/// MOCK DATA: Por ahora no valida credenciales, cualquier login funciona.
/// TODO [FASE-2]: Conectar con Firebase Authentication
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _handleLoginSuccess(BuildContext context) {
    // TODO [FASE-2]: Verificar rol del usuario y navegar según corresponda
    // final userRole = ref.read(authProvider).currentUser?.role;
    // if (userRole == 'admin') {
    //   context.go(AppRouter.admin);
    // } else {
    //   context.go(AppRouter.dashboard);
    // }

    // MOCK: Por ahora siempre ir a dashboard
    context.go(AppRouter.dashboard);
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
                      onLogin: () => _handleLoginSuccess(context),
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

