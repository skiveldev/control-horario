import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';

/// Pantalla de configuración del sistema (admin)
///
/// Placeholder honesto: la funcionalidad real de configuración del sistema
/// (parámetros globales, políticas de fichaje, etc.) se implementará en
/// una fase futura.
class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Configuración del sistema',
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings_suggest_outlined,
                size: 64,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              AppSpacing.verticalSpaceLg,
              Text(
                'Configuración del sistema',
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Coming soon',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceMd,
              Text(
                'Aquí podrás configurar parámetros globales del sistema,\npolíticas de fichaje, días festivos y más.',
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
