import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Footer del formulario de login
/// 
/// Contiene el link de registro y nota legal.
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allXxl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ¿No tienes cuenta? Regístrate
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes cuenta?',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO [FASE-2+]: Implementar registro
                  // Por ahora solo mostramos mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contacta al administrador para crear tu cuenta'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: Text(
                  'Regístrate aquí',
                  style: AppTextStyles.link,
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceMd,

          // Divider
          const Divider(height: 1),

          AppSpacing.verticalSpaceMd,

          // Nota legal
          Text(
            'Al continuar, aceptas nuestros términos de servicio y política de privacidad',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceSm,

          // Versión de la app
          Text(
            'Sistema seguro de gestión de tiempo para empleados',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

