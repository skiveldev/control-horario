import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/models/user_model.dart';
import 'supervisor_assignment_field.dart';
import '../../providers/supervisors_provider.dart';
import '../../providers/user_management_provider.dart';

/// Modal para editar la información general de un empleado
///
/// Permite editar:
/// - Datos personales (nombre, apellidos, DNI, teléfono, email)
/// - Datos laborales (cargo, departamento, empresa)
/// - Horas semanales
/// - Estado (activo/inactivo)
///
/// Ejemplo de uso:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => EmployeeInfoEditorModal(employee: employee),
/// );
/// ```
class EmployeeInfoEditorModal extends ConsumerStatefulWidget {
  final UserModel employee;

  const EmployeeInfoEditorModal({
    super.key,
    required this.employee,
  });

  @override
  ConsumerState<EmployeeInfoEditorModal> createState() =>
      _EmployeeInfoEditorModalState();
}

class _EmployeeInfoEditorModalState
    extends ConsumerState<EmployeeInfoEditorModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers - Información Personal
  late TextEditingController _nombreController;
  late TextEditingController _apellido1Controller;
  late TextEditingController _apellido2Controller;
  late TextEditingController _dniController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;

  // Controllers - Información Laboral
  late TextEditingController _cargoController;
  late TextEditingController _departamentoController;
  late TextEditingController _empresaController;
  late TextEditingController _weeklyHoursController;

  // Estado
  late bool _isActive;
  late bool _isSupervisor;
  String? _selectedSupervisorId;
  bool _isLoading = false;

  Object _textValueOrDelete(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? FieldValue.delete() : value;
  }

  @override
  void initState() {
    super.initState();

    // Inicializar controllers con datos actuales
    _nombreController = TextEditingController(text: widget.employee.nombre);
    _apellido1Controller =
        TextEditingController(text: widget.employee.apellido1);
    _apellido2Controller =
        TextEditingController(text: widget.employee.apellido2);
    _dniController = TextEditingController(text: widget.employee.dni);
    _telefonoController = TextEditingController(text: widget.employee.telefono);
    _emailController = TextEditingController(text: widget.employee.email);
    _cargoController = TextEditingController(text: widget.employee.position);
    _departamentoController =
        TextEditingController(text: widget.employee.department);
    _empresaController = TextEditingController(text: widget.employee.empresa);
    _weeklyHoursController = TextEditingController(
      text: widget.employee.weeklyHours.toStringAsFixed(0),
    );
    _isActive = widget.employee.isActive;
    _isSupervisor = widget.employee.isSupervisor;
    _selectedSupervisorId = widget.employee.supervisorId;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      child: Container(
        width: 700,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: AppSpacing.allXl,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  AppSpacing.horizontalSpaceMd,
                  Expanded(
                    child: Text(
                      'Editar Información del Empleado',
                      style: AppTextStyles.h4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                  ),
                ],
              ),

              AppSpacing.verticalSpaceLg,
              Divider(color: cs.outline),
              AppSpacing.verticalSpaceLg,

              // ===== CONTENIDO SCROLLEABLE =====
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECCIÓN 1: Información Personal
                      Text(
                        'Información Personal',
                        style: AppTextStyles.h6,
                      ),
                      AppSpacing.verticalSpaceMd,

                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre *',
                          hintText: 'Ej: María',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),

                      AppSpacing.verticalSpaceMd,

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _apellido1Controller,
                              decoration: const InputDecoration(
                                labelText: 'Primer Apellido *',
                                hintText: 'Ej: García',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El apellido es obligatorio';
                                }
                                return null;
                              },
                              enabled: !_isLoading,
                            ),
                          ),
                          AppSpacing.horizontalSpaceMd,
                          Expanded(
                            child: TextFormField(
                              controller: _apellido2Controller,
                              decoration: const InputDecoration(
                                labelText: 'Segundo Apellido',
                                hintText: 'Ej: López',
                              ),
                              enabled: !_isLoading,
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.verticalSpaceMd,

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dniController,
                              decoration: const InputDecoration(
                                labelText: 'DNI/NIE',
                                hintText: 'Ej: 12345678A',
                                prefixIcon: Icon(Icons.badge),
                              ),
                              enabled: !_isLoading,
                            ),
                          ),
                          AppSpacing.horizontalSpaceMd,
                          Expanded(
                            child: TextFormField(
                              controller: _telefonoController,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                hintText: 'Ej: 612345678',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              enabled: !_isLoading,
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.verticalSpaceMd,

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          hintText: 'ejemplo@empresa.com',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El email es obligatorio';
                          }
                          if (!value.contains('@')) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),

                      AppSpacing.verticalSpaceXl,

                      // SECCIÓN 2: Información Laboral
                      Text(
                        'Información Laboral',
                        style: AppTextStyles.h6,
                      ),
                      AppSpacing.verticalSpaceMd,

                      TextFormField(
                        controller: _cargoController,
                        decoration: const InputDecoration(
                          labelText: 'Cargo/Puesto',
                          hintText: 'Ej: Desarrollador Frontend',
                          prefixIcon: Icon(Icons.work),
                        ),
                        enabled: !_isLoading,
                      ),

                      AppSpacing.verticalSpaceMd,

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _departamentoController,
                              decoration: const InputDecoration(
                                labelText: 'Departamento',
                                hintText: 'Ej: Tecnología',
                                prefixIcon: Icon(Icons.business),
                              ),
                              enabled: !_isLoading,
                            ),
                          ),
                          AppSpacing.horizontalSpaceMd,
                          Expanded(
                            child: TextFormField(
                              controller: _empresaController,
                              decoration: const InputDecoration(
                                labelText: 'Empresa',
                                hintText: 'Ej: Escuela Música',
                                prefixIcon: Icon(Icons.apartment),
                              ),
                              enabled: !_isLoading,
                            ),
                          ),
                        ],
                      ),

                      AppSpacing.verticalSpaceMd,

                      TextFormField(
                        controller: _weeklyHoursController,
                        decoration: const InputDecoration(
                          labelText: 'Horas Semanales Contratadas',
                          hintText: 'Ej: 40',
                          prefixIcon: Icon(Icons.access_time),
                          suffixText: 'horas',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Las horas son obligatorias';
                          }
                          final hours = double.tryParse(value);
                          if (hours == null || hours <= 0) {
                            return 'Ingresa un número válido';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),

                      AppSpacing.verticalSpaceMd,

                      Consumer(
                        builder: (context, ref, _) => SupervisorAssignmentField(
                          supervisorsAsync: ref.watch(supervisorsProvider),
                          selectedSupervisorId: _selectedSupervisorId,
                          excludedUserId: widget.employee.userId,
                          enabled: widget.employee.role != UserRole.admin &&
                              !_isLoading,
                          onChanged: widget.employee.role == UserRole.admin ||
                                  _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedSupervisorId = value;
                                  });
                                },
                          helperText: widget.employee.role == UserRole.admin
                              ? 'Los administradores no se asignan a un supervisor.'
                              : 'Puedes asignar o quitar el supervisor responsable de este empleado.',
                          emptyText:
                              'No hay supervisores activos disponibles todavía.',
                        ),
                      ),

                      AppSpacing.verticalSpaceXs,
                      Text(
                        widget.employee.role == UserRole.admin
                            ? 'Los administradores no se asignan a un supervisor.'
                            : 'Puedes asignar o quitar el supervisor responsable de este empleado.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),

                      AppSpacing.verticalSpaceXl,

                      // SECCIÓN 3: Estado
                      Text(
                        'Estado y permisos',
                        style: AppTextStyles.h6,
                      ),
                      AppSpacing.verticalSpaceMd,

                      SwitchListTile(
                        title: const Text('Puede supervisar equipo'),
                        subtitle: Text(
                          widget.employee.role == UserRole.admin
                              ? 'Los administradores ya tienen permisos superiores.'
                              : _isSupervisor
                                  ? 'Este empleado aparecerá disponible para asignar equipos.'
                                  : 'Activa esta opción para convertirlo en supervisor.',
                        ),
                        value: _isSupervisor,
                        onChanged:
                            widget.employee.role == UserRole.admin || _isLoading
                                ? null
                                : (value) {
                                    setState(() => _isSupervisor = value);
                                  },
                      ),

                      SwitchListTile(
                        title: const Text('Empleado Activo'),
                        subtitle: Text(
                          _isActive
                              ? 'El empleado puede acceder al sistema'
                              : 'El empleado no puede acceder al sistema',
                        ),
                        value: _isActive,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() => _isActive = value);
                              },
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.verticalSpaceLg,
              Divider(color: cs.outline),
              AppSpacing.verticalSpaceMd,

              // ===== BOTONES =====
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  AppSpacing.horizontalSpaceMd,
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _save,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnPrimary,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                    style: ElevatedButton.styleFrom(
                      padding: AppSpacing.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // LÓGICA DE NEGOCIO
  // ==========================================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updates = <String, dynamic>{
        'nombre': _nombreController.text.trim(),
        'apellido1': _apellido1Controller.text.trim(),
        'email': _emailController.text.trim(),
        'isActive': _isActive,
        'isSupervisor': _isSupervisor,
        'weeklyHours': double.parse(_weeklyHoursController.text.trim()),
        'apellido2': _textValueOrDelete(_apellido2Controller),
        'dni': _textValueOrDelete(_dniController),
        'telefono': _textValueOrDelete(_telefonoController),
        'position': _textValueOrDelete(_cargoController),
        'department': _textValueOrDelete(_departamentoController),
        'empresa': _textValueOrDelete(_empresaController),
      };

      updates['supervisorId'] = _selectedSupervisorId ?? FieldValue.delete();

      // Actualizar displayName automáticamente
      final nombre = _nombreController.text.trim();
      final apellido1 = _apellido1Controller.text.trim();
      final apellido2 = _apellido2Controller.text.trim();
      updates['displayName'] = apellido2.isNotEmpty
          ? '$nombre $apellido1 $apellido2'
          : '$nombre $apellido1';

      await ref.read(userManagementProvider.notifier).updateEmployee(
            userId: widget.employee.userId,
            updates: updates,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Información actualizada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellido1Controller.dispose();
    _apellido2Controller.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _cargoController.dispose();
    _departamentoController.dispose();
    _empresaController.dispose();
    _weeklyHoursController.dispose();
    super.dispose();
  }
}
