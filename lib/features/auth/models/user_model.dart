import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Modelo de Usuario del sistema
///
/// Representa a un empleado con su información laboral y de autenticación.
/// Usa Freezed para inmutabilidad y JSON serialization.
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String userId,
    required String employeeId,
    required String email,
    required String displayName,
    required UserRole role,
    required double weeklyHours,
    @Default(true) bool isActive,
    required DateTime createdAt,

    // Información adicional del empleado
    String? position, // Cargo (ej: "Desarrolladora Frontend Senior")
    String? department, // Departamento (ej: "Tecnología")
    String? schedule, // Horario laboral (ej: "09:00 - 18:00")
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

    return UserModel(
      userId: doc.id,
      employeeId: data['employeeId'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: UserRole.values.byName(data['role'] ?? 'employee'),
      weeklyHours: (data['weeklyHours'] ?? 40).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: createdAtDate,
      position: data['position'] as String?,
      department: data['department'] as String?,
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
