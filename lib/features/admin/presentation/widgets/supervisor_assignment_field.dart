import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export '../../providers/supervisors_provider.dart'
    show availableSupervisorsForAssignment;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/models/user_model.dart';
import '../../providers/supervisors_provider.dart';

class SupervisorAssignmentField extends StatelessWidget {
  final AsyncValue<List<UserModel>> supervisorsAsync;
  final String? selectedSupervisorId;
  final ValueChanged<String?>? onChanged;
  final String? excludedUserId;
  final bool enabled;
  final String label;
  final String hintText;
  final String helperText;
  final String emptyText;
  final String unavailableSelectionLabel;

  const SupervisorAssignmentField({
    super.key,
    required this.supervisorsAsync,
    required this.selectedSupervisorId,
    required this.onChanged,
    required this.helperText,
    required this.emptyText,
    this.excludedUserId,
    this.enabled = true,
    this.label = 'Supervisor asignado',
    this.hintText = 'Sin asignar',
    this.unavailableSelectionLabel = 'Supervisor actual no disponible',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return supervisorsAsync.when(
      data: (supervisors) {
        final availableSupervisors = availableSupervisorsForAssignment(
          supervisors,
          excludedUserId: excludedUserId,
        );
        final hasCurrentSelection = selectedSupervisorId == null ||
            availableSupervisors.any(
              (supervisor) => supervisor.userId == selectedSupervisorId,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(selectedSupervisorId ?? '__none__'),
              isExpanded: true,
              initialValue: selectedSupervisorId,
              hint: Text(hintText),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: cs.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: cs.outline),
                ),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(hintText),
                ),
                if (!hasCurrentSelection && selectedSupervisorId != null)
                  DropdownMenuItem<String>(
                    value: selectedSupervisorId,
                    child: Text(unavailableSelectionLabel),
                  ),
                ...availableSupervisors.map((supervisor) {
                  return DropdownMenuItem<String>(
                    value: supervisor.userId,
                    child: Text(
                      supervisor.fullName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }),
              ],
              onChanged: enabled ? onChanged : null,
            ),
            AppSpacing.verticalSpaceXs,
            Text(
              availableSupervisors.isEmpty ? emptyText : helperText,
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.outline,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error),
        ),
        child: Text(
          'No se pudo cargar la lista de supervisores: $error',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
