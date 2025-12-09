import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Notifier para go_router que escucha cambios en el estado de autenticación
/// 
/// Implementa ChangeNotifier para que go_router pueda escuchar
/// cambios y ejecutar el redirect cuando cambie el estado de auth.
class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  User? _currentUser;

  AuthNotifier(this._firebaseAuth) {
    _currentUser = _firebaseAuth.currentUser;
    
    // Escuchar cambios en el estado de autenticación
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners(); // Notificar a go_router que hubo cambio
    });
  }

  /// Usuario actual (null si no está autenticado)
  User? get currentUser => _currentUser;

  /// Si hay un usuario autenticado
  bool get isAuthenticated => _currentUser != null;
}












