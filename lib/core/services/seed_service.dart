import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Servicio temporal para poblar la base de datos con datos iniciales
class SeedService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  SeedService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Crea los datos iniciales del sistema
  /// Retorna true si todo salió bien
  Future<bool> seedInitialData() async {
    try {
      debugPrint('🌱 Iniciando Seed de base de datos...');

      // 1. Crear Horarios Base
      await _seedSchedules();

      // 2. Crear Configuración del Sistema
      await _seedSystemConfig();

      debugPrint('✅ Seed completado con éxito');
      return true;
    } catch (e) {
      debugPrint('❌ Error en Seed: $e');
      return false;
    }
  }

  /// Crea los horarios predefinidos
  ///
  /// Plantillas comunes para escuela de música:
  /// - Jornadas completas 40h (diferentes horarios)
  /// - Jornadas reducidas 35h, 25h
  /// - Medias jornadas 20h
  /// - Part-time 15h
  Future<void> _seedSchedules() async {
    debugPrint('   📋 Creando plantillas de horario...');

    final schedules = [
      // ========== JORNADAS COMPLETAS 40H ==========
      {
        'scheduleId': 'schedule_40h_9_17',
        'name': 'Jornada 40h (9:00-17:00)',
        'description': 'Lunes a Viernes, 9:00-17:00 con 1h pausa',
        'totalWeeklyHours': 40,
        'isActive': true,
        'isTemplate': true,
        'usedByCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'system',
        'weeklySchedule': _generateWeek('09:00', '17:00', 60),
      },
      {
        'scheduleId': 'schedule_40h_10_18',
        'name': 'Jornada 40h (10:00-18:00)',
        'description': 'Lunes a Viernes, 10:00-18:00 con 1h pausa',
        'totalWeeklyHours': 40,
        'isActive': true,
        'isTemplate': true,
        'usedByCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'system',
        'weeklySchedule': _generateWeek('10:00', '18:00', 60),
      },
      {
        'scheduleId': 'schedule_40h_8_30_16_30',
        'name': 'Jornada 40h (8:30-16:30)',
        'description': 'Lunes a Viernes, 8:30-16:30 con 1h pausa',
        'totalWeeklyHours': 40,
        'isActive': true,
        'isTemplate': true,
        'usedByCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'system',
        'weeklySchedule': _generateWeek('08:30', '16:30', 60),
      },

      // ========== JORNADAS REDUCIDAS ==========
      {
        'scheduleId': 'schedule_35h_9_16',
        'name': 'Jornada 35h (9:00-16:00)',
        'description': 'Lunes a Viernes, 9:00-16:00 con 1h pausa',
        'totalWeeklyHours': 35,
        'isActive': true,
        'isTemplate': true,
        'usedByCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'system',
        'weeklySchedule': _generateWeek('09:00', '16:00', 60),
      },
      {
        'scheduleId': 'schedule_25h_afternoon',
        'name': 'Jornada Tarde 25h (15:00-20:00)',
        'description': 'Lunes a Viernes, turno tarde sin pausa',
        'totalWeeklyHours': 25,
        'isActive': true,
        'isTemplate': true,
        'usedByCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'system',
        'weeklySchedule': _generateWeek('15:00', '20:00', 0),
      },

      // ========== MEDIAS JORNADAS ==========
      {
        'scheduleId': 'schedule_20h_morning',
        'name': 'Media Jornada Mañana 20h (9:00-13:00)',
        'description': 'Lunes a Viernes, turno mañana',
        'totalWeeklyHours': 20,
        'isActive': true,
        'isTemplate': true,
        'usedByCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'system',
        'weeklySchedule': _generateWeek('09:00', '13:00', 0),
      },

      // ========== PART-TIME ==========
      {
        'scheduleId': 'schedule_15h_part_time',
        'name': 'Part-Time 15h (Lun/Mié/Vie 15:00-20:00)',
        'description': 'Lunes, Miércoles y Viernes tarde',
        'totalWeeklyHours': 15,
        'isActive': true,
        'isTemplate': true,
        'usedByCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': 'system',
        'weeklySchedule': _generateAlternateDays(
          ['monday', 'wednesday', 'friday'],
          '15:00',
          '20:00',
        ),
      },
    ];

    final batch = _db.batch();

    for (var schedule in schedules) {
      final docRef =
          _db.collection('schedules').doc(schedule['scheduleId'] as String);
      batch.set(docRef, schedule);
    }

    await batch.commit();
    debugPrint('   ✅ ${schedules.length} plantillas de horario creadas');
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
    debugPrint('   -> Configuración del sistema creada');
  }

  /// Promueve el usuario actual a Admin
  Future<void> promoteCurrentUserToAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ No hay usuario logueado para promover');
      return;
    }

    await _db.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? 'Admin',
      'role': 'admin', // <--- ESTO ES LO IMPORTANTE
      'employeeId': 'ADMIN-001',
      'contractType': 'full_time',
      'scheduleId': 'schedule_40h_9_17',
      'weeklyHours': 40,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('👑 Usuario ${user.email} promovido a ADMIN');
  }

  // ==========================================================================
  // HELPERS PARA GENERAR HORARIOS
  // ==========================================================================

  /// Generar semana estándar (Lun-Vie con mismo horario)
  ///
  /// [start]: Hora inicio (formato "HH:mm")
  /// [end]: Hora fin (formato "HH:mm")
  /// [breakMinutes]: Minutos de pausa
  Map<String, dynamic> _generateWeek(
    String start,
    String end,
    int breakMinutes,
  ) {
    final dailyHours = _calculateDailyHours(start, end, breakMinutes);

    final workDay = {
      'isWorkDay': true,
      'shifts': [
        {'startTime': start, 'endTime': end}
      ],
      'breakMinutes': breakMinutes,
      'dailyHours': dailyHours,
    };

    final freeDay = {
      'isWorkDay': false,
      'shifts': [],
      'breakMinutes': 0,
      'dailyHours': 0.0,
    };

    return {
      'monday': workDay,
      'tuesday': workDay,
      'wednesday': workDay,
      'thursday': workDay,
      'friday': workDay,
      'saturday': freeDay,
      'sunday': freeDay,
    };
  }

  /// Generar horario solo para días específicos
  ///
  /// Usado para part-time (ej: solo Lun/Mié/Vie)
  ///
  /// [workDays]: Lista de días laborables (ej: ['monday', 'wednesday', 'friday'])
  /// [start]: Hora inicio
  /// [end]: Hora fin
  Map<String, dynamic> _generateAlternateDays(
    List<String> workDays,
    String start,
    String end,
  ) {
    final allDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    final dailyHours = _calculateDailyHours(start, end, 0);

    final workDay = {
      'isWorkDay': true,
      'shifts': [
        {'startTime': start, 'endTime': end}
      ],
      'breakMinutes': 0,
      'dailyHours': dailyHours,
    };

    final freeDay = {
      'isWorkDay': false,
      'shifts': [],
      'breakMinutes': 0,
      'dailyHours': 0.0,
    };

    return {
      for (var day in allDays) day: workDays.contains(day) ? workDay : freeDay,
    };
  }

  /// Calcular horas diarias netas (restando pausa)
  double _calculateDailyHours(String start, String end, int breakMinutes) {
    final startParts = start.split(':');
    final endParts = end.split(':');

    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    final totalMinutes = endMinutes - startMinutes;
    final netMinutes =
        totalMinutes; // Pausa cuenta como trabajo según requisitos

    return netMinutes / 60.0;
  }
}
