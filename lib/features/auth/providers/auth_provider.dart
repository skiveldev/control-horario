import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/auth_service.dart';
import '../models/user_model.dart';

part 'auth_provider.g.dart';

// ==============================================================================
// STREAM PROVIDERS - Estado de Autenticación
// ==============================================================================

/// Provider del estado de autenticación de Firebase
///
/// Emite User? de Firebase Auth cuando hay cambios en la autenticación.
/// - null si no hay usuario autenticado
/// - User si hay sesión activa
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
}

/// Provider del usuario actual con datos completos
///
/// Combina Firebase Auth con Firestore para obtener UserModel completo.
/// Emite:
/// - null si no hay usuario autenticado
/// - UserModel con datos del empleado si hay sesión activa
@riverpod
Stream<UserModel?> currentUser(CurrentUserRef ref) async* {
  // Esperar al estado de autenticación
  final authState = await ref.watch(authStateProvider.future);

  if (authState == null) {
    yield null;
    return;
  }

  // Obtener datos completos del usuario desde Firestore
  final authService = ref.watch(authServiceProvider);
  yield* authService.userDataStream(authState.uid);
}

// ==============================================================================
// NOTIFIER - Acciones de Autenticación
// ==============================================================================

/// Notifier para acciones de autenticación
///
/// Maneja operaciones como login y logout.
/// Expone AsyncValue<void> como estado para manejar loading/error.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Iniciar sesión con email y contraseña
  ///
  /// Actualiza el estado a loading mientras procesa.
  /// Lanza errores si las credenciales son inválidas.
  ///
  /// Uso:
  /// ```dart
  /// await ref.read(authNotifierProvider.notifier).signIn(email, password);
  /// ```
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  /// Cerrar sesión
  ///
  /// Cierra la sesión del usuario actual.
  /// Actualiza el estado a loading mientras procesa.
  ///
  /// Uso:
  /// ```dart
  /// await ref.read(authNotifierProvider.notifier).signOut();
  /// ```
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
    });
  }
}
