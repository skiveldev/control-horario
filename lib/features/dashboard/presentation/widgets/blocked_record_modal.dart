import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../models/time_record_model.dart';

/// Modal informativo para registros bloqueados
///
/// Se muestra cuando un empleado intenta editar un registro
/// que ha sido bloqueado por un administrador.
///
/// Información mostrada:
/// - Quién bloqueó el registro
/// - Cuándo se bloqueó
/// - Motivo del bloqueo
/// - Detalles del registro
class BlockedRecordModal extends StatelessWidget {
  final TimeRecordModel record;
  final String? blockedByName; // Nombre del admin que bloqueó

  const BlockedRecordModal({
    super.key,
    required this.record,
    this.blockedByName,
  });

  static Future<void> show(
    BuildContext context, {
    required TimeRecordModel record,
    String? blockedByName,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BlockedRecordModal(
        record: record,
        blockedByName: blockedByName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = context.isMobile;

    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono y título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: AppSpacing.iconXl,
                    color: AppColors.error,
                  ),
                ),
                AppSpacing.horizontalSpaceMd,
                Expanded(
                  child: Text(
                    'Registro Bloqueado',
                    style: isMobile ? AppTextStyles.h4 : AppTextStyles.h3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar',
                ),
              ],
            ),

            AppSpacing.verticalSpaceLg,

            // Mensaje principal
            Container(
              padding: AppSpacing.allMd,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.block,
                    size: AppSpacing.iconMd,
                    color: AppColors.error,
                  ),
                  AppSpacing.horizontalSpaceMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No puedes editar este registro',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verticalSpaceXs,
                        Text(
                          'Este registro fue bloqueado por un administrador.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.verticalSpaceLg,

            // Información del bloqueo
            _buildInfoSection(
              cs,
              title: 'Información del bloqueo',
              items: [
                if (blockedByName != null)
                  _InfoItem(
                    label: 'Bloqueado por',
                    value: blockedByName!,
                    icon: Icons.person_outline,
                  ),
                if (record.blockedAt != null)
                  _InfoItem(
                    label: 'Fecha de bloqueo',
                    value: DateFormat('dd/MM/yyyy - HH:mm', 'es_ES')
                        .format(record.blockedAt!),
                    icon: Icons.calendar_today_outlined,
                  ),
                if (record.blockReason != null &&
                    record.blockReason!.isNotEmpty)
                  _InfoItem(
                    label: 'Motivo',
                    value: record.blockReason!,
                    icon: Icons.info_outline,
                  ),
              ],
            ),

            AppSpacing.verticalSpaceLg,

            // Detalles del registro
            _buildInfoSection(
              cs,
              title: 'Detalles del registro',
              items: [
                _InfoItem(
                  label: 'Tipo',
                  value: record.categoryName,
                  icon: record.category == RecordCategory.work
                      ? Icons.work_outline
                      : Icons.coffee_outlined,
                ),
                _InfoItem(
                  label: 'Horario',
                  value:
                      '${record.startTime} - ${record.endTime} (${(record.durationMinutes / 60).toStringAsFixed(1)}h)',
                  icon: Icons.access_time,
                ),
                _InfoItem(
                  label: 'Ubicación',
                  value: record.location,
                  icon: Icons.place_outlined,
                ),
              ],
            ),

            AppSpacing.verticalSpaceLg,

            // Mensaje de ayuda
            Text(
              'Si necesitas modificar este registro, contacta con tu supervisor o el departamento de RRHH.',
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),

            AppSpacing.verticalSpaceLg,

            // Botón entendido
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    ColorScheme cs, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.verticalSpaceSm,
        Container(
          padding: AppSpacing.allMd,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            children: items.map((item) => item).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppSpacing.iconMd,
            color: cs.onSurfaceVariant,
          ),
          AppSpacing.horizontalSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                AppSpacing.verticalSpaceXs,
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
