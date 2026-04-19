import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/models/user_model.dart';
import 'schedule_service.dart';
import 'calendar_service.dart';

part 'firebase_service.g.dart';

/// Provider para la instancia de Firestore
///
/// Proporciona acceso a la base de datos Firestore.
/// Se puede configurar para usar emulator en desarrollo.
@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

/// Provider para la instancia de Firebase Auth
///
/// Proporciona acceso al sistema de autenticación.
/// Se puede configurar para usar emulator en desarrollo.
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

// ============================================================================
// CREACIÓN DE USUARIOS - SPRINT 1.1
// ============================================================================

/// Genera una contraseña temporal aleatoria segura
///
/// Formato: 8 caracteres alfanuméricos (mayúsculas, minúsculas, números)
/// Ejemplo: "Abc123Xy"
String _generateTemporaryPassword() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random.secure();
  return List.generate(8, (index) => chars[random.nextInt(chars.length)])
      .join();
}

/// Genera el siguiente employeeId secuencial
///
/// Busca el último employeeId existente y genera el siguiente.
/// Formato: "EMP-001", "EMP-002", etc.
///
/// Si no hay empleados, comienza en "EMP-001"
///
/// TODO [COMENTADO - DÍA 6]: Por ahora no se usa, se asignarán IDs en lote
/// Para re-activar cuando se implemente el script de asignación masiva
/* 
Future<String> _generateNextEmployeeId(FirebaseFirestore firestore) async {
  // Buscar el último employeeId
  final snapshot = await firestore
      .collection('users')
      .orderBy('employeeId', descending: true)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) {
    return 'EMP-001';
  }

  // Extraer el número del último employeeId
  final lastEmployeeId = snapshot.docs.first.data()['employeeId'] as String?;
  
  if (lastEmployeeId == null || !lastEmployeeId.startsWith('EMP-')) {
    return 'EMP-001';
  }

  // Extraer el número y sumar 1
  final numberPart = lastEmployeeId.substring(4); // "001"
  final lastNumber = int.tryParse(numberPart) ?? 0;
  final nextNumber = lastNumber + 1;

  // Formatear con padding de ceros
  return 'EMP-${nextNumber.toString().padLeft(3, '0')}';
}
*/

/// Construye el displayName a partir de nombre y apellidos
///
/// Formato:
/// - Solo apellido1: "Nombre Apellido1"
/// - Con apellido2: "Nombre Apellido1 Apellido2"
String _buildDisplayName({
  required String nombre,
  required String apellido1,
  String? apellido2,
}) {
  if (apellido2 != null && apellido2.trim().isNotEmpty) {
    return '$nombre $apellido1 $apellido2';
  }
  return '$nombre $apellido1';
}

Map<String, dynamic> buildEmployeeDocumentData({
  required String userId,
  required String employeeId,
  required String email,
  required String displayName,
  required UserRole role,
  required bool isSupervisor,
  required bool isActive,
  required double weeklyHours,
  required String nombre,
  required String apellido1,
  String? apellido2,
  String? dni,
  String? telefono,
  String? cargo,
  String? departamento,
  String? empresa,
  String? scheduleId,
  String? calendarId,
  String? supervisorId,
  DateTime? fechaInicio,
  DateTime? fechaFin,
  Object? createdAt,
}) {
  return {
    'userId': userId,
    'employeeId': employeeId,
    'email': email.trim(),
    'displayName': displayName,
    'role': role.name,
    'isSupervisor': isSupervisor,
    if (supervisorId != null && supervisorId.trim().isNotEmpty)
      'supervisorId': supervisorId.trim(),
    'weeklyHours': weeklyHours,
    'isActive': isActive,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    if (nombre.trim().isNotEmpty) 'nombre': nombre.trim(),
    if (apellido1.trim().isNotEmpty) 'apellido1': apellido1.trim(),
    if (apellido2 != null && apellido2.trim().isNotEmpty)
      'apellido2': apellido2.trim(),
    if (dni != null && dni.trim().isNotEmpty) 'dni': dni.trim(),
    if (telefono != null && telefono.trim().isNotEmpty)
      'telefono': telefono.trim(),
    if (cargo != null && cargo.trim().isNotEmpty) 'position': cargo.trim(),
    if (departamento != null && departamento.trim().isNotEmpty)
      'department': departamento.trim(),
    if (empresa != null && empresa.trim().isNotEmpty) 'empresa': empresa.trim(),
    if (scheduleId != null && scheduleId.trim().isNotEmpty)
      'scheduleId': scheduleId.trim(),
    if (calendarId != null && calendarId.trim().isNotEmpty)
      'calendarId': calendarId.trim(),
    if (fechaInicio != null) 'fechaInicio': Timestamp.fromDate(fechaInicio),
    if (fechaFin != null) 'fechaFin': Timestamp.fromDate(fechaFin),
  };
}

/// Provider para el servicio de creación de empleados
@riverpod
EmployeeCreationService employeeCreationService(
    EmployeeCreationServiceRef ref) {
  return EmployeeCreationService(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
}

/// Exception lanzada cuando la sesión del admin expira durante la creación de empleado.
///
/// Ocurre cuando la creación no puede aislarse en una sesión secundaria y
/// Firebase Auth reemplaza la sesión activa por la del usuario recién creado.
///
/// Incluye [employeeData] con los datos del empleado creado, para que la UI
/// pueda mostrar las credenciales antes de redirigir al login.
class AdminSessionExpiredException implements Exception {
  final String message;
  final Map<String, String> employeeData;

  const AdminSessionExpiredException({
    required this.employeeData,
    this.message =
        'Sesión del administrador cerrada. Por favor, vuelva a iniciar sesión.',
  });

  @override
  String toString() =>
      'AdminSessionExpiredException: $message\nEmpleado creado: ${employeeData['userId']}';
}

/// Servicio para crear empleados en Firebase
///
/// Gestiona la creación de usuarios en Authentication + Firestore
class EmployeeCreationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EmployeeCreationService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Crea un nuevo empleado en Firebase Auth + Firestore
  ///
  /// Usa una sesión secundaria de Firebase Auth para no destruir la sesión
  /// activa del administrador mientras se crea la credencial del empleado.
  ///
  /// Parámetros obligatorios:
  /// - [email]: Email del empleado
  /// - [nombre]: Nombre del empleado
  /// - [apellido1]: Primer apellido del empleado
  ///
  /// Parámetros opcionales:
  /// - [apellido2]: Segundo apellido (opcional)
  /// - [employeeId]: ID del empleado. Si es null, se genera automáticamente (EMP-XXX)
  /// - [weeklyHours]: Horas semanales. Por defecto 40.0
  /// - [dni]: DNI del empleado (opcional)
  /// - [telefono]: Teléfono del empleado (opcional)
  /// - [cargo]: Cargo/posición del empleado (opcional)
  /// - [departamento]: Departamento del empleado (opcional)
  /// - [empresa]: Empresa del empleado (opcional, por defecto "Escuela Música")
  /// - [scheduleId]: ID de plantilla de horario (opcional)
  /// - [calendarId]: ID del calendario laboral asignado (opcional)
  /// - [fechaInicio]: Fecha de inicio en la APLICACIÓN (NO en la empresa).
  ///   Desde esta fecha el empleado puede fichar en el sistema.
  ///   Ejemplo: Empleado trabaja desde 2018, pero acceso app desde 10/01/2026
  /// - [fechaFin]: Fecha de fin en la APLICACIÓN (baja/baja temporal del sistema).
  ///   Hasta esta fecha el empleado puede fichar. Null = indefinido.
  ///   Ejemplo: Baja de maternidad, despido, jubilación
  /// - [role]: Rol del usuario. Por defecto UserRole.employee
  /// - [isSupervisor]: Habilita funciones de supervision en panel empleado
  /// - [supervisorId]: Supervisor asignado para este empleado
  /// - [isActive]: Estado inicial del empleado en el sistema
  ///
  /// Retorna:
  /// - Map con 'userId', 'temporaryPassword' y 'employeeId'
  ///
  /// Lanza excepciones si:
  /// - El email ya existe
  /// - No hay conexión a Firebase
  /// - Faltan permisos
  Future<Map<String, String>> createEmployee({
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
    debugPrint('🚀 EmployeeCreationService.createEmployee() iniciado');
    debugPrint('📧 Email: $email');

    // Validar email
    if (email.trim().isEmpty) {
      throw Exception('El email es obligatorio');
    }
    if (nombre.trim().isEmpty) {
      throw Exception('El nombre es obligatorio');
    }
    if (apellido1.trim().isEmpty) {
      throw Exception('El primer apellido es obligatorio');
    }

    // 1. Generar contraseña temporal
    final temporaryPassword = _generateTemporaryPassword();
    if (kDebugMode) {
      debugPrint('🔑 Contraseña temporal generada');
    }

    // 2. EmployeeId: Dejarlo vacío por ahora (se asignará en lote más adelante)
    // TODO [DÍA-6]: Crear script para asignar employeeIds secuenciales a todos los usuarios
    final finalEmployeeId =
        employeeId?.trim() ?? ''; // Vacío si no se especifica
    debugPrint(
        '🆔 EmployeeId: ${finalEmployeeId.isEmpty ? "(vacío - se asignará después)" : finalEmployeeId}');

    // 3. Construir displayName
    final displayName = _buildDisplayName(
      nombre: nombre.trim(),
      apellido1: apellido1.trim(),
      apellido2: apellido2?.trim(),
    );
    debugPrint('👤 DisplayName: $displayName');

    // 4. Crear usuario en Firebase Authentication usando una sesión aislada
    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;
    UserCredential userCredential;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'employee-creation-${DateTime.now().microsecondsSinceEpoch}',
        options: _auth.app.options,
      );
      secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      debugPrint('🔐 Creando usuario en Firebase Auth...');
      userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: temporaryPassword,
      );
      debugPrint('✅ Usuario creado en Auth: ${userCredential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        throw Exception('El email ya está registrado');
      } else if (e.code == 'invalid-email') {
        throw Exception('El email no es válido');
      }
      throw Exception('Error al crear usuario: ${e.message}');
    }

    final userId = userCredential.user!.uid;

    try {
      // 5. Crear documento en Firestore manteniendo la sesión admin original
      debugPrint('📝 Creando documento en Firestore...');
      await _firestore.collection('users').doc(userId).set(
            buildEmployeeDocumentData(
              userId: userId,
              employeeId: finalEmployeeId,
              email: email,
              displayName: displayName,
              role: role,
              isSupervisor: isSupervisor,
              supervisorId: supervisorId,
              isActive: isActive,
              weeklyHours: weeklyHours ?? 40.0,
              nombre: nombre,
              apellido1: apellido1,
              apellido2: apellido2,
              dni: dni,
              telefono: telefono,
              cargo: cargo,
              departamento: departamento,
              empresa: empresa,
              scheduleId: scheduleId,
              calendarId: calendarId,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
            ),
          );
      debugPrint('✅ Documento creado en Firestore');

      return {
        'userId': userId,
        'temporaryPassword': temporaryPassword,
        'employeeId': finalEmployeeId,
      };
    } catch (e) {
      debugPrint('❌ ERROR al crear documento Firestore: $e');
      // Si falla la creación en Firestore, intentar eliminar el usuario de Auth
      try {
        await userCredential.user!.delete();
        debugPrint('🗑️ Usuario eliminado de Auth tras fallo');
      } catch (_) {
        debugPrint('⚠️ No se pudo eliminar usuario de Auth');
      }

      rethrow;
    } finally {
      try {
        await secondaryAuth.signOut();
      } catch (_) {
        debugPrint('⚠️ No se pudo cerrar sesión secundaria');
      }
      try {
        await secondaryApp.delete();
      } catch (_) {
        debugPrint('⚠️ No se pudo liberar la app secundaria');
      }
    }
  }
}

// ============================================================================
// SCHEDULE SERVICE - Gestión de Plantillas de Horario
// ============================================================================

/// Provider para el servicio de gestión de plantillas de horario
///
/// Proporciona acceso a operaciones CRUD de plantillas en Firestore.
/// Usado por ScheduleManagementProvider para lógica de negocio.
@riverpod
ScheduleService scheduleService(ScheduleServiceRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return ScheduleService(firestore);
}

// ============================================================================
// CALENDAR SERVICE - Gestión de Calendarios Laborales
// ============================================================================

/// Provider para el servicio de gestión de calendarios laborales
///
/// Proporciona acceso a operaciones CRUD de calendarios en Firestore.
/// Usado por CalendarManagementProvider para lógica de negocio.
@riverpod
CalendarService calendarService(CalendarServiceRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return CalendarService(firestore);
}
