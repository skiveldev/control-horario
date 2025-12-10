import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../dashboard/presentation/widgets/records_table.dart';
import '../widgets/week_schedule_viewer.dart';

/// Pantalla de detalle de empleado (Admin)
///
/// Muestra información completa y registros de un empleado.
class EmployeeDetailScreen extends StatelessWidget {
  /// ID del empleado
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    // Buscar empleado en mock data
    final employee = MockData.employees.firstWhere(
      (e) => e['id'] == employeeId,
      orElse: () => MockData.employees.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Detalle de Empleado',
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
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
                          _getInitials(employee['name'] as String),
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
                              employee['name'] as String,
                              style: AppTextStyles.h3,
                            ),
                            AppSpacing.verticalSpaceXs,
                            Text(
                              employee['position'] as String,
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
                                Text(
                                  employee['email'] as String,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
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
                          onPressed: () {
                            // TODO [FASE-2]: Editar empleado
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edición en desarrollo'),
                              ),
                            );
                          },
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
                      _buildInfoRow('ID', employee['id'] as String),
                      _buildInfoRow(
                        'Departamento',
                        employee['department'] as String,
                      ),
                      _buildInfoRow('Estado', employee['status'] as String),
                      _buildInfoRow(
                        'Fichado hoy',
                        (employee['isClockedIn'] as bool) ? 'Sí' : 'No',
                      ),
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
                      AppSpacing.verticalSpaceLg,
                      RecordsTable(records: MockData.recentRecords),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edición en desarrollo')),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
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
            width: 120,
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
    return name.substring(0, 2).toUpperCase();
  }
}
