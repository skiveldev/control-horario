import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Notifier para go_router que escucha cambios en el estado de autenticación
///
/// Implementa ChangeNotifier para que go_router pueda escuchar
/// cambios y ejecutar el redirect cuando cambie el estado de auth.
/// También carga el rol del usuario desde Firestore para proteger rutas de admin.
class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  User? _currentUser;
  bool _isAdmin = false;
  bool _isLoadingRole = false;

  AuthNotifier(this._firebaseAuth, this._firestore) {
    _currentUser = _firebaseAuth.currentUser;

    // authStateChanges() emite el usuario actual inmediatamente al suscribirse,
    // por lo que no hace falta llamar _fetchUserRole() desde el constructor.
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _isAdmin = false;
      if (user != null) {
        _isLoadingRole = true;
        _fetchUserRole(user.uid);
      } else {
        _isLoadingRole = false;
      }
      notifyListeners();
    });
  }

  /// Carga el rol del usuario desde Firestore y notifica a go_router
  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() ?? const <String, dynamic>{};
        final isActive = data['isActive'] as bool? ?? true;
        if (!isActive) {
          _isAdmin = false;
          if (_firebaseAuth.currentUser?.uid == uid) {
            await _firebaseAuth.signOut();
          }
          return;
        }

        final role = (data['role'] as String?) ?? 'employee';
        _isAdmin = role == 'admin';
      }
    } catch (e) {
      debugPrint('AuthNotifier: error al cargar rol del usuario: $e');
      _isAdmin = false;
    } finally {
      _isLoadingRole = false;
      notifyListeners();
    }
  }

  /// Usuario actual (null si no está autenticado)
  User? get currentUser => _currentUser;

  /// Si hay un usuario autenticado
  bool get isAuthenticated => _currentUser != null;

  /// Si el usuario autenticado tiene rol admin
  bool get isAdmin => _isAdmin;

  /// Si el rol está siendo cargado desde Firestore
  bool get isLoadingRole => _isLoadingRole;
}
