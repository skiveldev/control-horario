import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/models/user_model.dart';

part 'user_management_provider.g.dart';

/// Estado de creación de usuario
///
/// Gestiona el estado durante el proceso de creación
class UserCreationState {
  final bool isLoading;
  final String? error;
  final Map<String, String>? result; // userId + temporaryPassword

  const UserCreationState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  UserCreationState copyWith({
    bool? isLoading,
    String? error,
    Map<String, String>? result,
  }) {
    return UserCreationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

/// Provider para gestión de usuarios (creación, edición, eliminación)
///
/// Gestiona todas las operaciones CRUD de usuarios desde el panel admin.
/// Usa EmployeeCreationService para interactuar con Firebase.
@riverpod
class UserManagement extends _$UserManagement {
  @override
  UserCreationState build() {
    return const UserCreationState();
  }

  /// Crea un nuevo empleado en el sistema
  ///
  /// Parámetros obligatorios:
  /// - [email]: Email del empleado
  /// - [nombre]: Nombre del empleado
  /// - [apellido1]: Primer apellido del empleado
  ///
  /// Parámetros opcionales:
  /// - [apellido2]: Segundo apellido
  /// - [employeeId]: ID manual (si null, se auto-genera)
  /// - [weeklyHours]: Horas semanales (default: 40.0)
  /// - [dni]: DNI del empleado
  /// - [telefono]: Teléfono
  /// - [cargo]: Cargo/posición
  /// - [departamento]: Departamento
  /// - [empresa]: Empresa (por defecto "Escuela Música")
  /// - [scheduleId]: ID de plantilla de horario
  /// - [fechaInicio]: Fecha de inicio en la APLICACIÓN
  /// - [fechaFin]: Fecha de fin en la APLICACIÓN (baja/baja temporal)
  /// - [role]: Rol del usuario (default: employee)
  ///
  /// Retorna el resultado con userId y contraseña temporal, o null si hay error
  Future<Map<String, String>?> createEmployee({
    required String email,
    required String nombre,
    required String apellido1,
    String? apellido2,
    String? employeeId,
    double? weeklyHours,
    String? dni,
    String? telefono,
    String? cargo,
    String? departamento,
    String? empresa,
    String? scheduleId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    UserRole role = UserRole.employee,
  }) async {
    // DEBUGGING
    debugPrint('🔄 UserManagementProvider.createEmployee() iniciado');
    debugPrint('📧 Email: $email');
    debugPrint('👤 Nombre: $nombre $apellido1');

    // Validaciones básicas
    if (email.trim().isEmpty) {
      state = state.copyWith(error: 'El email es obligatorio');
      return null;
    }
    if (nombre.trim().isEmpty) {
      state = state.copyWith(error: 'El nombre es obligatorio');
      return null;
    }
    if (apellido1.trim().isEmpty) {
      state = state.copyWith(error: 'El primer apellido es obligatorio');
      return null;
    }

    // Verificar que el email no esté ya registrado
    // TODO: Implementar verificación en Firestore antes de crear en Auth
    // (por ahora el servicio ya maneja esto)

    state = state.copyWith(isLoading: true, error: null);
    debugPrint('⏳ Estado: isLoading = true');

    try {
      final service = ref.read(employeeCreationServiceProvider);
      debugPrint('📞 Llamando a employeeCreationService.createEmployee()...');

      final result = await service.createEmployee(
        email: email,
        nombre: nombre,
        apellido1: apellido1,
        apellido2: apellido2,
        employeeId: employeeId,
        weeklyHours: weeklyHours,
        dni: dni,
        telefono: telefono,
        cargo: cargo,
        departamento: departamento,
        empresa: empresa,
        scheduleId: scheduleId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        role: role,
      );

      debugPrint('✅ Usuario creado exitosamente');
      debugPrint('🆔 userId: ${result['userId']}');
      debugPrint('🔑 password: ${result['temporaryPassword']}');

      state = state.copyWith(
        isLoading: false,
        result: result,
        error: null,
      );

      return result;
    } catch (e) {
      debugPrint('❌ ERROR en createEmployee: $e');
      debugPrint('❌ Tipo de error: ${e.runtimeType}');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Resetea el estado del provider
  ///
  /// Útil para limpiar errores o resultados después de mostrarlos
  void reset() {
    state = const UserCreationState();
  }

  /// Limpia solo el error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
