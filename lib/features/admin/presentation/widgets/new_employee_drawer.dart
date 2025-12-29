import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_data.dart';
import '../../../../core/constants/mock_schedules.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';

/// Drawer lateral para crear nuevo empleado
///
/// Características:
/// - Desliza desde la derecha con animación suave (300ms)
/// - Ancho responsive: 100% mobile, 520px desktop
/// - Backdrop oscuro con tap para cerrar
/// - Formulario con 3 secciones: Personal, Laboral, Control Horario
///
/// FASE 1: Solo UI/UX con datos mock
/// TODO [FASE-2]: Conectar con EmployeeNotifier (Riverpod)
class NewEmployeeDrawer extends StatefulWidget {
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
  State<NewEmployeeDrawer> createState() => _NewEmployeeDrawerState();
}

class _NewEmployeeDrawerState extends State<NewEmployeeDrawer> {
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
  String _selectedRole = 'employee';
  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;
  String? _selectedScheduleId;
  bool _isActive = true;
  final _weeklyHoursController = TextEditingController();

  // ============================================================================
  // VALIDATION STATE
  // ============================================================================
  final Map<String, String?> _errors = {};
  bool _showValidation = false;

  @override
  void dispose() {
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

      // Validar campos obligatorios
      if (_nombreController.text.trim().isEmpty) {
        _errors['nombre'] = 'Campo obligatorio';
      }
      if (_apellido1Controller.text.trim().isEmpty) {
        _errors['apellido1'] = 'Campo obligatorio';
      }
      if (_dniController.text.trim().isEmpty) {
        _errors['dni'] = 'Campo obligatorio';
      } else if (_dniController.text.trim().length < 8) {
        _errors['dni'] = 'DNI/NIE muy corto';
      }
      if (_emailController.text.trim().isEmpty) {
        _errors['email'] = 'Campo obligatorio';
      } else if (!_emailController.text.contains('@')) {
        _errors['email'] = 'Email inválido';
      }
      if (_selectedDepartamento == null) {
        _errors['departamento'] = 'Selecciona un departamento';
      }
      if (_cargoController.text.trim().isEmpty) {
        _errors['cargo'] = 'Campo obligatorio';
      }
    });

    return _errors.isEmpty;
  }

  // ============================================================================
  // MÉTODOS DE GUARDADO
  // ============================================================================

  void _save() {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newEmployee = _buildEmployeeData();
    MockData.addEmployee(newEmployee);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Empleado ${newEmployee['displayName']} creado'),
        backgroundColor: AppColors.success,
      ),
    );

    widget.onEmployeeCreated?.call();
    widget.onClose();
  }

  void _saveAndAddAnother() {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newEmployee = _buildEmployeeData();
    MockData.addEmployee(newEmployee);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Empleado ${newEmployee['displayName']} creado'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onEmployeeCreated?.call();
    _clearForm();
  }

  Map<String, dynamic> _buildEmployeeData() {
    final nombre = _nombreController.text.trim();
    final apellido1 = _apellido1Controller.text.trim();
    final apellido2 = _apellido2Controller.text.trim();

    // Auto-generar employeeId si está vacío
    final employeeId = _employeeIdController.text.trim().isEmpty
        ? MockData.generateEmployeeId()
        : _employeeIdController.text.trim();

    // Auto-generar displayName
    final displayName = apellido2.isEmpty
        ? '$nombre $apellido1'
        : '$nombre $apellido1 $apellido2';

    return {
      // Sección 1: Información Personal
      'id': employeeId,
      'name': displayName,
      'nombre': nombre,
      'apellido1': apellido1,
      'apellido2': apellido2.isEmpty ? null : apellido2,
      'dni': _dniController.text.trim(),
      'telefono': _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      'email': _emailController.text.trim(),

      // Sección 2: Información Laboral
      'position': _cargoController.text.trim(),
      'department': _selectedDepartamento,
      'empresa': _empresaController.text.trim(),

      // Sección 3: Control Horario
      'role': _selectedRole,
      'fechaInicio': _fechaInicio.toIso8601String(),
      'fechaFin': _fechaFin?.toIso8601String(),
      'scheduleId': _selectedScheduleId,
      'weeklyHours': _weeklyHoursController.text.trim().isEmpty
          ? null
          : double.tryParse(_weeklyHoursController.text.trim()),

      // Sección 4: Auto-generada
      'displayName': displayName,
      'createdAt': DateTime.now().toIso8601String(),
      'isActive': _isActive,
      'status': _isActive ? 'activo' : 'inactivo',
      'isClockedIn': false,
    };
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
      _weeklyHoursController.clear();
      _isActive = true;
      _errors.clear();
      _showValidation = false;
    });
  }

  void _generateEmployeeId() {
    setState(() {
      _employeeIdController.text = MockData.generateEmployeeId();
    });
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth < Breakpoints.tablet ? screenWidth : 650.0;

    return Stack(
      children: [
        // Backdrop
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: widget.isOpen ? 0.5 : 0.0,
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.black,
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
              color: AppColors.surface,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.allLg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPersonalSection(),
                          AppSpacing.verticalSpaceXxl,
                          _buildWorkSection(),
                          AppSpacing.verticalSpaceXxl,
                          _buildScheduleSection(),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
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
            onPressed: widget.onClose,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      padding: AppSpacing.allLg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            text: 'Cancelar',
            variant: ButtonVariant.text,
            onPressed: widget.onClose,
          ),
          AppSpacing.horizontalSpaceSm,
          CustomButton(
            text: 'Guardar y Añadir',
            variant: ButtonVariant.outline,
            onPressed: _saveAndAddAnother,
          ),
          AppSpacing.horizontalSpaceSm,
          CustomButton(
            text: 'Guardar',
            variant: ButtonVariant.primary,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // SECCIÓN 1: INFORMACIÓN PERSONAL
  // ============================================================================

  Widget _buildPersonalSection() {
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
                label: 'DNI/NIE *',
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

  Widget _buildWorkSection() {
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

        // Employee ID con botón generar
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: _employeeIdController,
                label: 'Código empleado',
                hintText: 'Ej: EMP-009',
              ),
            ),
            AppSpacing.horizontalSpaceSm,
            CustomButton(
              text: 'Generar',
              variant: ButtonVariant.outline,
              onPressed: _generateEmployeeId,
            ),
          ],
        ),
        AppSpacing.verticalSpaceXs,
        Text(
          'Si se deja vacío, se generará automáticamente',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
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
                  labelText: 'Departamento *',
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border),
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
                label: 'Cargo/Puesto *',
                hintText: 'Ej: Profesor Piano',
                errorText: _showValidation ? _errors['cargo'] : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================================
  // SECCIÓN 3: CONTROL HORARIO
  // ============================================================================

  Widget _buildScheduleSection() {
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
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.verticalSpaceSm,
        _buildRoleRadio(
            'employee', 'Empleado', 'Solo puede fichar y ver su información'),
        _buildRoleRadio('supervisor', 'Supervisor',
            'Puede ver su equipo y aprobar solicitudes'),
        _buildRoleRadio('admin', 'Administrador', 'Acceso completo al sistema'),
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
                      color: AppColors.textSecondary,
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
                        setState(() => _fechaInicio = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                            style: AppTextStyles.bodyMedium,
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
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    hint: const Text('Sin asignar'),
                    decoration: InputDecoration(
                      hintText: _selectedScheduleId,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin asignar'),
                      ),
                      ...MockSchedules.templates.map((template) {
                        return DropdownMenuItem(
                          value: template['id'] as String,
                          child: Text(
                            '${template['name']} (${template['weeklyHours']}h/sem)',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedScheduleId = value);
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
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
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
                      color: AppColors.textSecondary,
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
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_busy,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            _fechaFin == null
                                ? 'Sin definir'
                                : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _fechaFin == null
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (_fechaFin != null) ...[
                            const Spacer(),
                            InkWell(
                              onTap: () => setState(() => _fechaFin = null),
                              child: Icon(Icons.clear,
                                  size: 16, color: AppColors.textSecondary),
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
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _weeklyHoursController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: '40',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.border),
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
          'Dejar vacío para indefinido. Horas se calculan automáticamente del horario.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        AppSpacing.verticalSpaceMd,

        // Estado (Switch)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
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
                        color: AppColors.textSecondary,
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

  Widget _buildRoleRadio(String value, String title, String description) {
    final isSelected = _selectedRole == value;
    return InkWell(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : Colors.transparent,
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
                  color: isSelected ? AppColors.primary : AppColors.border,
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
                      color: AppColors.textSecondary,
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
