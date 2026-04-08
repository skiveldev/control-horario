import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../dashboard/presentation/widgets/records_table.dart';
import '../widgets/week_schedule_viewer.dart';
import '../widgets/employee_schedule_editor_modal.dart';
import '../widgets/employee_info_editor_modal.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/models/user_model.dart';
import '../../models/work_calendar_model.dart';
import '../../providers/calendar_management_provider.dart';
import '../../providers/user_management_provider.dart';

/// Pantalla de detalle de empleado (Admin)
///
/// Muestra información completa y registros de un empleado desde Firebase.
/// ✅ Conectado a Firebase via userByIdProvider
class EmployeeDetailScreen extends ConsumerWidget {
  /// ID del empleado
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener datos del empleado desde Firebase
    final employeeAsync = ref.watch(userByIdProvider(employeeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Detalle de Empleado',
        automaticallyImplyLeading: true,
      ),
      body: employeeAsync.when(
        data: (employee) {
          if (employee == null) {
            return _buildNotFound(context);
          }
          return _buildContent(context, ref, employee);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => _buildError(context, error.toString()),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, UserModel employee) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        context.responsiveValue(
          mobile: AppSpacing.lg,
          tablet: AppSpacing.xxl,
          desktop: AppSpacing.xxxl,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Header del empleado
              CustomCard(
                elevation: CardElevation.low,
                padding: AppSpacing.cardLarge,
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        _getInitials(employee.displayName),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),

                    AppSpacing.horizontalSpaceLg,

                    // Información
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.fullName,
                            style: AppTextStyles.h3,
                          ),
                          AppSpacing.verticalSpaceXs,
                          Text(
                            employee.position ?? 'Sin cargo asignado',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          AppSpacing.verticalSpaceSm,
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  employee.email,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Botones de acción
                    if (!context.isMobile) ...[
                      CustomButton(
                        text: 'Editar',
                        icon: Icons.edit,
                        variant: ButtonVariant.outline,
                        onPressed: () =>
                            _showInfoEditorModal(context, employee),
                      ),
                      AppSpacing.horizontalSpaceSm,
                      CustomButton(
                        text: 'Más',
                        icon: Icons.more_vert,
                        variant: ButtonVariant.text,
                        onPressed: () {},
                      ),
                    ],
                  ],
                ),
              ),

              AppSpacing.verticalSpaceLg,

              // Información detallada
              CustomCard(
                elevation: CardElevation.low,
                padding: AppSpacing.cardLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Información del Empleado', style: AppTextStyles.h5),
                    AppSpacing.verticalSpaceLg,
                    _buildInfoRow('ID Empleado', employee.employeeId),
                    _buildInfoRow('DNI/NIE', employee.dni ?? 'No especificado'),
                    _buildInfoRow(
                        'Teléfono', employee.telefono ?? 'No especificado'),
                    _buildInfoRow('Departamento',
                        employee.department ?? 'No especificado'),
                    _buildInfoRow(
                        'Empresa', employee.empresa ?? 'No especificado'),
                    _buildInfoRow('Rol', _formatRole(employee.role)),
                    _buildInfoRow('Horas Semanales',
                        '${employee.weeklyHours.toStringAsFixed(0)}h'),
                    _buildInfoRow(
                        'Estado', employee.isActive ? 'Activo' : 'Inactivo'),
                    if (employee.fechaInicio != null)
                      _buildInfoRow(
                        'Fecha Inicio',
                        DateFormat('dd/MM/yyyy').format(employee.fechaInicio!),
                      ),
                    _buildCalendarRow(context, ref, employee),
                  ],
                ),
              ),

              AppSpacing.verticalSpaceLg,

              // Horario Laboral
              CustomCard(
                elevation: CardElevation.low,
                padding: AppSpacing.cardLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        AppSpacing.horizontalSpaceSm,
                        Expanded(
                          child: Text(
                            'Horario Laboral',
                            style: AppTextStyles.h5,
                          ),
                        ),
                        // Botón Editar Horario
                        OutlinedButton.icon(
                          onPressed: () =>
                              _showScheduleEditorModal(context, employee),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar Horario'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalSpaceLg,
                    WeekScheduleViewer(employeeId: employeeId),
                  ],
                ),
              ),

              AppSpacing.verticalSpaceLg,

              // Registros recientes
              CustomCard(
                elevation: CardElevation.low,
                padding: AppSpacing.cardLarge,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Registros Recientes', style: AppTextStyles.h5),
                    AppSpacing.verticalSpaceSm,
                    Text(
                      'Próximamente: Registros de fichajes',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    // TODO: Conectar con provider de registros
                    // AppSpacing.verticalSpaceLg,
                    // RecordsTable(userId: employeeId),
                  ],
                ),
              ),

              // Botones de acción (mobile)
              if (context.isMobile) ...[
                AppSpacing.verticalSpaceLg,
                CustomButton(
                  text: 'Editar Empleado',
                  icon: Icons.edit,
                  variant: ButtonVariant.primary,
                  fullWidth: true,
                  onPressed: () => _showInfoEditorModal(context, employee),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          AppSpacing.verticalSpaceLg,
          Text(
            'Empleado no encontrado',
            style: AppTextStyles.h4,
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            'El empleado con ID $employeeId no existe',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          AppSpacing.verticalSpaceLg,
          Text(
            'Error al cargar empleado',
            style: AppTextStyles.h4,
          ),
          AppSpacing.verticalSpaceSm,
          Padding(
            padding: AppSpacing.horizontalXl,
            child: Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: AppSpacing.verticalSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  String _formatRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.rrhh:
        return 'Recursos Humanos';
      case UserRole.employee:
        return 'Empleado';
    }
  }

  /// Mostrar modal de edición de horario
  void _showScheduleEditorModal(BuildContext context, UserModel employee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmployeeScheduleEditorModal(
        employee: employee,
      ),
    );
  }

  /// Mostrar modal de edición de información general
  void _showInfoEditorModal(BuildContext context, UserModel employee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmployeeInfoEditorModal(
        employee: employee,
      ),
    );
  }

  /// Fila de calendario con nombre resuelto y botón "Cambiar"
  Widget _buildCalendarRow(
    BuildContext context,
    WidgetRef ref,
    UserModel employee,
  ) {
    return Padding(
      padding: AppSpacing.verticalSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              'Calendario',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: employee.calendarId != null
                ? Consumer(
                    builder: (context, ref, _) {
                      final calendarAsync = ref.watch(
                        calendarByIdProvider(employee.calendarId!),
                      );
                      return calendarAsync.when(
                        data: (calendar) => Text(
                          calendar?.name ?? 'Calendario no encontrado',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        loading: () => const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => Text(
                          'Error al cargar',
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    },
                  )
                : Text(
                    'Sin asignar',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
          TextButton.icon(
            onPressed: () => _showCalendarChangeDialog(context, ref, employee),
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Cambiar'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  /// Diálogo para cambiar el calendario asignado al empleado
  Future<void> _showCalendarChangeDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel employee,
  ) async {
    // Obtener lista de calendarios una sola vez para el diálogo
    List<WorkCalendarModel> calendars = [];
    try {
      calendars = await ref.read(allCalendarsProvider.future);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar calendarios')),
        );
      }
      return;
    }

    if (!context.mounted) return;

    String? selectedCalendarId = employee.calendarId;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Cambiar Calendario'),
            content: SizedBox(
              width: 320,
              child: DropdownButtonFormField<String>(
                key: ValueKey(selectedCalendarId),
                isExpanded: true,
                initialValue: selectedCalendarId,
                hint: const Text('Sin asignar'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Sin asignar'),
                  ),
                  ...calendars.map((calendar) {
                    return DropdownMenuItem(
                      value: calendar.id,
                      child: Text(
                        '${calendar.name} (${calendar.year})',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setDialogState(() => selectedCalendarId = value);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await ref
                        .read(userManagementProvider.notifier)
                        .updateEmployee(
                      userId: employee.userId,
                      updates: {
                        'calendarId': selectedCalendarId,
                      },
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calendario actualizado'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
