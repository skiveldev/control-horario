import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/custom_app_bar.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../widgets/employee_list_item.dart';

/// Pantalla de lista de empleados
/// 
/// Muestra todos los empleados con búsqueda y filtros.
/// 
/// MOCK DATA: Usa MockData.employees
class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  final _searchController = TextEditingController();
  String _selectedDepartment = 'todos';
  List<Map<String, dynamic>> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _filteredEmployees = List.from(MockData.employees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees() {
    setState(() {
      _filteredEmployees = MockData.employees.where((emp) {
        final matchesSearch = emp['name']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());

        final matchesDepartment = _selectedDepartment == 'todos' ||
            emp['department'] == _selectedDepartment;

        return matchesSearch && matchesDepartment;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Gestión de Empleados',
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: EdgeInsets.all(
              context.responsiveValue(
                mobile: AppSpacing.lg,
                tablet: AppSpacing.xxl,
                desktop: AppSpacing.xxl,
              ),
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              children: [
                // Búsqueda
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _searchController,
                        hintText: 'Buscar por nombre...',
                        prefixIcon: Icons.search,
                        onChanged: (_) => _filterEmployees(),
                      ),
                    ),
                    AppSpacing.horizontalSpaceMd,
                    CustomButton(
                      text: 'Nuevo',
                      icon: Icons.add,
                      variant: ButtonVariant.primary,
                      onPressed: () {
                        // TODO [FASE-2]: Crear nuevo empleado
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Crear empleado en desarrollo'),
                          ),
                        );
                      },
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
              ],
            ),
          ),

          // Lista de empleados
          Expanded(
            child: _filteredEmployees.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: EdgeInsets.all(
                      context.responsiveValue(
                        mobile: AppSpacing.lg,
                        tablet: AppSpacing.xxl,
                        desktop: AppSpacing.xxl,
                      ),
                    ),
                    itemCount: _filteredEmployees.length,
                    separatorBuilder: (context, index) =>
                        AppSpacing.verticalSpaceMd,
                    itemBuilder: (context, index) {
                      final employee = _filteredEmployees[index];
                      return EmployeeListItem(
                        employee: employee,
                        onTap: () {
                          // Navegar a detalle
                          context.push(
                            AppRouter.adminEmployeeDetail
                                .replaceFirst(':id', employee['id'] as String),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Footer con contador
          Container(
            padding: AppSpacing.allLg,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Text(
              'Mostrando ${_filteredEmployees.length} de ${MockData.employees.length} empleados',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
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
          _filterEmployees();
        });
      },
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withOpacity(0.1),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          AppSpacing.verticalSpaceLg,
          Text(
            'No se encontraron empleados',
            style: AppTextStyles.h4,
          ),
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

