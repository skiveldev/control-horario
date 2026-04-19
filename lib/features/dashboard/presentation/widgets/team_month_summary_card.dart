import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/team_provider.dart';

class TeamMonthSummaryCard extends StatelessWidget {
  final TeamMonthlyOverview overview;
  final bool isClosed;

  const TeamMonthSummaryCard({
    super.key,
    required this.overview,
    required this.isClosed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isClosed ? Icons.verified : Icons.groups_2_outlined,
                  color: isClosed ? colorScheme.primary : colorScheme.secondary,
                ),
                AppSpacing.horizontalSpaceSm,
                Expanded(
                  child: Text(
                    'Resumen del equipo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  avatar: Icon(
                    isClosed ? Icons.lock : Icons.schedule,
                    size: 16,
                    color: isClosed
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  label: Text(isClosed ? 'Mes cerrado' : 'Mes abierto'),
                ),
              ],
            ),
            AppSpacing.verticalSpaceMd,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                _MetricTile(
                  label: 'Miembros',
                  value: overview.membersCount.toString(),
                  icon: Icons.people_outline,
                ),
                _MetricTile(
                  label: 'Registros del mes',
                  value: overview.totalRecords.toString(),
                  icon: Icons.event_note_outlined,
                ),
                _MetricTile(
                  label: 'Validados',
                  value: overview.validatedRecords.toString(),
                  icon: Icons.task_alt,
                  iconColor: colorScheme.primary,
                ),
                _MetricTile(
                  label: 'Pendientes',
                  value: overview.pendingRecords.toString(),
                  icon: Icons.pending_actions,
                  iconColor: colorScheme.error,
                ),
                _MetricTile(
                  label: 'Miembros con pendientes',
                  value: overview.membersWithPending.toString(),
                  icon: Icons.assignment_late_outlined,
                  iconColor: colorScheme.tertiary,
                ),
                _MetricTile(
                  label: 'Sin registros',
                  value: overview.membersWithoutRecords.toString(),
                  icon: Icons.person_off_outlined,
                  iconColor: colorScheme.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
          AppSpacing.horizontalSpaceSm,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
