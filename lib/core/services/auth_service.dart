import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/models/user_model.dart';

part 'auth_service.g.dart';

/// Provider del servicio de autenticación
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
}

/// Servicio de Autenticación
///
/// Gestiona todas las operaciones relacionadas con la autenticación
/// de usuarios usando Firebase Auth y Firestore.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  // ==========================================================================
  // STREAMS Y GETTERS
  // ==========================================================================

  /// Stream del estado de autenticación de Firebase
  ///
  /// Emite el User actual cuando hay cambios en la autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actualmente autenticado (snapshot)
  User? get currentUser => _auth.currentUser;

  // ==========================================================================
  // AUTENTICACIÓN
  // ==========================================================================

  /// Login con email y contraseña
  ///
  /// Retorna UserCredential de Firebase Auth.
  /// Lanza excepción si las credenciales son inválidas.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Cerrar sesión
  ///
  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==========================================================================
  // DATOS DE USUARIO (FIRESTORE)
  // ==========================================================================

  /// Obtener datos del usuario desde Firestore (snapshot)
  ///
  /// Retorna UserModel con la información completa del empleado
  /// o null si el documento no existe.
  Future<UserModel?> getUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream de datos del usuario desde Firestore
  ///
  /// Emite UserModel cada vez que el documento cambia.
  /// Útil para mantener la UI actualizada en tiempo real.
  Stream<UserModel?> userDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null)
        .handleError((Object error, StackTrace stackTrace) {
      debugPrint('AuthService.userDataStream error [$userId]: $error');
      throw error;
    });
  }

  /// Actualizar datos del usuario en Firestore
  ///
  /// Actualiza los campos especificados en [data] del documento del usuario.
  /// Solo actualiza los campos proporcionados, manteniendo el resto intactos.
  ///
  /// Ejemplo:
  /// ```dart
  /// await authService.updateUserData(
  ///   userId,
  ///   {
  ///     'nombre': 'Juan',
  ///     'apellido1': 'Pérez',
  ///     'telefono': '+34 600 123 456',
  ///   },
  /// );
  /// ```
  ///
  /// Lanza excepción si el usuario no existe o hay error de permisos.
  Future<void> updateUserData(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  /// Cambiar la contraseña del usuario actual
  ///
  /// Requiere la contraseña actual para reautenticar al usuario
  /// antes de actualizar a la nueva contraseña (requisito de Firebase Auth).
  ///
  /// Lanza [FirebaseAuthException] si la contraseña actual es incorrecta
  /// o si la nueva no cumple los requisitos de Firebase.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');
    if (user.email == null) throw Exception('El usuario no tiene email');

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
