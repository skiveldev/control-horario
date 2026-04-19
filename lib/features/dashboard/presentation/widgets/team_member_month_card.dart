import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/time_record_model.dart';
import '../../providers/team_provider.dart';

class TeamMemberMonthCard extends StatelessWidget {
  final TeamMemberMonthlySummary summary;
  final bool isMonthClosed;
  final Set<String> validatingRecordKeys;
  final ValueChanged<TimeRecordModel> onValidateRecord;

  const TeamMemberMonthCard({
    super.key,
    required this.summary,
    required this.isMonthClosed,
    required this.validatingRecordKeys,
    required this.onValidateRecord,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, summary.statusLabel);

    return Card(
      child: ExpansionTile(
        tilePadding: AppSpacing.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        leading: const CircleAvatar(
          child: Icon(Icons.person_outline),
        ),
        title: Text(summary.member.fullName),
        subtitle: Text(
          'Total: ${summary.totalRecords} · '
          'Validados: ${summary.validatedRecords} · '
          'Pendientes: ${summary.pendingRecords}',
        ),
        trailing: _StatusChip(
          label: summary.statusLabel,
          color: statusColor,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              summary.pendingRecordItems.isEmpty
                  ? 'No hay registros pendientes para este empleado.'
                  : 'Registros pendientes',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (summary.pendingRecordItems.isNotEmpty) ...[
            AppSpacing.verticalSpaceSm,
            ...summary.pendingRecordItems.map((record) {
              final recordKey = '${summary.member.userId}::${record.id}';
              final isValidating = validatingRecordKeys.contains(recordKey);
              final canValidate =
                  !isMonthClosed && !isValidating && !record.isBlocked;
              final actionMessage = isMonthClosed
                  ? 'El mes ya está cerrado y no admite nuevas validaciones.'
                  : record.isBlocked
                      ? 'Este registro está bloqueado por administración.'
                      : isValidating
                          ? 'Validando registro...'
                          : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: AppSpacing.allMd,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _recordTitle(record),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            AppSpacing.verticalSpaceXs,
                            Text(
                              '${record.categoryName} · ${record.startTime} - ${record.endTime}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (record.validatedAt != null) ...[
                              AppSpacing.verticalSpaceXs,
                              Text(
                                'Última validación: ${DateFormat('dd/MM/yyyy HH:mm').format(record.validatedAt!)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (actionMessage != null) ...[
                              AppSpacing.verticalSpaceXs,
                              Text(
                                actionMessage,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      AppSpacing.horizontalSpaceMd,
                      FilledButton.icon(
                        onPressed:
                            canValidate ? () => onValidateRecord(record) : null,
                        icon: isValidating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.task_alt),
                        label: Text(
                          isMonthClosed
                              ? 'Mes cerrado'
                              : record.isBlocked
                                  ? 'Bloqueado'
                                  : 'Validar',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _recordTitle(TimeRecordModel record) {
    final date = DateTime.tryParse(record.date);
    if (date == null) return record.date;
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _statusColor(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (label) {
      case 'Validado':
        return colorScheme.primary;
      case 'Pendiente':
        return colorScheme.error;
      case 'Parcial':
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
