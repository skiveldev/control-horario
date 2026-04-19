import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/team_provider.dart';

class TeamPendingBreakdownCard extends StatelessWidget {
  final List<TeamPendingBreakdownItem> items;

  const TeamPendingBreakdownCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: AppSpacing.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                AppSpacing.horizontalSpaceSm,
                Expanded(
                  child: Text(
                    'Pendientes antes de cerrar mes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceSm,
            Text(
              'El cierre mensual seguirá bloqueado mientras existan registros sin validar.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            AppSpacing.verticalSpaceXs,
            Text(
              '${items.length} empleado(s) con pendientes',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
            AppSpacing.verticalSpaceMd,
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(item.member.fullName)),
                    Text(
                      '${item.pendingRecords} pendiente(s)',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.error,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
