import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/layouts/admin_layout.dart';
import '../../../../shared/widgets/cards/custom_card.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
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
    final cs = Theme.of(context).colorScheme;

    return AdminLayout(
      currentRoute: AppRouter.adminEmployees,
      child: employeeAsync.when(
        data: (employee) {
          if (employee == null) {
            return _buildNotFound(context, cs);
          }
          return _buildContent(context, cs, ref, employee);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => _buildError(context, cs, error.toString()),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ColorScheme cs, WidgetRef ref, UserModel employee) {
    final isDesktop = context.isDesktop;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            // ── BACK NAVIGATION ────────────────────────────────────────
            _buildBackButton(context, cs),

            // ── HERO CARD ──────────────────────────────────────────────
            _buildHeroCard(context, cs, employee),

            AppSpacing.verticalSpaceXl,

            // ── TWO-COLUMN / STACKED LAYOUT ────────────────────────────
            if (isDesktop)
              _buildDesktopGrid(context, cs, ref, employee)
            else
              _buildMobileStack(context, cs, ref, employee),

            AppSpacing.verticalSpaceXl,

            // ── RECORDS CARD ───────────────────────────────────────────
            _buildRecordsCard(context, cs),

            // ── MOBILE EDIT BUTTON ─────────────────────────────────────
            if (!isDesktop) ...[
              AppSpacing.verticalSpaceXl,
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HERO CARD
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildHeroCard(
      BuildContext context, ColorScheme cs, UserModel employee) {
    final isMobile = context.isMobile;

    return CustomCard(
      elevation: CardElevation.medium,
      padding: AppSpacing.cardLarge,
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: isMobile
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Left: Avatar + info
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              // Bigger avatar
              _buildHeroAvatar(cs, employee),
              if (isMobile) AppSpacing.verticalSpaceMd,
              if (!isMobile) AppSpacing.horizontalSpaceXl,
              // Name + details
              Flexible(
                child: _buildHeroInfo(context, cs, employee, isMobile),
              ),
            ],
          ),

          // Right: Action buttons (desktop only)
          if (!isMobile) _buildHeroActions(context, cs, employee),
        ],
      ),
    );
  }

  Widget _buildHeroAvatar(ColorScheme cs, UserModel employee) {
    return CircleAvatar(
      radius: 45,
      backgroundColor: cs.primary,
      child: Text(
        _getInitials(employee.displayName),
        style: AppTextStyles.h2.copyWith(
          color: cs.onPrimary,
        ),
      ),
    );
  }

  Widget _buildHeroInfo(
      BuildContext context, ColorScheme cs, UserModel employee, bool isMobile) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Row: Name + status chip
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Text(employee.fullName, style: AppTextStyles.h2),
            _buildStatusChip(cs, employee.isActive),
          ],
        ),
        AppSpacing.verticalSpaceXs,
        // Position
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.badge, size: 18, color: cs.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                employee.position ?? 'Sin cargo asignado',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceSm,
        // Email + ID in a row
        Wrap(
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.xs,
          children: [
            _buildHeroBadge(
              icon: Icons.email,
              label: employee.email,
              cs: cs,
            ),
            _buildHeroBadge(
              icon: Icons.fingerprint,
              label: 'ID: ${employee.employeeId}',
              cs: cs,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(ColorScheme cs, bool isActive) {
    final color = isActive ? AppColors.success : cs.outline;
    final bgColor = isActive
        ? AppColors.success.withValues(alpha: 0.1)
        : cs.surfaceContainerHighest;
    final label = isActive ? 'Activo' : 'Inactivo';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge({
    required IconData icon,
    required String label,
    required ColorScheme cs,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: cs.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHeroActions(
      BuildContext context, ColorScheme cs, UserModel employee) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          text: 'Editar',
          icon: Icons.edit,
          variant: ButtonVariant.outline,
          onPressed: () => _showInfoEditorModal(context, employee),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DESKTOP GRID (two columns)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildDesktopGrid(
      BuildContext context, ColorScheme cs, WidgetRef ref, UserModel employee) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: Personal info + Weekly hours
        Expanded(
          flex: 5,
          child: _buildLeftColumn(context, cs, ref, employee),
        ),
        AppSpacing.horizontalSpaceXxl,
        // Right column: Schedule card
        Expanded(
          flex: 7,
          child: _buildScheduleCard(context, cs, employee),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MOBILE/TABLET STACK
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildMobileStack(
      BuildContext context, ColorScheme cs, WidgetRef ref, UserModel employee) {
    return Column(
      children: [
        _buildPersonalInfoCard(context, cs, ref, employee),
        AppSpacing.verticalSpaceLg,
        _buildWeeklyHoursCard(cs, employee),
        AppSpacing.verticalSpaceLg,
        _buildScheduleCard(context, cs, employee),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LEFT COLUMN (Desktop)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildLeftColumn(
      BuildContext context, ColorScheme cs, WidgetRef ref, UserModel employee) {
    return Column(
      children: [
        _buildPersonalInfoCard(context, cs, ref, employee),
        AppSpacing.verticalSpaceLg,
        _buildWeeklyHoursCard(cs, employee),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PERSONAL INFO CARD
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPersonalInfoCard(
      BuildContext context, ColorScheme cs, WidgetRef ref, UserModel employee) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with icon
          _buildSectionHeader(
            icon: Icons.info_outline,
            title: 'Información Personal',
            cs: cs,
          ),
          AppSpacing.verticalSpaceMd,
          _buildSeparator(cs),
          AppSpacing.verticalSpaceMd,
          // Info rows with icons
          _buildIconInfoRow(
            icon: Icons.contact_page,
            label: 'DNI/NIE',
            value: employee.dni ?? 'No especificado',
            cs: cs,
          ),
          _buildIconInfoRow(
            icon: Icons.call,
            label: 'Teléfono',
            value: employee.telefono ?? 'No especificado',
            cs: cs,
          ),
          _buildIconInfoRow(
            icon: Icons.domain,
            label: 'Departamento',
            value: employee.department ?? 'No especificado',
            cs: cs,
          ),
          _buildIconInfoRow(
            icon: Icons.business,
            label: 'Empresa',
            value: employee.empresa ?? 'No especificado',
            cs: cs,
          ),
          _buildIconInfoRow(
            icon: Icons.manage_accounts,
            label: 'Rol',
            value: _formatRole(employee.role),
            cs: cs,
          ),
          _buildIconInfoRow(
            icon: Icons.visibility,
            label: 'Puede supervisar',
            value: employee.canSuperviseTeam ? 'Sí' : 'No',
            cs: cs,
          ),
          _buildSupervisorIconRow(ref, employee, cs),
          if (employee.fechaInicio != null)
            _buildIconInfoRow(
              icon: Icons.calendar_today,
              label: 'Fecha Inicio',
              value: DateFormat('dd/MM/yyyy').format(employee.fechaInicio!),
              cs: cs,
            ),
          _buildCalendarRow(context, cs, ref, employee),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // WEEKLY HOURS CARD
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildWeeklyHoursCard(ColorScheme cs, UserModel employee) {
    final weeklyHours = employee.weeklyHours.toStringAsFixed(0);
    final statusLabel =
        employee.isActive ? 'Contrato activo' : 'Empleado inactivo';
    final statusColor = employee.isActive ? AppColors.success : cs.outline;

    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      backgroundColor: cs.surfaceContainerLowest,
      borderColor: cs.primary.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.allMd,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Icon(
                  Icons.access_time,
                  size: 18,
                  color: cs.primary,
                ),
              ),
              AppSpacing.horizontalSpaceSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horas Semanales',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.verticalSpaceXs,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCircular,
                        ),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceLg,
          Text(
            '${weeklyHours}h',
            style: AppTextStyles.displaySmall.copyWith(
              color: cs.primary,
            ),
          ),
          AppSpacing.verticalSpaceXs,
          Text(
            'Jornada semanal asignada',
            style: AppTextStyles.bodySmall.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          AppSpacing.verticalSpaceLg,
          ClipRRect(
            borderRadius: AppSpacing.borderRadiusXs,
            child: LinearProgressIndicator(
              value: 1,
              minHeight: 8,
              backgroundColor: cs.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
          AppSpacing.verticalSpaceSm,
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              AppSpacing.horizontalSpaceXs,
              Expanded(
                child: Text(
                  'Objetivo semanal configurado',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SCHEDULE CARD
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildScheduleCard(
      BuildContext context, ColorScheme cs, UserModel employee) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: _buildSectionHeader(
                  icon: Icons.schedule,
                  title: 'Horario Laboral',
                  cs: cs,
                ),
              ),
              // Edit schedule button
              OutlinedButton.icon(
                onPressed: () => _showScheduleEditorModal(context, employee),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Editar Horario'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceLg,
          WeekScheduleViewer(employeeId: employeeId),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RECORDS CARD
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildRecordsCard(BuildContext context, ColorScheme cs) {
    return CustomCard(
      elevation: CardElevation.low,
      padding: AppSpacing.cardLarge,
      child: Column(
        children: [
          // Section header with icon
          _buildSectionHeader(
            icon: Icons.history,
            title: 'Registros Recientes',
            cs: cs,
          ),
          AppSpacing.verticalSpaceMd,
          _buildSeparator(cs),
          AppSpacing.verticalSpaceXxl,
          // Empty state
          Icon(Icons.history,
              size: 40, color: cs.outline.withValues(alpha: 0.5)),
          AppSpacing.verticalSpaceMd,
          Text(
            'Próximamente: Visualiza aquí el historial detallado de fichajes, '
            'pausas e incidencias de este empleado.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SHARED BUILDING BLOCKS
  // ═══════════════════════════════════════════════════════════════════════

  /// Safe back-to-employees-list affordance.
  ///
  /// Pops the top route when there is a previous route in the stack (navigated
  /// from the list). When the detail screen was opened directly (deep-link,
  /// browser refresh), `canPop()` is false and the button navigates explicitly
  /// to [AppRouter.adminEmployees] so the user never lands on a blank shell.
  Widget _buildBackButton(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.adminEmployees);
            }
          },
          borderRadius: AppSpacing.borderRadiusSm,
          child: Padding(
            padding: AppSpacing.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, size: 18, color: cs.primary),
                AppSpacing.horizontalSpaceXs,
                Text(
                  'Volver a empleados',
                  style: AppTextStyles.labelLarge.copyWith(color: cs.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required ColorScheme cs,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.primary),
        AppSpacing.horizontalSpaceSm,
        Flexible(
          child: Text(
            title,
            style: AppTextStyles.h5.copyWith(color: cs.primary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(ColorScheme cs) {
    return Divider(
      height: 1,
      thickness: 1,
      color: cs.outlineVariant,
    );
  }

  Widget _buildIconInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme cs,
  }) {
    return Padding(
      padding: AppSpacing.verticalSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: cs.outline),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
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

  Widget _buildNotFound(BuildContext context, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBackButton(context, cs),
          Icon(
            Icons.person_off,
            size: 64,
            color: cs.outline,
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
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, ColorScheme cs, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBackButton(context, cs),
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
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
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

  /// Fila de calendario con nombre resuelto y botón "Cambiar" (icon-row style)
  Widget _buildCalendarRow(
    BuildContext context,
    ColorScheme cs,
    WidgetRef ref,
    UserModel employee,
  ) {
    return Padding(
      padding: AppSpacing.verticalSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 18, color: cs.outline),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              'Calendario',
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
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
            icon: Icon(Icons.edit_outlined, size: 14, color: cs.primary),
            label: Text(
              'Cambiar',
              style: TextStyle(color: cs.primary),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  /// Supervisor row with icon pattern
  Widget _buildSupervisorIconRow(
      WidgetRef ref, UserModel employee, ColorScheme cs) {
    if (employee.role == UserRole.admin) {
      return _buildIconInfoRow(
        icon: Icons.supervisor_account,
        label: 'Supervisor',
        value: 'No aplica',
        cs: cs,
      );
    }

    if (employee.supervisorId == null ||
        employee.supervisorId!.trim().isEmpty) {
      return _buildIconInfoRow(
        icon: Icons.supervisor_account,
        label: 'Supervisor',
        value: 'Sin asignar',
        cs: cs,
      );
    }

    final supervisorAsync = ref.watch(userByIdProvider(employee.supervisorId!));

    return Padding(
      padding: AppSpacing.verticalSm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.supervisor_account, size: 18, color: cs.outline),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              'Supervisor',
              style: AppTextStyles.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: supervisorAsync.when(
              data: (supervisor) => Text(
                supervisor?.fullName ?? 'Supervisor no encontrado',
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
                employee.supervisorId!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
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
