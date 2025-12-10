import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
