import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Footer del formulario de login
///
/// Contiene la nota legal y copyright.
/// Solo administradores pueden registrar nuevos usuarios.
class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.allXxl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

          // Copyright y seguridad
          Text(
            'Sistema seguro • © 2026 Time Rega',
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
