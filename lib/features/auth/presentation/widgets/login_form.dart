import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/inputs/custom_password_field.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';

/// Formulario de login
///
/// Contiene los campos de email, contraseña, checkbox de "Recordarme"
/// y botón de iniciar sesión.
///
/// Callback pasa email y password para que el padre maneje la autenticación.
class LoginForm extends StatefulWidget {
  /// Callback cuando se presiona el botón de login
  /// Recibe email y password como parámetros
  final Future<void> Function(String email, String password) onLogin;

  const LoginForm({super.key, required this.onLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validar formulario básico
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa email y contraseña')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Llamar al callback con email y password
      await widget.onLogin(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      // Mostrar error si falla la autenticación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: AppSpacing.allXxl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email
            CustomTextField(
              controller: _emailController,
              label: 'Correo electrónico',
              hintText: 'tu@empresa.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),

            AppSpacing.verticalSpaceLg,

            // Contraseña
            CustomPasswordField(
              controller: _passwordController,
              label: 'Contraseña',
              enabled: !_isLoading,
              onSubmitted: (_) => _handleLogin(),
            ),

            AppSpacing.verticalSpaceMd,

            // Fila: Recordarme + ¿Olvidaste contraseña?
            Row(
              children: [
                // Checkbox Recordarme
                Checkbox(
                  value: _rememberMe,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() => _rememberMe = value ?? false);
                        },
                ),
                Text('Recordarme', style: AppTextStyles.bodyMedium),

                const Spacer(),

                // Link ¿Olvidaste contraseña?
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // TODO [FASE-2]: Implementar recuperación de contraseña
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidad en desarrollo'),
                            ),
                          );
                        },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: AppTextStyles.linkSmall,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalSpaceXxl,

            // Botón Iniciar Sesión
            CustomButton(
              text: 'Iniciar sesión',
              icon: Icons.login,
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
              fullWidth: true,
              variant: ButtonVariant
                  .brand, // Gradiente azul-violeta coherente con header
            ),
          ],
        ),
      ),
    );
  }
}
