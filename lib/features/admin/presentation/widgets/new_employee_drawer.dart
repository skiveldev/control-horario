import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/provisioning_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../auth/models/user_model.dart';
import 'supervisor_assignment_field.dart';
import '../../providers/supervisors_provider.dart';
import '../../providers/user_management_provider.dart';
import '../../providers/schedule_management_provider.dart';
import '../../providers/calendar_management_provider.dart';

/// Drawer lateral para crear nuevo empleado
///
/// Características:
/// - Desliza desde la derecha con animación suave (300ms)
/// - Ancho responsive: 100% mobile, 520px desktop
/// - Backdrop oscuro con tap para cerrar
/// - Formulario con 3 secciones: Personal, Laboral, Control Horario
///
class NewEmployeeDrawer extends ConsumerStatefulWidget {
  /// Controla si el drawer está abierto
  final bool isOpen;

  /// Callback al cerrar el drawer
  final VoidCallback onClose;

  /// Callback opcional cuando se crea un empleado (para refrescar lista)
  final VoidCallback? onEmployeeCreated;

  const NewEmployeeDrawer({
    super.key,
    required this.isOpen,
    required this.onClose,
    this.onEmployeeCreated,
  });

  @override
  ConsumerState<NewEmployeeDrawer> createState() => _NewEmployeeDrawerState();
}

class _NewEmployeeDrawerState extends ConsumerState<NewEmployeeDrawer> {
  // ============================================================================
  // CONTROLLERS - Sección 1: Información Personal
  // ============================================================================
  final _nombreController = TextEditingController();
  final _apellido1Controller = TextEditingController();
  final _apellido2Controller = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  // ============================================================================
  // CONTROLLERS - Sección 2: Información Laboral
  // ============================================================================
  final _employeeIdController = TextEditingController();
  final _empresaController = TextEditingController(text: 'Escuela Música');
  final _cargoController = TextEditingController();

  // ============================================================================
  // STATE - Sección 2: Información Laboral
  // ============================================================================
  String? _selectedDepartamento;
  final List<String> _departamentos = [
    'Docente',
    'Tecnología',
    'Administración',
    'Recursos Humanos',
  ];

  // ============================================================================
  // STATE - Sección 3: Control Horario
  // ============================================================================
  // TODO: Replace String with UserRole enum for type safety (see FIX-11)
  String _selectedRole = 'employee';
  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;
  String? _selectedScheduleId;
  String? _selectedCalendarId;
  String? _selectedSupervisorId;
  bool _isActive = true;
  final _weeklyHoursController = TextEditingController();

  // ============================================================================
  // VALIDATION / SUBMISSION STATE
  // ============================================================================
  final Map<String, String?> _errors = {};
  bool _showValidation = false;
  bool _isSubmitting = false;
  late final ProvisioningWorkflow _workflow;

  @override
  void initState() {
    super.initState();
    _workflow = ref.read(provisioningWorkflowProvider);
  }

  @override
  void dispose() {
    _workflow.cancel();
    _nombreController.dispose();
    _apellido1Controller.dispose();
    _apellido2Controller.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _empresaController.dispose();
    _cargoController.dispose();
    _weeklyHoursController.dispose();
    super.dispose();
  }

  // ============================================================================
  // VALIDACIONES
  // ============================================================================

  bool _validateForm() {
    setState(() {
      _showValidation = true;
      _errors.clear();

      // ✅ SOLO 3 CAMPOS OBLIGATORIOS (Sprint 1.3)
      // 1. Nombre
      if (_nombreController.text.trim().isEmpty) {
        _errors['nombre'] = 'Campo obligatorio';
      }

      // 2. Primer Apellido
      if (_apellido1Controller.text.trim().isEmpty) {
        _errors['apellido1'] = 'Campo obligatorio';
      }

      // 3. Email
      if (_emailController.text.trim().isEmpty) {
        _errors['email'] = 'Campo obligatorio';
      } else if (!_emailController.text.contains('@')) {
        _errors['email'] = 'Email inválido';
      }

      // ⚠️ Validaciones opcionales (solo si hay valor)
      if (_dniController.text.trim().isNotEmpty &&
          _dniController.text.trim().length < 8) {
        _errors['dni'] = 'DNI/NIE muy corto';
      }

      // Validación de horas semanales
      final hoursText = _weeklyHoursController.text.trim();
      if (hoursText.isNotEmpty) {
        final hours = double.tryParse(hoursText);
        if (hours == null) {
          _errors['weeklyHours'] = 'Ingrese un número válido';
        } else if (hours <= 0) {
          _errors['weeklyHours'] = 'Debe ser mayor que 0';
        }
      }
    });

    return _errors.isEmpty;
  }

  // ============================================================================
  // MÉTODOS DE GUARDADO - FASE 2 (Sprint 1.3)
  // ============================================================================

  Future<void> _save() => _submit(closeAfterCompletion: true);

  Future<void> _saveAndAddAnother() => _submit(closeAfterCompletion: false);

  Future<void> _submit({required bool closeAfterCompletion}) async {
    if (_isSubmitting) return;
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _createEmployeeInFirebase();
      if (!mounted || result == null) return;
      if (result is CompletedProvisioningStatus) {
        widget.onEmployeeCreated?.call();
        if (closeAfterCompletion) {
          _showCompletedDialog(result);
        } else {
          _clearForm();
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Creates the employee through the typed provisioning provider.
  Future<ProvisioningResult?> _createEmployeeInFirebase() async {
    // Convertir role de String a UserRole
    UserRole role = UserRole.employee;
    var isSupervisor = false;
    switch (_selectedRole) {
      case 'admin':
        role = UserRole.admin;
        break;
      case 'rrhh':
        role = UserRole.rrhh;
        break;
      case 'supervisor':
        // Supervisor mantiene rol base empleado y habilita permiso adicional
        role = UserRole.employee;
        isSupervisor = true;
        break;
      default:
        role = UserRole.employee;
    }

    // Parsear weeklyHours: vacío usa default 40.0, validado previamente por _validateForm
    final hoursText = _weeklyHoursController.text.trim();
    final weeklyHours = hoursText.isEmpty
        ? 40.0
        : double.parse(hoursText); // Ya validado, no necesita ?? fallback

    try {
      final result =
          await ref.read(userManagementProvider.notifier).createEmployee(
                email: _emailController.text.trim(),
                nombre: _nombreController.text.trim(),
                apellido1: _apellido1Controller.text.trim(),
                apellido2: _apellido2Controller.text.trim().isEmpty
                    ? null
                    : _apellido2Controller.text.trim(),
                employeeId: _employeeIdController.text.trim().isEmpty
                    ? null
                    : _employeeIdController.text.trim(),
                weeklyHours: weeklyHours,
                dni: _dniController.text.trim().isEmpty
                    ? null
                    : _dniController.text.trim(),
                telefono: _telefonoController.text.trim().isEmpty
                    ? null
                    : _telefonoController.text.trim(),
                cargo: _cargoController.text.trim().isEmpty
                    ? null
                    : _cargoController.text.trim(),
                departamento: _selectedDepartamento,
                role: role,
                isSupervisor: isSupervisor,
                supervisorId:
                    _selectedRole == 'admin' ? null : _selectedSupervisorId,
                isActive: _isActive,
                // ✅ Los 4 campos que faltaban
                empresa: _empresaController.text.trim().isEmpty
                    ? null
                    : _empresaController.text.trim(),
                scheduleId: _selectedScheduleId,
                calendarId: _selectedCalendarId,
                fechaInicio: _fechaInicio,
                fechaFin: _fechaFin,
              );

      return result;
    } catch (_) {
      return const ProvisioningFailure.unknown();
    }
  }

  Future<bool> _tryCopyToClipboard(String text) async {
    if (text.isEmpty) return false;

    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showCompletedDialog(CompletedProvisioningStatus result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Alta completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Copiá este enlace y entregáselo de forma segura al empleado.'),
            const SizedBox(height: AppSpacing.md),
            SelectableText(result.passwordResetLink),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final copied =
                  await _tryCopyToClipboard(result.passwordResetLink);
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                    content:
                        Text(copied ? 'Enlace copiado' : 'No se pudo copiar')),
              );
            },
            child: const Text('COPIAR ENLACE'),
          ),
          CustomButton(
            text: 'CERRAR',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _closeDrawer();
            },
            variant: ButtonVariant.brand,
          ),
        ],
      ),
    );
  }

  void _closeDrawer() {
    ref.read(userManagementProvider.notifier).cancelObservation();
    widget.onClose();
  }

  void _clearForm() {
    setState(() {
      _nombreController.clear();
      _apellido1Controller.clear();
      _apellido2Controller.clear();
      _dniController.clear();
      _telefonoController.clear();
      _emailController.clear();
      _employeeIdController.clear();
      _cargoController.clear();
      _selectedDepartamento = null;
      _selectedRole = 'employee';
      _fechaInicio = DateTime.now();
      _fechaFin = null;
      _selectedScheduleId = null;
      _selectedCalendarId = null;
      _selectedSupervisorId = null;
      _weeklyHoursController.clear();
      _isActive = true;
      _errors.clear();
      _showValidation = false;
    });
  }

  // ============================================================================
  // TEST-ONLY SETTERS
  // ============================================================================

  /// Injects a [date] as the start date, applying the same contract the
  /// production date-picker callback uses: if [fechaFin] is set and is before
  /// the new start date, [fechaFin] is cleared to null.
  @visibleForTesting
  void debugSetFechaInicio(DateTime date) {
    setState(() {
      _fechaInicio = date;
      if (_fechaFin != null && _fechaFin!.isBefore(_fechaInicio)) {
        _fechaFin = null;
      }
    });
  }

  /// Injects a [date] as the end date directly, without opening a picker.
  @visibleForTesting
  void debugSetFechaFin(DateTime date) {
    setState(() {
      _fechaFin = date;
    });
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth < Breakpoints.tablet ? screenWidth : 650.0;

    return Stack(
      children: [
        // Backdrop
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: widget.isOpen ? 0.5 : 0.0,
          child: GestureDetector(
            onTap: _closeDrawer,
            child: Container(
              color: theme.colorScheme.onSurface,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // Drawer
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          right: widget.isOpen ? 0 : -drawerWidth,
          top: 0,
          bottom: 0,
          width: drawerWidth,
          child: Material(
            elevation: 8,
            child: Container(
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  // Header
                  _buildHeader(theme),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.allLg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProvisioningState(),
                          _buildPersonalSection(theme),
                          AppSpacing.verticalSpaceXxl,
                          _buildWorkSection(theme),
                          AppSpacing.verticalSpaceXxl,
                          _buildScheduleSection(theme),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  _buildFooter(theme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProvisioningState() {
    final result = ref.watch(userManagementProvider).result;
    if (result == null) return const SizedBox.shrink();
    final message = switch (result) {
      PendingProvisioningStatus(:final operationId) =>
        'Alta pendiente. Operación: $operationId',
      ActiveProvisioningStatus(:final operationId) =>
        'Alta en curso. Operación: $operationId',
      CompletedProvisioningStatus(:final passwordResetLink) =>
        'Alta completada. Enlace de restablecimiento: $passwordResetLink',
      FailedProvisioningStatus(:final operationId, :final terminalCode) =>
        'Alta fallida. Código terminal: $terminalCode. Operación: $operationId',
      ManualRecoveryProvisioningStatus(
        :final operationId,
        :final terminalCode,
        :final recoveryCode,
      ) =>
        'Recuperación manual requerida. Código terminal: $terminalCode. '
            'Código de recuperación: $recoveryCode. Operación: $operationId',
      ProvisioningFailure(:final code) =>
        'No se pudo completar el alta. Código: $code',
      _ => 'No se pudo completar el alta.',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Text(message, key: const Key('provisioningResult')),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      padding: AppSpacing.horizontalLg,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Nuevo Trabajador',
              style: AppTextStyles.h5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closeDrawer,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    final providerIsLoading =
        ref.watch(userManagementProvider.select((s) => s.isLoading));
    final isProcessing = providerIsLoading || _isSubmitting;
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < Breakpoints.tablet;

    final buttons = <Widget>[
      CustomButton(
        text: 'Cancelar',
        variant: ButtonVariant.text,
        onPressed: isProcessing ? null : _closeDrawer,
      ),
      if (!isNarrow) AppSpacing.horizontalSpaceSm,
      CustomButton(
        text: 'Guardar y Añadir',
        variant: ButtonVariant.outline,
        isLoading: isProcessing,
        onPressed: isProcessing ? null : _saveAndAddAnother,
      ),
      if (!isNarrow) AppSpacing.horizontalSpaceSm,
      CustomButton(
        text: 'Guardar',
        variant: ButtonVariant.brand,
        isLoading: isProcessing,
        onPressed: isProcessing ? null : _save,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      padding: AppSpacing.allLg,
      child: isNarrow
          ? Wrap(
              alignment: WrapAlignment.end,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: buttons,
            )
          : Row(
              children: [
                Expanded(child: buttons[0]),
                AppSpacing.horizontalSpaceSm,
                Expanded(child: buttons[2]),
                AppSpacing.horizontalSpaceSm,
                Expanded(child: buttons[4]),
              ],
            ),
    );
  }

  // ============================================================================
  // SECCIÓN 1: INFORMACIÓN PERSONAL
  // ============================================================================

  Widget _buildPersonalSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, size: 20, color: AppColors.primary),
            AppSpacing.horizontalSpaceSm,
            Text('Información Personal', style: AppTextStyles.h6),
          ],
        ),
        AppSpacing.verticalSpaceMd,

        // Nombre
        CustomTextField(
          controller: _nombreController,
          label: 'Nombre *',
          hintText: 'Ej: María',
          errorText: _showValidation ? _errors['nombre'] : null,
        ),
        AppSpacing.verticalSpaceMd,

        // Apellidos (row)
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _apellido1Controller,
                label: 'Primer apellido *',
                hintText: 'Ej: García',
                errorText: _showValidation ? _errors['apellido1'] : null,
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: CustomTextField(
                controller: _apellido2Controller,
                label: 'Segundo apellido',
                hintText: 'Ej: López',
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMd,

        // DNI y Teléfono (row)
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _dniController,
                label: 'DNI/NIE',
                hintText: '12345678A',
                errorText: _showValidation ? _errors['dni'] : null,
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: CustomTextField(
                controller: _telefonoController,
                label: 'Teléfono',
                hintText: '600123456',
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMd,

        // Email
        CustomTextField(
          controller: _emailController,
          label: 'Email *',
          hintText: 'nombre@escuelamusica.com',
          errorText: _showValidation ? _errors['email'] : null,
        ),
      ],
    );
  }

  // ============================================================================
  // SECCIÓN 2: INFORMACIÓN LABORAL
  // ============================================================================

  Widget _buildWorkSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.business, size: 20, color: AppColors.primary),
            AppSpacing.horizontalSpaceSm,
            Text('Información Laboral', style: AppTextStyles.h6),
          ],
        ),
        AppSpacing.verticalSpaceMd,

        // Código empleado (opcional, se genera automático)
        CustomTextField(
          controller: _employeeIdController,
          label: 'Código empleado (opcional)',
          hintText: 'Ej: EMP-009',
        ),
        AppSpacing.verticalSpaceXs,
        Text(
          '✨ Si se deja vacío, se generará automáticamente (EMP-001, EMP-002...)',
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSpaceMd,

        // Empresa
        CustomTextField(
          controller: _empresaController,
          label: 'Empresa',
          enabled: false,
        ),
        AppSpacing.verticalSpaceMd,

        // Departamento y Cargo (row)
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                hint: const Text('Seleccionar'),
                decoration: InputDecoration(
                  labelText: 'Departamento',
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  errorText: _showValidation ? _errors['departamento'] : null,
                ),
                items: _departamentos.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(
                      dept,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartamento = value;
                    if (_showValidation) {
                      _errors.remove('departamento');
                    }
                  });
                },
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: CustomTextField(
                controller: _cargoController,
                label: 'Cargo/Puesto',
                hintText: 'Ej: Profesor Piano',
                errorText: _showValidation ? _errors['cargo'] : null,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMd,
        _buildSupervisorSelector(),
      ],
    );
  }

  // ============================================================================
  // SECCIÓN 3: CONTROL HORARIO
  // ============================================================================

  Widget _buildScheduleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 20, color: AppColors.primary),
            AppSpacing.horizontalSpaceSm,
            Text('Control Horario', style: AppTextStyles.h6),
          ],
        ),
        AppSpacing.verticalSpaceMd,

        // Rol en sistema (Radio buttons)
        Text(
          'Rol en el sistema *',
          style: AppTextStyles.labelMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSpaceSm,
        _buildRoleRadio(theme, 'employee', 'Empleado',
            'Solo puede fichar y ver su información'),
        _buildRoleRadio(theme, 'supervisor', 'Supervisor',
            'Puede ver su equipo y aprobar solicitudes'),
        _buildRoleRadio(
            theme, 'admin', 'Administrador', 'Acceso completo al sistema'),
        AppSpacing.verticalSpaceMd,

        // Fecha inicio y Horario (row)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha de inicio',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaInicio,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _fechaInicio = picked;
                          // Si la fecha de fin queda antes, limpiarla
                          if (_fechaFin != null &&
                              _fechaFin!.isBefore(_fechaInicio)) {
                            _fechaFin = null;
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horario',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Observar plantillas desde Firebase
                  Consumer(
                    builder: (context, ref, _) {
                      final templatesAsync =
                          ref.watch(allScheduleTemplatesProvider);

                      return templatesAsync.when(
                        data: (templates) {
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedScheduleId,
                            hint: const Text('Sin asignar'),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.outline),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Sin asignar'),
                              ),
                              ...templates.map((template) {
                                return DropdownMenuItem(
                                  value: template.scheduleId,
                                  child: Text(
                                    '${template.name} (${template.totalWeeklyHours}h/sem)',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedScheduleId = value);
                            },
                          );
                        },
                        loading: () => const Center(
                          child: SizedBox(
                            height: 48,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (error, _) => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: AppColors.error, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error al cargar plantillas',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceXs,
        Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: AppColors.info),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'El horario puede asignarse después desde el detalle del empleado',
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMd,

        // Calendario laboral
        Text(
          'Calendario laboral',
          style: AppTextStyles.labelMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, _) {
            final calendarsAsync = ref.watch(allCalendarsProvider);

            return calendarsAsync.when(
              data: (calendars) {
                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedCalendarId,
                  hint: const Text('Sin asignar'),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
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
                    setState(() => _selectedCalendarId = value);
                  },
                );
              },
              loading: () => const SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, _) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error al cargar calendarios',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        AppSpacing.verticalSpaceMd,

        // Fecha de fin y Horas semanales (row)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha de fin',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaFin ??
                            _fechaInicio.add(const Duration(days: 365)),
                        firstDate: _fechaInicio,
                        lastDate: DateTime(2040),
                      );
                      if (picked != null) {
                        setState(() => _fechaFin = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_busy,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              key: const Key('fechaFinDisplay'),
                              _fechaFin == null
                                  ? 'Sin definir'
                                  : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _fechaFin == null
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (_fechaFin != null) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => setState(() => _fechaFin = null),
                              child: Icon(Icons.clear,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontalSpaceMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horas semanales',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('weeklyHoursField'),
                    controller: _weeklyHoursController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: '40',
                      errorText:
                          _showValidation ? _errors['weeklyHours'] : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: theme.colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: theme.colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceXs,
        Text(
          'Fecha fin vacía = contrato indefinido. Horas vacías = 40h/semana por defecto.',
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSpaceMd,

        // Estado (Switch)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              Icon(
                _isActive ? Icons.check_circle : Icons.cancel,
                color: _isActive ? AppColors.success : AppColors.error,
                size: 20,
              ),
              AppSpacing.horizontalSpaceSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado del empleado',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isActive
                          ? 'El empleado podrá fichar y acceder al sistema'
                          : 'El empleado no podrá acceder al sistema',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                activeThumbColor: AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupervisorSelector() {
    final isAdminRole = _selectedRole == 'admin';

    return Consumer(
      builder: (context, ref, _) {
        final supervisorsAsync = ref.watch(supervisorsProvider);

        return SupervisorAssignmentField(
          supervisorsAsync: supervisorsAsync,
          selectedSupervisorId: _selectedSupervisorId,
          enabled: !isAdminRole,
          onChanged: isAdminRole
              ? null
              : (value) {
                  setState(() => _selectedSupervisorId = value);
                },
          hintText:
              isAdminRole ? 'No aplica para administradores' : 'Sin asignar',
          helperText: isAdminRole
              ? 'Los administradores no se asignan a un supervisor.'
              : 'Opcional. Define quién supervisará los fichajes de este empleado.',
          emptyText: 'No hay supervisores activos disponibles todavía.',
        );
      },
    );
  }

  Widget _buildRoleRadio(
      ThemeData theme, String value, String title, String description) {
    final isSelected = _selectedRole == value;
    return InkWell(
      onTap: () => setState(() {
        _selectedRole = value;
        if (value == 'admin') {
          _selectedSupervisorId = null;
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.outline,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
}
