import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../widgets/employee_list_item.dart';
import '../widgets/new_employee_drawer.dart';
import '../../providers/admin_provider.dart';

/// Pantalla de lista de empleados
///
/// Muestra todos los empleados con búsqueda y filtros.
///
/// DÍA 4 - SPRINT 4.3: Conectado con Firestore via searchAndFilterEmployeesProvider
/// - Lista actualizada en tiempo real
/// - Búsqueda funcional
/// - Filtros por departamento funcionales
class EmployeesListScreen extends ConsumerStatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  ConsumerState<EmployeesListScreen> createState() =>
      _EmployeesListScreenState();
}

class _EmployeesListScreenState extends ConsumerState<EmployeesListScreen> {
  final _searchController = TextEditingController();
  String _selectedDepartment = 'todos';
  bool _isDrawerOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DÍA 4 - SPRINT 4.3: Observar empleados desde Firestore con filtros
    final employeesAsync = ref.watch(
      searchAndFilterEmployeesProvider(
        _searchController.text,
        _selectedDepartment,
      ),
    );

    // También obtener el total (sin filtros) para el contador
    final allEmployeesAsync = ref.watch(allEmployeesProvider);

    return Stack(
      children: [
        AdminLayout(
          currentRoute: AppRouter.adminEmployees,
          child: SingleChildScrollView(
            padding: AppSpacing.allXxl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text('Gestión de Empleados', style: AppTextStyles.h3),

                AppSpacing.verticalSpaceLg,

                // Búsqueda y botón nuevo
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _searchController,
                        hintText: 'Buscar por nombre, email o ID...',
                        prefixIcon: Icons.search,
                        onChanged: (_) {
                          // El provider se actualiza automáticamente
                          setState(() {}); // Trigger rebuild para el provider
                        },
                      ),
                    ),
                    AppSpacing.horizontalSpaceMd,
                    CustomButton(
                      text: 'Nuevo',
                      icon: Icons.add,
                      variant: ButtonVariant.primary,
                      onPressed: () => setState(() => _isDrawerOpen = true),
                    ),
                  ],
                ),

                AppSpacing.verticalSpaceMd,

                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos', 'todos'),
                      AppSpacing.horizontalSpaceSm,
                      _buildFilterChip('Tecnología', 'Tecnología'),
                      AppSpacing.horizontalSpaceSm,
                      _buildFilterChip('Docente', 'Docente'),
                      AppSpacing.horizontalSpaceSm,
                      _buildFilterChip('Administración', 'Administración'),
                      AppSpacing.horizontalSpaceSm,
                      _buildFilterChip('RRHH', 'Recursos Humanos'),
                    ],
                  ),
                ),

                AppSpacing.verticalSpaceLg,

                // Lista de empleados con estados de AsyncValue
                employeesAsync.when(
                  data: (filteredEmployees) {
                    if (filteredEmployees.isEmpty) {
                      return SizedBox(
                        height: 400,
                        child: _buildEmptyState(),
                      );
                    }

                    return Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredEmployees.length,
                          separatorBuilder: (context, index) =>
                              AppSpacing.verticalSpaceMd,
                          itemBuilder: (context, index) {
                            final employee = filteredEmployees[index];
                            return EmployeeListItem(
                              employee:
                                  employee, // Pasar UserModel directamente
                              onTap: () {
                                context.push(
                                  AppRouter.adminEmployeeDetail.replaceFirst(
                                    ':id',
                                    employee.userId,
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // Footer con contador
                        AppSpacing.verticalSpaceMd,
                        allEmployeesAsync.when(
                          data: (allEmployees) => Text(
                            'Mostrando ${filteredEmployees.length} de ${allEmployees.length} empleados',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          loading: () => Text(
                            'Cargando...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          AppSpacing.verticalSpaceLg,
                          Text(
                            'Error al cargar empleados',
                            style: AppTextStyles.h4,
                          ),
                          AppSpacing.verticalSpaceSm,
                          Text(
                            error.toString(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Drawer para nuevo empleado
        NewEmployeeDrawer(
          isOpen: _isDrawerOpen,
          onClose: () => setState(() => _isDrawerOpen = false),
          onEmployeeCreated: () {
            setState(() {
              // La lista se actualiza automáticamente vía Stream
              _isDrawerOpen = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedDepartment == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDepartment = value;
          // El provider se actualiza automáticamente
        });
      },
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
          AppSpacing.verticalSpaceLg,
          Text('No se encontraron empleados', style: AppTextStyles.h4),
          AppSpacing.verticalSpaceSm,
          Text(
            'Intenta con otros filtros o búsqueda',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
