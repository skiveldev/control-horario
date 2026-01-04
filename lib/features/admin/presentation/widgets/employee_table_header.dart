import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';

/// Header de tabla de empleados
///
/// Muestra las columnas: NOMBRE Y PERFIL | DEPARTAMENTO | EMPRESA | ESTADO | ÚLTIMO FICHAJE
/// Diseñado para responsive, ocultando columnas en pantallas pequeñas.
///
/// Ejemplo:
/// ```dart
/// EmployeeTableHeader()
/// ```
class EmployeeTableHeader extends StatelessWidget {
  const EmployeeTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // NOMBRE Y PERFIL (40% en desktop, 50% en tablet)
          Expanded(
            flex: isDesktop ? 40 : 50,
            child: Text(
              'NOMBRE Y PERFIL',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // DEPARTAMENTO (20%)
          Expanded(
            flex: 20,
            child: Text(
              'DEPARTAMENTO',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // EMPRESA (15% - solo desktop)
          if (isDesktop)
            Expanded(
              flex: 15,
              child: Text(
                'EMPRESA',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),

          // ESTADO (15%)
          Expanded(
            flex: 15,
            child: Text(
              'ESTADO',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // ÚLTIMO FICHAJE (15% en desktop, 15% en tablet)
          Expanded(
            flex: 15,
            child: Text(
              'ÚLTIMO FICHAJE',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // Espacio para el icono de flecha
          SizedBox(width: AppSpacing.iconMd + AppSpacing.sm),
        ],
      ),
    );
  }
}
