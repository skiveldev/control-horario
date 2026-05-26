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
import '../widgets/employee_table_header.dart';
import '../widgets/employee_table_row.dart';
import '../widgets/new_employee_drawer.dart';
import '../../providers/admin_provider.dart';
import '../../../auth/models/user_model.dart';

/// Pantalla de lista de empleados (rediseñada con tabla)
///
/// Muestra todos los empleados con búsqueda y filtros en formato tabla.
///
/// DÍA 4 - SPRINT 4.3: Conectado con Firestore via searchAndFilterEmployeesProvider
/// - Lista actualizada en tiempo real
/// - Búsqueda funcional
/// - Filtros por departamento funcionales
/// - Nueva UI: Tabla estructurada con columnas
/// - Paginación local
/// - Responsive: tabla en desktop, cards en mobile
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

  // Paginación
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text('Gestión de Trabajadores', style: AppTextStyles.h3),
              AppSpacing.verticalSpaceXs,
              Text(
                'Administra los empleados del sistema y sus turnos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              AppSpacing.verticalSpaceLg,

              // Búsqueda, Filtros, Exportar y botón nuevo
              _buildActionBar(context),

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

              // Lista de empleados con tabla o cards según pantalla
              employeesAsync.when(
                data: (filteredEmployees) {
                  if (filteredEmployees.isEmpty) {
                    return SizedBox(
                      height: 400,
                      child: _buildEmptyState(),
                    );
                  }

                  // Calcular paginación
                  final totalPages =
                      (filteredEmployees.length / _itemsPerPage).ceil();
                  final startIndex = (_currentPage - 1) * _itemsPerPage;
                  final endIndex = (startIndex + _itemsPerPage)
                      .clamp(0, filteredEmployees.length);
                  final paginatedEmployees =
                      filteredEmployees.sublist(startIndex, endIndex);

                  // Responsive: tabla en desktop/tablet, cards en mobile
                  final isMobile = context.isMobile;

                  return Column(
                    children: [
                      // Tabla o Cards según dispositivo
                      if (isMobile)
                        _buildCardsList(paginatedEmployees)
                      else
                        _buildTable(paginatedEmployees),

                      AppSpacing.verticalSpaceLg,

                      // Footer con contador y paginación
                      _buildFooter(
                        context,
                        allEmployeesAsync,
                        filteredEmployees.length,
                        totalPages,
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
                          color: Theme.of(context).colorScheme.error,
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      selectedColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
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
          Icon(Icons.search_off,
              size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          AppSpacing.verticalSpaceLg,
          Text('No se encontraron empleados', style: AppTextStyles.h4),
          AppSpacing.verticalSpaceSm,
          Text(
            'Intenta con otros filtros o búsqueda',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MÉTODOS DE BUILD
  // ============================================================================

  Widget _buildActionBar(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile) {
      // En mobile: diseño vertical
      return Column(
        children: [
          // Búsqueda
          CustomTextField(
            controller: _searchController,
            hintText: 'Buscar por nombre, email o ID...',
            prefixIcon: Icons.search,
            onChanged: (_) {
              // Resetear página al buscar
              setState(() {
                _currentPage = 1;
              });
            },
          ),
          AppSpacing.verticalSpaceSm,
          // Botones
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Filtros',
                  icon: Icons.filter_list,
                  variant: ButtonVariant.outline,
                  onPressed: _showFiltersPlaceholder,
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              Expanded(
                child: CustomButton(
                  text: 'Exportar',
                  icon: Icons.download,
                  variant: ButtonVariant.outline,
                  onPressed: _showExportPlaceholder,
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              Expanded(
                child: CustomButton(
                  text: 'Nuevo',
                  icon: Icons.add,
                  variant: ButtonVariant.brand,
                  onPressed: () => setState(() => _isDrawerOpen = true),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // En desktop/tablet: diseño horizontal con botones flexibles
    return Row(
      children: [
        // Búsqueda
        Expanded(
          flex: 3,
          child: CustomTextField(
            controller: _searchController,
            hintText: 'Buscar por nombre, email o ID...',
            prefixIcon: Icons.search,
            onChanged: (_) {
              // Resetear página al buscar
              setState(() {
                _currentPage = 1;
              });
            },
          ),
        ),
        AppSpacing.horizontalSpaceMd,
        // Filtros
        Flexible(
          child: CustomButton(
            text: 'Filtros',
            icon: Icons.filter_list,
            variant: ButtonVariant.outline,
            onPressed: _showFiltersPlaceholder,
          ),
        ),
        AppSpacing.horizontalSpaceSm,
        // Exportar
        Flexible(
          child: CustomButton(
            text: 'Exportar',
            icon: Icons.download,
            variant: ButtonVariant.outline,
            onPressed: _showExportPlaceholder,
          ),
        ),
        AppSpacing.horizontalSpaceMd,
        // Nuevo Trabajador
        Flexible(
          child: CustomButton(
            text: 'Nuevo Trabajador',
            icon: Icons.add,
            variant: ButtonVariant.brand,
            onPressed: () => setState(() => _isDrawerOpen = true),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<UserModel> employees) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          // Header de tabla
          const EmployeeTableHeader(),

          // Filas de empleados
          ...employees.map((employee) {
            return EmployeeTableRow(
              employee: employee,
              onTap: () {
                context.push(
                  AppRouter.adminEmployeeDetail.replaceFirst(
                    ':id',
                    employee.userId,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardsList(List<UserModel> employees) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      separatorBuilder: (context, index) => AppSpacing.verticalSpaceMd,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return EmployeeListItem(
          employee: employee,
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
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AsyncValue<List<dynamic>> allEmployeesAsync,
    int filteredCount,
    int totalPages,
  ) {
    return Column(
      children: [
        // Contador
        allEmployeesAsync.when(
          data: (allEmployees) => Text(
            'Mostrando $filteredCount de ${allEmployees.length} empleados',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          loading: () => Text(
            'Cargando...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          error: (_, __) => Text(
            'Error',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),

        AppSpacing.verticalSpaceMd,

        // Paginación
        if (totalPages > 1) _buildPagination(totalPages),
      ],
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón Anterior
        TextButton.icon(
          onPressed:
              _currentPage > 1 ? () => setState(() => _currentPage--) : null,
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          label: const Text('Anterior'),
          style: TextButton.styleFrom(
            foregroundColor: _currentPage > 1
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        AppSpacing.horizontalSpaceMd,

        // Indicador de página actual
        Container(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: AppSpacing.borderRadiusXs,
          ),
          child: Text(
            '$_currentPage',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),

        AppSpacing.horizontalSpaceSm,

        Text(
          'de $totalPages',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),

        AppSpacing.horizontalSpaceMd,

        // Botón Siguiente
        TextButton(
          onPressed: _currentPage < totalPages
              ? () => setState(() => _currentPage++)
              : null,
          style: TextButton.styleFrom(
            foregroundColor: _currentPage < totalPages
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Siguiente'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // CALLBACKS
  // ============================================================================

  void _showFiltersPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Panel de filtros avanzados - Próximamente',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showExportPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exportar a CSV/Excel - Próximamente',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
