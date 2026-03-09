import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Header del formulario de login
///
/// Contiene el gradiente de marca y branding Time Rega.
/// Parte visual superior de la pantalla de login.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.symmetric(
        vertical: AppSpacing.huge,
        horizontal: AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono de reloj con fondo circular (más grande)
          Container(
            padding: AppSpacing.allLg,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time,
              size: 64, // Aumentado de 48 a 64px (+33%)
              color: AppColors.textOnPrimary,
            ),
          ),

          AppSpacing.verticalSpaceMd,

          // Título principal: Time Rega (más grande)
          Text(
            'Time Rega',
            style: AppTextStyles.h1.copyWith(
              // Cambiado de h2 a h1
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceXs,

          // Subtítulo: Sistema de control horario (más grande)
          Text(
            'Sistema de control horario',
            style: AppTextStyles.bodyLarge.copyWith(
              // Cambiado de bodyMedium a bodyLarge
              color: AppColors.textOnPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
