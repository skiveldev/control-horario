import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio temporal para poblar la base de datos con datos iniciales
class SeedService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Crea los datos iniciales del sistema
  /// Retorna true si todo salió bien
  Future<bool> seedInitialData() async {
    try {
      print('🌱 Iniciando Seed de base de datos...');

      // 1. Crear Horarios Base
      await _seedSchedules();

      // 2. Crear Configuración del Sistema
      await _seedSystemConfig();

      print('✅ Seed completado con éxito');
      return true;
    } catch (e) {
      print('❌ Error en Seed: $e');
      return false;
    }
  }

  /// Crea los horarios predefinidos
  Future<void> _seedSchedules() async {
    final schedules = [
      {
        'scheduleId': 'schedule_standard',
        'name': 'Jornada Completa (40h)',
        'description': 'Lunes a Viernes de 9:00 a 18:00 con 1h de pausa',
        'totalWeeklyHours': 40,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'weeklySchedule': _generateStandardWeek(),
      },
      {
        'scheduleId': 'schedule_part_time',
        'name': 'Media Jornada (20h)',
        'description': 'Lunes a Viernes de 9:00 a 13:00',
        'totalWeeklyHours': 20,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'weeklySchedule': _generatePartTimeWeek(),
      },
    ];

    final batch = _db.batch();

    for (var schedule in schedules) {
      final docRef = _db.collection('schedules').doc(schedule['scheduleId'] as String);
      batch.set(docRef, schedule);
    }

    await batch.commit();
    print('   -> Horarios creados');
  }

  /// Crea la configuración global
  Future<void> _seedSystemConfig() async {
    await _db.collection('system_config').doc('settings').set({
      'version': '1.0.0',
      'clockingRules': {
        'maxDailyHours': 12,
        'allowEarlyClockIn': 15, // minutos
        'allowLateClockOut': 15, // minutos
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('   -> Configuración del sistema creada');
  }

  /// Promueve el usuario actual a Admin
  Future<void> promoteCurrentUserToAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ No hay usuario logueado para promover');
      return;
    }

    await _db.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? 'Admin',
      'role': 'admin', // <--- ESTO ES LO IMPORTANTE
      'employeeId': 'ADMIN-001',
      'contractType': 'full_time',
      'scheduleId': 'schedule_standard',
      'weeklyHours': 40,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('👑 Usuario ${user.email} promovido a ADMIN');
  }

  // Helpers para generar horarios
  Map<String, dynamic> _generateStandardWeek() {
    final day = {
      'isWorkDay': true,
      'startTime': '09:00',
      'endTime': '18:00',
      'breakMinutes': 60,
    };
    final weekend = {
      'isWorkDay': false,
      'startTime': null,
      'endTime': null,
      'breakMinutes': 0,
    };

    return {
      'monday': day,
      'tuesday': day,
      'wednesday': day,
      'thursday': day,
      'friday': day,
      'saturday': weekend,
      'sunday': weekend,
    };
  }

  Map<String, dynamic> _generatePartTimeWeek() {
    final day = {
      'isWorkDay': true,
      'startTime': '09:00',
      'endTime': '13:00',
      'breakMinutes': 0,
    };
    final weekend = {
      'isWorkDay': false,
      'startTime': null,
      'endTime': null,
      'breakMinutes': 0,
    };

    return {
      'monday': day,
      'tuesday': day,
      'wednesday': day,
      'thursday': day,
      'friday': day,
      'saturday': weekend,
      'sunday': weekend,
    };
  }
}

