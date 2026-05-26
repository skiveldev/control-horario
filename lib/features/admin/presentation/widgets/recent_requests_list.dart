import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';

/// Lista de solicitudes recientes para dashboard admin
///
/// Muestra las últimas solicitudes pendientes de los empleados.
/// FASE 1: Datos mock estáticos.
///
/// Ejemplo:
/// ```dart
/// RecentRequestsList(
///   requests: [
///     {'name': 'Usuario 1', 'type': 'Solicitud de vacaciones', 'status': 'Pendiente'},
///   ],
/// )
/// ```
class RecentRequestsList extends StatelessWidget {
  /// Lista de solicitudes a mostrar
  final List<Map<String, String>> requests;

  const RecentRequestsList({
    super.key,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Últimas Solicitudes',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          AppSpacing.verticalSpaceLg,

          // Lista de solicitudes o estado vacío
          if (requests.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 40,
                      color: cs.outline.withValues(alpha: 0.5),
                    ),
                    AppSpacing.verticalSpaceMd,
                    Text(
                      'No hay solicitudes pendientes',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...requests.asMap().entries.map((entry) {
              final index = entry.key;
              final request = entry.value;
              final isLast = index == requests.length - 1;

              return Column(
                children: [
                  _RequestItem(
                    cs: cs,
                    name: request['name'] ?? '',
                    type: request['type'] ?? '',
                    status: request['status'] ?? 'Pendiente',
                    initial: request['name']?[0] ?? 'U',
                  ),
                  if (!isLast) AppSpacing.verticalSpaceMd,
                ],
              );
            }),
        ],
      ),
    );
  }
}

/// Item individual de solicitud
class _RequestItem extends StatelessWidget {
  final ColorScheme cs;
  final String name;
  final String type;
  final String status;
  final String initial;

  const _RequestItem({
    required this.cs,
    required this.name,
    required this.type,
    required this.status,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO [FASE-2]: Navegar a detalle de solicitud
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ver detalle de solicitud: $name'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: AppSpacing.borderRadiusSm,
      child: Padding(
        padding: AppSpacing.allSm,
        child: Row(
          children: [
            // Avatar con inicial
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                initial.toUpperCase(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            AppSpacing.horizontalSpaceMd,

            // Información de la solicitud
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalSpaceXs,
                  Text(
                    type,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            AppSpacing.horizontalSpaceSm,

            // Badge de estado
            Container(
              padding: AppSpacing.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(cs, status).withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusXs,
              ),
              child: Text(
                status,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _getStatusColor(cs, status),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ColorScheme cs, String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return AppColors.info;
      case 'aprobado':
        return AppColors.success;
      case 'rechazado':
        return AppColors.error;
      default:
        return cs.onSurfaceVariant;
    }
  }
}
