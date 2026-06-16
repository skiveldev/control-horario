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

/// Pantalla de lista de empleados — rediseño visual.
///
/// Centro de gestión de empleados con búsqueda funcional, filtros por
/// departamento, tabla/cards responsive y paginación local.
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
    final employeesAsync = ref.watch(
      searchAndFilterEmployeesProvider(
        _searchController.text,
        _selectedDepartment,
      ),
    );

    final allEmployeesAsync = ref.watch(allEmployeesProvider);

    return Stack(
      children: [
        AdminLayout(
          currentRoute: AppRouter.adminEmployees,
          child: employeesAsync.when(
            data: (filteredEmployees) => _Content(
              allEmployeesAsync: allEmployeesAsync,
              filteredEmployees: filteredEmployees,
              searchController: _searchController,
              selectedDepartment: _selectedDepartment,
              currentPage: _currentPage,
              itemsPerPage: _itemsPerPage,
              onSearchChanged: () => setState(() => _currentPage = 1),
              onDepartmentChanged: (dept) => setState(() {
                _selectedDepartment = dept;
                _currentPage = 1;
              }),
              onPageChanged: (page) => setState(() => _currentPage = page),
              onNewEmployee: () => setState(() => _isDrawerOpen = true),
              onEmployeeTap: (employee) {
                context.push(
                  AppRouter.adminEmployeeDetail.replaceFirst(
                    ':id',
                    employee.userId,
                  ),
                );
              },
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => _ErrorState(message: error.toString()),
          ),
        ),

        // Drawer para nuevo empleado
        NewEmployeeDrawer(
          isOpen: _isDrawerOpen,
          onClose: () => setState(() => _isDrawerOpen = false),
          onEmployeeCreated: () {
            setState(() {
              _isDrawerOpen = false;
            });
          },
        ),
      ],
    );
  }
}

// ==========================================================================
// EMPTY LIST PLACEHOLDER (shown inside _Content when list is empty)
// ==========================================================================

/// Empty-state message rendered *inside* the normal content shell, so the
/// header, search, department chips, and "Nuevo Trabajador" CTA remain visible.
Widget _buildEmptyStateContent(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.giant,
          horizontal: AppSpacing.massive,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.avatarXxl,
              height: AppSpacing.avatarXxl,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: AppSpacing.iconXxl,
                color: cs.primary,
              ),
            ),
            AppSpacing.verticalSpaceXl,
            Text(
              'No se encontraron empleados',
              style: AppTextStyles.h4.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceMd,
            Text(
              'Intenta con otros filtros o búsqueda',
              style: AppTextStyles.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

// ============================================================================
// CONTENT (employees loaded)
// ============================================================================

class _Content extends StatelessWidget {
  final AsyncValue<List<UserModel>> allEmployeesAsync;
  final List<UserModel> filteredEmployees;
  final TextEditingController searchController;
  final String selectedDepartment;
  final int currentPage;
  final int itemsPerPage;
  final VoidCallback onSearchChanged;
  final void Function(String) onDepartmentChanged;
  final void Function(int) onPageChanged;
  final VoidCallback onNewEmployee;
  final void Function(UserModel) onEmployeeTap;

  const _Content({
    required this.allEmployeesAsync,
    required this.filteredEmployees,
    required this.searchController,
    required this.selectedDepartment,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onSearchChanged,
    required this.onDepartmentChanged,
    required this.onPageChanged,
    required this.onNewEmployee,
    required this.onEmployeeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER INTRO ──
            _HeaderIntro(
              allEmployeesAsync: allEmployeesAsync,
              onNewEmployee: onNewEmployee,
            ),
            AppSpacing.verticalSpaceXl,

            // ── STATS ROW ──
            _StatsRow(allEmployeesAsync: allEmployeesAsync),
            AppSpacing.verticalSpaceXl,

            // ── SEARCH & FILTER BAR ──
            _SearchFilterBar(
              searchController: searchController,
              onSearchChanged: onSearchChanged,
            ),
            AppSpacing.verticalSpaceMd,

            // ── DEPARTMENT CHIPS ──
            _DepartmentChips(
              selectedDepartment: selectedDepartment,
              onDepartmentChanged: onDepartmentChanged,
            ),
            AppSpacing.verticalSpaceXl,

            // ── EMPLOYEE LIST or EMPTY STATE ──
            if (filteredEmployees.isEmpty)
              _buildEmptyStateContent(context)
            else
              _EmployeeList(
                filteredEmployees: filteredEmployees,
                currentPage: currentPage,
                itemsPerPage: itemsPerPage,
                onEmployeeTap: onEmployeeTap,
              ),
            AppSpacing.verticalSpaceXl,

            // ── FOOTER ──
            _Footer(
              allEmployeesAsync: allEmployeesAsync,
              filteredCount: filteredEmployees.length,
              currentPage: currentPage,
              itemsPerPage: itemsPerPage,
              onPageChanged: onPageChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER INTRO
// ============================================================================

/// Bloque superior con título, subtítulo, descripción y botón de acción.
class _HeaderIntro extends StatelessWidget {
  final AsyncValue<List<UserModel>> allEmployeesAsync;
  final VoidCallback onNewEmployee;

  const _HeaderIntro({
    required this.allEmployeesAsync,
    required this.onNewEmployee,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = allEmployeesAsync.valueOrNull?.length ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Trabajadores',
                style: AppTextStyles.h1.copyWith(color: cs.primary),
              ),
              const SizedBox(height: 6),
              Text(
                'Administra los empleados del sistema y sus turnos. '
                '$total ${total == 1 ? 'empleado registrado' : 'empleados registrados'}.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.horizontalSpaceXl,
        CustomButton(
          text: 'Nuevo Trabajador',
          icon: Icons.add,
          variant: ButtonVariant.brand,
          size: ButtonSize.medium,
          onPressed: onNewEmployee,
        ),
      ],
    );
  }
}

// ============================================================================
// STATS ROW
// ============================================================================

/// Fila de tarjetas con métricas derivadas de los datos reales de empleados.
///
/// Adapta el patrón de CalendarManagementScreen: 4 cards en desktop,
/// 2 en tablet, 1 en mobile.
class _StatsRow extends StatelessWidget {
  final AsyncValue<List<UserModel>> allEmployeesAsync;

  const _StatsRow({required this.allEmployeesAsync});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allEmployees = allEmployeesAsync.valueOrNull ?? [];

    final total = allEmployees.length;
    final withSchedule = allEmployees.where((e) => e.scheduleId != null).length;
    final departments = allEmployees
        .map((e) => e.department)
        .where((d) => d != null && d.isNotEmpty)
        .toSet()
        .length;
    final supervisors = allEmployees
        .where(
          (e) =>
              e.isSupervisor ||
              e.role == UserRole.admin ||
              e.role == UserRole.rrhh,
        )
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const double gap = 16.0;

        int columns;
        if (width >= 1024) {
          columns = 4;
        } else if (width >= 640) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cardWidth = (width - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Total Empleados',
                value: '$total',
                icon: Icons.people,
                color: cs.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Con Horario',
                value: '$withSchedule',
                icon: Icons.schedule,
                color: AppColors.success,
                valueColor: AppColors.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Departamentos',
                value: '$departments',
                icon: Icons.business,
                color: cs.primary,
                valueColor: cs.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _StatCard(
                label: 'Supervisores',
                value: '$supervisors',
                icon: Icons.admin_panel_settings,
                color: AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// STAT CARD (reused pattern from CalendarManagementScreen)
// ============================================================================

/// Tarjeta individual de estadística.
///
/// Surface card con borde, sombra sutil, icono en caja de color y valor grande.
///
/// [color] controla el icono y su fondo.
/// [valueColor] controla el color del valor numérico.
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.6,
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: valueColor ?? cs.onSurface,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SEARCH & FILTER BAR
// ============================================================================

/// Barra de búsqueda responsive.
///
/// Desktop: search field ocupa todo el ancho.
/// Mobile: search field ocupa todo el ancho.
///
/// El CTA "Nuevo Trabajador" se mantiene exclusivamente en el _HeaderIntro
/// para evitar duplicados.
class _SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;

  const _SearchFilterBar({
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: searchController,
      hintText: 'Buscar por nombre, email o ID...',
      prefixIcon: Icons.search,
      onChanged: (_) => onSearchChanged(),
    );
  }
}

// ============================================================================
// DEPARTMENT CHIPS
// ============================================================================

/// Fila de chips de departamento para filtrar empleados.
class _DepartmentChips extends StatelessWidget {
  final String selectedDepartment;
  final void Function(String) onDepartmentChanged;

  const _DepartmentChips({
    required this.selectedDepartment,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget buildChip(String label, String value) {
      final isSelected = selectedDepartment == value;
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onDepartmentChanged(value),
          backgroundColor: cs.surfaceContainerHighest,
          selectedColor: cs.primary.withValues(alpha: 0.1),
          checkmarkColor: cs.primary,
          labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? cs.primary : cs.onSurface,
              ),
          labelPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          buildChip('Todos', 'todos'),
          buildChip('Tecnología', 'Tecnología'),
          buildChip('Docente', 'Docente'),
          buildChip('Administración', 'Administración'),
          buildChip('RRHH', 'Recursos Humanos'),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPLOYEE LIST (table or cards)
// ============================================================================

class _EmployeeList extends StatelessWidget {
  final List<UserModel> filteredEmployees;
  final int currentPage;
  final int itemsPerPage;
  final void Function(UserModel) onEmployeeTap;

  const _EmployeeList({
    required this.filteredEmployees,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onEmployeeTap,
  });

  @override
  Widget build(BuildContext context) {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage).clamp(0, filteredEmployees.length);
    final paginatedEmployees = filteredEmployees.sublist(startIndex, endIndex);

    final isMobile = context.isMobile;

    if (isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: paginatedEmployees.length,
        separatorBuilder: (_, __) => AppSpacing.verticalSpaceMd,
        itemBuilder: (context, index) {
          final employee = paginatedEmployees[index];
          return EmployeeListItem(
            employee: employee,
            onTap: () => onEmployeeTap(employee),
          );
        },
      );
    }

    return _Table(employees: paginatedEmployees, onEmployeeTap: onEmployeeTap);
  }
}

// ============================================================================
// TABLE
// ============================================================================

class _Table extends StatelessWidget {
  final List<UserModel> employees;
  final void Function(UserModel) onEmployeeTap;

  const _Table({required this.employees, required this.onEmployeeTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const EmployeeTableHeader(),
          ...employees.map((employee) {
            return EmployeeTableRow(
              employee: employee,
              onTap: () => onEmployeeTap(employee),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// FOOTER (counter + pagination)
// ============================================================================

class _Footer extends StatelessWidget {
  final AsyncValue<List<UserModel>> allEmployeesAsync;
  final int filteredCount;
  final int currentPage;
  final int itemsPerPage;
  final void Function(int) onPageChanged;

  const _Footer({
    required this.allEmployeesAsync,
    required this.filteredCount,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (filteredCount / itemsPerPage).ceil();

    return Column(
      children: [
        // ── COUNTER ──
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

        // ── PAGINATION ──
        if (totalPages > 1)
          _Pagination(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          ),
      ],
    );
  }
}

// ============================================================================
// PAGINATION
// ============================================================================

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        TextButton.icon(
          onPressed:
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          label: const Text('Anterior'),
          style: TextButton.styleFrom(
            foregroundColor: currentPage > 1 ? cs.primary : cs.onSurfaceVariant,
          ),
        ),

        AppSpacing.horizontalSpaceMd,

        // Page indicator
        Container(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: AppSpacing.borderRadiusXs,
          ),
          child: Text(
            '$currentPage',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),

        AppSpacing.horizontalSpaceSm,

        Text(
          'de $totalPages',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),

        AppSpacing.horizontalSpaceMd,

        // Next
        TextButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          style: TextButton.styleFrom(
            foregroundColor:
                currentPage < totalPages ? cs.primary : cs.onSurfaceVariant,
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
}

// ============================================================================
// ERROR STATE
// ============================================================================

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          AppSpacing.verticalSpaceMd,
          Text(
            'Error al cargar empleados',
            style: AppTextStyles.h4.copyWith(color: cs.onSurface),
          ),
          AppSpacing.verticalSpaceSm,
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: cs.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
