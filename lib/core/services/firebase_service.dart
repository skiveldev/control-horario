import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/models/user_model.dart';

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

/// Provider para el servicio de creación de empleados
@riverpod
EmployeeCreationService employeeCreationService(
    EmployeeCreationServiceRef ref) {
  return EmployeeCreationService(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
}

/// Servicio para crear empleados en Firebase
///
/// Gestiona la creación de usuarios en Authentication + Firestore
class EmployeeCreationService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  EmployeeCreationService({
    required this.firestore,
    required this.auth,
  });

  /// Crea un nuevo empleado en Firebase Auth + Firestore
  ///
  /// ⚠️ LIMITACIÓN CONOCIDA (Sprint 1.1):
  /// Este método usa createUserWithEmailAndPassword() que automáticamente
  /// inicia sesión con el usuario creado, cerrando la sesión del admin.
  ///
  /// SOLUCIÓN TEMPORAL: El admin debe volver a iniciar sesión después.
  ///
  /// SOLUCIÓN DEFINITIVA (Sprint 2): Implementar Cloud Function con Admin SDK
  /// para crear usuarios sin afectar la sesión actual.
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
  /// - [scheduleId]: ID de plantilla de horario (opcional)
  /// - [fechaInicio]: Fecha de inicio en la APLICACIÓN, no en la empresa (opcional)
  /// - [fechaFin]: Fecha de fin en la APLICACIÓN - baja/baja temporal (opcional)
  /// - [role]: Rol del usuario. Por defecto UserRole.employee
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
    String? scheduleId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    UserRole role = UserRole.employee,
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
    debugPrint('🔑 Contraseña temporal generada: $temporaryPassword');

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

    // 4. Crear usuario en Firebase Authentication
    // ⚠️ Esto cerrará la sesión del admin actual
    UserCredential userCredential;
    try {
      debugPrint('🔐 Creando usuario en Firebase Auth...');
      userCredential = await auth.createUserWithEmailAndPassword(
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
      // 5. Crear documento en Firestore
      // ⚠️ AHORA el usuario autenticado es el recién creado, NO el admin
      // Por eso necesitamos que las reglas permitan que el usuario cree su propio documento
      debugPrint('📝 Creando documento en Firestore...');
      await firestore.collection('users').doc(userId).set({
        'userId': userId,
        'employeeId': finalEmployeeId,
        'email': email.trim(),
        'displayName': displayName,
        'role': role.name,
        'weeklyHours': weeklyHours ?? 40.0,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        // Campos opcionales (solo si tienen valor)
        if (dni != null && dni.trim().isNotEmpty) 'dni': dni.trim(),
        if (telefono != null && telefono.trim().isNotEmpty)
          'telefono': telefono.trim(),
        if (cargo != null && cargo.trim().isNotEmpty) 'position': cargo.trim(),
        if (departamento != null && departamento.trim().isNotEmpty)
          'department': departamento.trim(),
        if (scheduleId != null && scheduleId.trim().isNotEmpty)
          'scheduleId': scheduleId.trim(),
        if (fechaInicio != null) 'fechaInicio': Timestamp.fromDate(fechaInicio),
        if (fechaFin != null) 'fechaFin': Timestamp.fromDate(fechaFin),
      });
      debugPrint('✅ Documento creado en Firestore');

      // 6. Cerrar sesión del usuario recién creado
      debugPrint('🚪 Cerrando sesión del usuario creado...');
      await auth.signOut();
      debugPrint('✅ Sesión cerrada');

      // 7. Retornar credenciales
      debugPrint('🎉 createEmployee completado exitosamente');
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

      // Cerrar sesión para limpiar estado
      await auth.signOut();

      rethrow;
    }
  }
}
