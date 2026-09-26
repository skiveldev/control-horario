import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
/// Proporciona acceso a operaciones CRUD de calendarios laborales.
/// Usado por CalendarManagementProvider para lógica de negocio.
@riverpod
CalendarService calendarService(CalendarServiceRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return CalendarService(firestore);
}
