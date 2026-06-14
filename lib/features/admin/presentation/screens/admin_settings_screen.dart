import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';

/// Pantalla de configuración del sistema (admin)
///
/// Placeholder honesto: la funcionalidad real de configuración del sistema
/// (parámetros globales, políticas de fichaje, etc.) se implementará en
/// una fase futura. Por ahora muestra un estado intencional de "Próximamente".
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AdminLayout(
      currentRoute: AppRouter.adminSettings,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono decorativo con círculo sutil
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings_suggest_outlined,
                    size: 56,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                AppSpacing.verticalSpaceXl,

                // Título
                Text(
                  'Configuración del sistema',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalSpaceMd,

                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusCircular),
                  ),
                  child: Text(
                    'Próximamente',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.verticalSpaceXl,

                // Descripción
                Text(
                  'Aquí podrás configurar parámetros globales del sistema,\n'
                  'políticas de fichaje, días festivos y más.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
