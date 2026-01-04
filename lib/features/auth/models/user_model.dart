import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Modelo de Usuario del sistema
///
/// Representa a un empleado con su información laboral y de autenticación.
/// Usa Freezed para inmutabilidad y JSON serialization.
///
/// DÍA 4: Actualizado con estructura híbrida completa
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    // === Campos básicos obligatorios ===
    required String userId,
    required String employeeId,
    required String email,
    required String displayName,
    required UserRole role,
    required double weeklyHours,
    @Default(true) bool isActive,
    required DateTime createdAt,

    // === Información personal (opcional) ===
    String? dni, // DNI/NIE del empleado
    String? telefono, // Teléfono de contacto

    // === Información laboral (opcional, desnormalizado) ===
    String? position, // Cargo (ej: "Desarrollador Frontend Senior")
    String? department, // Departamento (ej: "Tecnología", "Docente")

    // === Control horario (opcional, híbrido) ===
    String?
        scheduleId, // Referencia a plantilla de horario (ej: "template_40h_001")
    DateTime?
        fechaInicio, // Fecha de inicio en la APLICACIÓN (no en la empresa)
    DateTime? fechaFin, // Fecha de fin en la APLICACIÓN (baja/baja temporal)

    // DEPRECATED: Mantener por compatibilidad con código existente
    @Deprecated('Usar scheduleId en su lugar')
    String? schedule, // Horario en formato texto (ej: "09:00 - 18:00")
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Crear UserModel desde documento de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Manejar createdAt que puede ser null o Timestamp
    DateTime createdAtDate;
    if (data['createdAt'] != null) {
      createdAtDate = (data['createdAt'] as Timestamp).toDate();
    } else {
      // Si no existe, usar la fecha actual
      createdAtDate = DateTime.now();
    }

    // Manejar fechaInicio que puede ser null o Timestamp
    DateTime? fechaInicioDate;
    if (data['fechaInicio'] != null) {
      fechaInicioDate = (data['fechaInicio'] as Timestamp).toDate();
    }

    // Manejar fechaFin que puede ser null o Timestamp
    DateTime? fechaFinDate;
    if (data['fechaFin'] != null) {
      fechaFinDate = (data['fechaFin'] as Timestamp).toDate();
    }

    return UserModel(
      userId: doc.id,
      employeeId: data['employeeId'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: UserRole.values.byName(data['role'] ?? 'employee'),
      weeklyHours: (data['weeklyHours'] ?? 40).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: createdAtDate,

      // Información personal
      dni: data['dni'] as String?,
      telefono: data['telefono'] as String?,

      // Información laboral
      position: data['position'] as String?,
      department: data['department'] as String?,

      // Control horario
      scheduleId: data['scheduleId'] as String?,
      fechaInicio: fechaInicioDate,
      fechaFin: fechaFinDate,

      // DEPRECATED: Mantener por compatibilidad
      schedule: data['schedule'] as String?,
    );
  }
}

/// Roles de usuario en el sistema
enum UserRole {
  /// Empleado estándar - puede ver sus propios registros y fichar
  employee,

  /// RRHH - puede ver todos los empleados y gestionar horarios
  rrhh,

  /// Admin - control total del sistema
  admin,
}
