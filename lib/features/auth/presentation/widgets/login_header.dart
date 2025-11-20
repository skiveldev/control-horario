import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Header del formulario de login
/// 
/// Contiene el gradiente de marca, ícono de reloj y título.
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
          topLeft: Radius.circular(AppSpacing.radiusLg),
          topRight: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícono de reloj con fondo circular
          Container(
            padding: AppSpacing.allLg,
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time,
              size: 48,
              color: AppColors.textOnPrimary,
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // Título
          Text(
            'Sistema de Control de Tiempo',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textOnPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          AppSpacing.verticalSpaceXs,

          // Subtítulo
          Text(
            'Inicia sesión para gestionar tu tiempo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

