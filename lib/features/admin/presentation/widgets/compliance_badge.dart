import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../dashboard/services/compliance_service.dart';

/// Badge de cumplimiento horario.
///
/// Muestra el estado de cumplimiento de un día con un indicador visual
/// coloreado: verde para compliant, ámbar para deviated, rojo para noRecord.
///
/// Ejemplo:
/// ```dart
/// const ComplianceBadge(status: ComplianceStatus.compliant)
/// ```
class ComplianceBadge extends StatelessWidget {
  /// Estado de cumplimiento a mostrar
  final ComplianceStatus status;

  const ComplianceBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusXs,
        border: Border.all(
          color: _backgroundColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: AppSpacing.iconXs, color: _backgroundColor),
          AppSpacing.horizontalSpaceXs,
          Text(
            _label,
            style: AppTextStyles.labelSmall.copyWith(
              color: _backgroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case ComplianceStatus.compliant:
        return AppColors.success;
      case ComplianceStatus.deviated:
        return AppColors.warning;
      case ComplianceStatus.noRecord:
        return AppColors.error;
    }
  }

  IconData get _icon {
    switch (status) {
      case ComplianceStatus.compliant:
        return Icons.check_circle;
      case ComplianceStatus.deviated:
        return Icons.warning_amber;
      case ComplianceStatus.noRecord:
        return Icons.remove_circle;
    }
  }

  String get _label {
    switch (status) {
      case ComplianceStatus.compliant:
        return 'Cumple';
      case ComplianceStatus.deviated:
        return 'Desviado';
      case ComplianceStatus.noRecord:
        return 'Sin datos';
    }
  }
}
