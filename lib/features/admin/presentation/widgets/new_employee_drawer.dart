import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/breakpoints.dart';
import '../../../../core/constants/mock_schedules.dart';
import '../../../../shared/widgets/buttons/custom_button.dart';
import '../../../../shared/widgets/inputs/custom_text_field.dart';
import '../../../auth/models/user_model.dart';
import '../../providers/user_management_provider.dart';

/// Drawer lateral para crear nuevo empleado
///
/// Características:
/// - Desliza desde la derecha con animación suave (300ms)
/// - Ancho responsive: 100% mobile, 520px desktop
/// - Backdrop oscuro con tap para cerrar
/// - Formulario con 3 secciones: Personal, Laboral, Control Horario
///
/// FASE 2 - SPRINT 1.3: Conectado con Firebase
/// - Crea usuarios reales en Firebase Auth + Firestore
/// - Genera employeeId automático si no se especifica
/// - Genera displayName automático
/// - Solo 3 campos obligatorios: Nombre, Apellido1, Email
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
    });

    return _errors.isEmpty;
  }

  // ============================================================================
  // MÉTODOS DE GUARDADO - FASE 2 (Sprint 1.3)
  // ============================================================================

  Future<void> _save() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Llamar al provider de Riverpod para crear usuario
    final result = await _createEmployeeInFirebase();

    if (result != null) {
      if (mounted) {
        // Mostrar credenciales temporales
        _showSuccessDialog(result);
        widget.onEmployeeCreated?.call();
        widget.onClose();
      }
    }
  }

  Future<void> _saveAndAddAnother() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Llamar al provider de Riverpod para crear usuario
    final result = await _createEmployeeInFirebase();

    if (result != null) {
      if (mounted) {
        // Mostrar credenciales temporales (más breve)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Usuario creado: ${_emailController.text}\nContraseña: ${result['temporaryPassword']}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'COPIAR',
              textColor: AppColors.surface,
              onPressed: () {
                // TODO: Copiar al portapapeles
              },
            ),
          ),
        );

        widget.onEmployeeCreated?.call();
        _clearForm();
      }
    }
  }

  /// Crea el empleado en Firebase usando el provider
  Future<Map<String, String>?> _createEmployeeInFirebase() async {
    // Convertir role de String a UserRole
    UserRole role = UserRole.employee;
    switch (_selectedRole) {
      case 'admin':
        role = UserRole.admin;
        break;
      case 'rrhh':
        role = UserRole.rrhh;
        break;
      default:
        role = UserRole.employee;
    }

    // Parsear weeklyHours (default 40.0 si está vacío)
    final weeklyHours = _weeklyHoursController.text.trim().isEmpty
        ? 40.0
        : double.tryParse(_weeklyHoursController.text.trim()) ?? 40.0;

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
                // ✅ Los 4 campos que faltaban
                empresa: _empresaController.text.trim().isEmpty
                    ? null
                    : _empresaController.text.trim(),
                scheduleId: _selectedScheduleId,
                fechaInicio: _fechaInicio,
                fechaFin: _fechaFin,
              );

      if (result == null) {
        // Hubo un error, mostrar mensaje
        final error = ref.read(userManagementProvider).error;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Error desconocido al crear usuario'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 10), // Más tiempo para leer
            ),
          );

          // DEBUGGING: Imprimir error en consola
          debugPrint('❌ ERROR AL CREAR USUARIO: $error');
        }
      }

      return result;
    } catch (e) {
      // DEBUGGING: Imprimir error completo en consola
      debugPrint('❌ EXCEPCIÓN AL CREAR USUARIO: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 10),
          ),
        );
      }
      return null;
    }
  }

  /// Muestra un diálogo con las credenciales temporales
  void _showSuccessDialog(Map<String, String> credentials) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Text(
                'Usuario Creado',
                style: AppTextStyles.h3,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Credenciales de acceso temporal:',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.email,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          _emailController.text.trim(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.lock,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          credentials['temporaryPassword'] ?? '',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              '⚠️ El empleado deberá cambiar la contraseña en su primer acceso.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Copiar credenciales al portapapeles
              Navigator.of(context).pop();
            },
            child: const Text('COPIAR CREDENCIALES'),
          ),
          CustomButton(
            text: 'CERRAR',
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  // TODO [COMENTADO Sprint 1.3]: Ya no se usa, se crea directamente en Firebase
  // El método _buildEmployeeData() se reemplazó por _createEmployeeInFirebase()
  /*
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
  */

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

  // TODO [COMENTADO Sprint 1.3]: Ya no se usa, se genera automáticamente en Firebase
  /*
  void _generateEmployeeId() {
    setState(() {
      _employeeIdController.text = MockData.generateEmployeeId();
    });
  }
  */

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

        // Employee ID con botón generar (COMENTADO Sprint 1.3 - se genera automático)
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.end,
        //   children: [
        //     Expanded(
        //       flex: 2,
        //       child: CustomTextField(
        //         controller: _employeeIdController,
        //         label: 'Código empleado',
        //         hintText: 'Ej: EMP-009',
        //       ),
        //     ),
        //     AppSpacing.horizontalSpaceSm,
        //     CustomButton(
        //       text: 'Generar',
        //       variant: ButtonVariant.outline,
        //       onPressed: _generateEmployeeId,
        //     ),
        //   ],
        // ),

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
                  labelText: 'Departamento',
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
                label: 'Cargo/Puesto',
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
