import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_spacing.dart';

class TeamScreenHeader extends StatelessWidget {
  final bool isMobile;
  final DateTime selectedMonth;
  final bool isClosed;
  final int pendingCount;
  final VoidCallback onCloseMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const TeamScreenHeader({
    super.key,
    required this.isMobile,
    required this.selectedMonth,
    required this.isClosed,
    required this.pendingCount,
    required this.onCloseMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (isMobile) ...[
              Builder(
                builder: (scaffoldContext) => IconButton(
                  onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                  icon: const Icon(Icons.menu),
                  tooltip: 'Abrir menu',
                ),
              ),
              AppSpacing.horizontalSpaceSm,
            ],
            Expanded(
              child: Text(
                'Equipo',
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 8,
                children: [
                  IconButton(
                    onPressed: onPreviousMonth,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Mes anterior',
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 120 : 160,
                    ),
                    child: Text(
                      _formatMonthLabel(selectedMonth),
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: onNextMonth,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Mes siguiente',
                  ),
                  FilledButton.icon(
                    onPressed: isClosed ? null : onCloseMonth,
                    icon: Icon(isClosed ? Icons.lock : Icons.task_alt),
                    label: Text(
                      isMobile
                          ? isClosed
                              ? 'Cerrado'
                              : 'Cerrar'
                          : isClosed
                              ? 'Mes cerrado'
                              : pendingCount > 0
                                  ? 'Cerrar mes ($pendingCount pendientes)'
                                  : 'Cerrar mes',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonthLabel(DateTime month) {
    try {
      return DateFormat('MMMM yyyy', 'es_ES').format(month);
    } catch (_) {
      return DateFormat('MMMM yyyy').format(month);
    }
  }
}
