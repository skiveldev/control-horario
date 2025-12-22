import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Badge que muestra el estado del horario laboral del empleado
///
/// Estados posibles:
/// - **En horario**: El empleado está dentro de su horario laboral
/// - **Fuera de horario**: El empleado está fuera de su horario laboral
///
/// Características:
/// - Color adaptativo según tema (light/dark)
/// - Incluye fecha formateada
/// - Estilo consistente con el sistema de diseño
///
/// Ejemplo:
/// ```dart
/// WorkScheduleStatusBadge(
///   isInWorkSchedule: true,
///   currentDate: 'Lunes, 8 de Diciembre de 2025',
/// )
/// ```
class WorkScheduleStatusBadge extends StatelessWidget {
  /// Si el empleado está dentro de su horario laboral
  final bool isInWorkSchedule;

  /// Fecha actual formateada
  final String currentDate;

  const WorkScheduleStatusBadge({
    super.key,
    required this.isInWorkSchedule,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores según estado y tema
    final backgroundColor = isInWorkSchedule
        ? (isDark
            ? const Color(0xFF10B981).withValues(alpha: 0.15) // Verde oscuro
            : const Color(0xFFD1FAE5)) // Verde claro
        : (isDark
            ? const Color(0xFFF59E0B).withValues(alpha: 0.15) // Amber oscuro
            : const Color(0xFFFEF3C7)); // Amber claro

    final textColor = isInWorkSchedule
        ? (isDark
            ? const Color(0xFF34D399) // Verde brillante
            : const Color(0xFF065F46)) // Verde oscuro
        : (isDark
            ? const Color(0xFFFBBF24) // Amber brillante
            : const Color(0xFF92400E)); // Amber oscuro

    final statusText = isInWorkSchedule ? 'En horario' : 'Fuera de horario';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el espacio es muy reducido, ajustar padding
        final isCompact = constraints.maxWidth < 300;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de estado (punto)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: textColor,
                  shape: BoxShape.circle,
                ),
              ),

              SizedBox(width: isCompact ? 4 : AppSpacing.xs),

              // Texto de estado
              Text(
                statusText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize:
                      isCompact ? 11 : null, // Reducir tamaño si es compacto
                ),
              ),

              // Separador
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 4 : AppSpacing.xs),
                child: Text(
                  '•',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Fecha - ENVUELTO EN FLEXIBLE para prevenir overflow
              Flexible(
                child: Text(
                  currentDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    fontSize:
                        isCompact ? 11 : null, // Reducir tamaño si es compacto
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
