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
  const UserModel._();

  const factory UserModel({
    // === Campos básicos obligatorios ===
    required String userId,
    required String employeeId,
    required String email,
    required String displayName,
    required UserRole role,
    @Default(false) bool isSupervisor,
    String? supervisorId,
    required double weeklyHours,
    @Default(true) bool isActive,
    required DateTime createdAt,

    // === Información personal (opcional) ===
    String? nombre, // Nombre (ej: "María")
    String? apellido1, // Primer apellido (ej: "García")
    String? apellido2, // Segundo apellido (ej: "López")
    String? dni, // DNI/NIE del empleado
    String? telefono, // Teléfono de contacto

    // === Información laboral (opcional, desnormalizado) ===
    String? position, // Cargo (ej: "Desarrollador Frontend Senior")
    String? department, // Departamento (ej: "Tecnología", "Docente")
    String? empresa, // Empresa (ej: "Escuela Música")

    // === Control horario (opcional, híbrido) ===
    String?
        scheduleId, // Referencia a plantilla de horario (ej: "schedule_40h_9_17")
    @Default('template')
    String
        scheduleType, // Tipo de horario: "template" (usa scheduleId) | "custom" (usa customSchedule)
    Map<String, dynamic>?
        customSchedule, // Horario personalizado (solo si scheduleType = "custom")
    String? calendarId, // Referencia al calendario laboral asignado
    // ⚠️ FECHAS DE ALTA EN LA APLICACIÓN (NO en la empresa)
    DateTime?
        fechaInicio, // Fecha desde la cual el empleado puede FICHAR en la app
    DateTime?
        fechaFin, // Fecha hasta la cual el empleado puede FICHAR (baja app)

    // DEPRECATED: Mantener por compatibilidad con código existente
    @Deprecated('Usar scheduleId + scheduleType en su lugar')
    String? schedule, // Horario en formato texto (ej: "09:00 - 18:00")
  }) = _UserModel;

  /// Obtiene el nombre completo del usuario
  ///
  /// Prioriza construir desde campos individuales (nombre + apellidos).
  /// Si no existen, usa displayName como fallback.
  ///
  /// Útil para usuarios antiguos donde displayName puede estar incompleto.
  String get fullName {
    // Si existen campos individuales, construir nombre completo
    if (nombre != null && apellido1 != null) {
      final nombreCompleto = nombre!.trim();
      final primerApellido = apellido1!.trim();
      final segundoApellido = apellido2?.trim() ?? '';

      if (segundoApellido.isNotEmpty) {
        return '$nombreCompleto $primerApellido $segundoApellido';
      }
      return '$nombreCompleto $primerApellido';
    }

    // Fallback a displayName
    return displayName;
  }

  /// Indica si el usuario puede acceder a funciones de supervision de equipo.
  bool get canSuperviseTeam =>
      isActive && (role == UserRole.admin || isSupervisor);

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Crear UserModel desde documento de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final createdAtDate =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final fechaInicioDate = (data['fechaInicio'] as Timestamp?)?.toDate();
    final fechaFinDate = (data['fechaFin'] as Timestamp?)?.toDate();

    return UserModel(
      userId: doc.id,
      employeeId: data['employeeId'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: _roleFromString(data['role'] as String?),
      isSupervisor: data['isSupervisor'] as bool? ?? false,
      supervisorId: data['supervisorId'] as String?,
      weeklyHours: (data['weeklyHours'] ?? 40).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: createdAtDate,

      // Compatibilidad con múltiples formatos de nombres de campos
      nombre: data['nombre'] as String? ?? data['Nombre'] as String?,
      apellido1: data['apellido1'] as String? ??
          data['Apellido1'] as String? ??
          data['Primer Apellido'] as String?,
      apellido2: data['apellido2'] as String? ??
          data['Apellido2'] as String? ??
          data['Segundo Apellido'] as String?,
      dni: data['dni'] as String? ?? data['DNI/NIE'] as String?,
      telefono: data['telefono'] as String? ?? data['Telefono'] as String?,

      // Compatibilidad con campos en español (usuarios antiguos) e inglés (usuarios nuevos)
      position: data['position'] as String? ??
          data['Cargo/Puesto'] as String? ??
          data['cargo'] as String?,
      department: data['department'] as String? ??
          data['Departamento'] as String? ??
          data['departamento'] as String?,
      empresa: data['empresa'] as String? ?? data['Empresa'] as String?,

      scheduleId: data['scheduleId'] as String?,
      scheduleType: data['scheduleType'] as String? ?? 'template',
      customSchedule: data['customSchedule'] as Map<String, dynamic>?,
      calendarId: data['calendarId'] as String?,
      fechaInicio: fechaInicioDate,
      fechaFin: fechaFinDate,

      // DEPRECATED: Mantener por compatibilidad
      schedule: data['schedule'] as String?,
    );
  }

  /// Serializar a Map para guardar en Firestore.
  ///
  /// Convierte DateTime → Timestamp para todos los campos de fecha,
  /// usando las mismas claves literales que fromFirestore.
  Map<String, dynamic> toFirestore() {
    return {
      'employeeId': employeeId,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'isSupervisor': isSupervisor,
      if (supervisorId != null) 'supervisorId': supervisorId,
      'weeklyHours': weeklyHours,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      if (nombre != null) 'nombre': nombre,
      if (apellido1 != null) 'apellido1': apellido1,
      if (apellido2 != null) 'apellido2': apellido2,
      if (dni != null) 'dni': dni,
      if (telefono != null) 'telefono': telefono,
      if (position != null) 'position': position,
      if (department != null) 'department': department,
      if (empresa != null) 'empresa': empresa,
      if (scheduleId != null) 'scheduleId': scheduleId,
      'scheduleType': scheduleType,
      if (customSchedule != null) 'customSchedule': customSchedule,
      if (calendarId != null) 'calendarId': calendarId,
      if (fechaInicio != null) 'fechaInicio': Timestamp.fromDate(fechaInicio!),
      if (fechaFin != null) 'fechaFin': Timestamp.fromDate(fechaFin!),
      if (schedule != null) 'schedule': schedule,
    };
  }
}

/// Convierte un string de Firestore al enum UserRole con fallback seguro.
UserRole _roleFromString(String? value) {
  try {
    return UserRole.values.byName(value ?? 'employee');
  } catch (_) {
    return UserRole.employee;
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
