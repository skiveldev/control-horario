import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../admin/presentation/widgets/week_schedule_viewer.dart';

/// Sección "Mi Horario" para la pantalla de calendario del empleado
///
/// Muestra el horario semanal del empleado en modo solo lectura.
///
/// Ejemplo de uso:
/// ```dart
/// ScheduleSummarySection(employeeId: user.userId)
/// ```
class ScheduleSummarySection extends ConsumerWidget {
  final String employeeId;

  const ScheduleSummarySection({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            AppSpacing.horizontalSpaceSm,
            Flexible(
              child: Text(
                'Mi Horario',
                style: AppTextStyles.h4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMd,
        WeekScheduleViewer(employeeId: employeeId, isReadOnly: true),
      ],
    );
  }
}
