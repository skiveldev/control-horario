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
/// MOCK DATA: Por ahora no valida, solo simula el login.
class LoginForm extends StatefulWidget {
  /// Callback cuando se presiona el botón de login
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.onLogin,
  });

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
    // Validar formulario
    if (_formKey.currentState != null) {
      // Por ahora no validamos, solo simulamos el proceso
      // _formKey.currentState!.validate();
    }

    setState(() => _isLoading = true);

    // TODO [FASE-2]: Implementar lógica real de autenticación
    // try {
    //   await ref.read(authProvider).login(
    //     email: _emailController.text,
    //     password: _passwordController.text,
    //   );
    //   widget.onLogin();
    // } catch (e) {
    //   // Mostrar error
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error: ${e.toString()}')),
    //   );
    // }

    // MOCK: Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    // Llamar callback
    widget.onLogin();
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
                Text(
                  'Recordarme',
                  style: AppTextStyles.bodyMedium,
                ),

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
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}

