import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/services/provisioning_service.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

part 'user_management_provider.g.dart';

/// The application composition root for employee provisioning.
///
/// Keeping this hand-written provider outside generated output makes the
/// workflow explicitly overrideable in widget and provider tests.
final provisioningWorkflowProvider = Provider<ProvisioningWorkflow>((ref) {
  return ProvisioningWorkflow(
    ProvisioningService(FirebaseCallableTransport()),
    storage: SharedPreferencesProvisioningOperationStorage(),
    operationIdFactory: _newUuidV4,
  );
});

String _newUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = StringBuffer();
  for (final byte in bytes) {
    hex.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  final value = hex.toString();
  return '${value.substring(0, 8)}-'
      '${value.substring(8, 12)}-'
      '${value.substring(12, 16)}-'
      '${value.substring(16, 20)}-'
      '${value.substring(20)}';
}

/// Typed provisioning state for employee creation.
class UserCreationState {
  const UserCreationState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  final bool isLoading;
  final ProvisioningResult? result;
  final ProvisioningFailure? error;
}

/// Manages employee creation and existing employee updates for the admin panel.
@riverpod
class UserManagement extends _$UserManagement {
  @override
  UserCreationState build() {
    ref.listen(authStateProvider, (previous, next) {
      if (previous?.valueOrNull != null && next.valueOrNull == null) {
        ref.read(provisioningWorkflowProvider).cancel();
      }
    });
    return const UserCreationState();
  }

  /// Creates an employee through the durable provisioning workflow.
  Future<ProvisioningResult?> createEmployee({
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
    String? calendarId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    UserRole role = UserRole.employee,
    bool isSupervisor = false,
    String? supervisorId,
    bool isActive = true,
  }) async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null || currentUser.role != UserRole.admin) {
      const failure = ProvisioningFailure.permissionDenied();
      state = const UserCreationState(error: failure);
      return failure;
    }
    if (email.trim().isEmpty ||
        nombre.trim().isEmpty ||
        apellido1.trim().isEmpty) {
      const failure = ProvisioningFailure.invalidArgument();
      state = const UserCreationState(error: failure);
      return failure;
    }

    state = const UserCreationState(isLoading: true);
    try {
      final result = await ref.read(provisioningWorkflowProvider).submit(
            (operationId) => ProvisioningRequest(
              operationId: operationId,
              email: email.trim(),
              nombre: nombre.trim(),
              apellido1: apellido1.trim(),
              apellido2: apellido2,
              employeeId: employeeId,
              weeklyHours: weeklyHours,
              dni: dni,
              telefono: telefono,
              cargo: cargo,
              departamento: departamento,
              empresa: empresa,
              scheduleId: scheduleId,
              calendarId: calendarId,
              fechaInicio: fechaInicio?.toIso8601String(),
              fechaFin: fechaFin?.toIso8601String(),
              role: role.name,
              isSupervisor: isSupervisor,
              supervisorId: supervisorId,
              isActive: isActive,
            ),
          );
      state = UserCreationState(
        result: result,
        error: result is ProvisioningFailure ? result : null,
      );
      return result;
    } catch (_) {
      const failure = ProvisioningFailure.unknown();
      state = const UserCreationState(error: failure);
      return failure;
    }
  }

  void cancelObservation() => ref.read(provisioningWorkflowProvider).cancel();

  void reset() => state = const UserCreationState();

  void clearError() {
    state = UserCreationState(result: state.result);
  }

  /// Updates an existing employee without changing its legacy update behavior.
  Future<void> updateEmployee({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null || currentUser.role != UserRole.admin) {
      throw Exception(
        'Sin permisos: solo administradores pueden actualizar empleados',
      );
    }

    state = const UserCreationState(isLoading: true);
    try {
      final firestore = ref.read(firestoreProvider);
      await firestore.collection('users').doc(userId).update(updates);
      state = const UserCreationState();
    } catch (error) {
      state = const UserCreationState(error: ProvisioningFailure.unknown());
      rethrow;
    }
  }
}
