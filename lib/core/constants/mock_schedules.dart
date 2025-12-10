/// Mock data para plantillas de horarios y horarios personalizados de empleados
///
/// MOCK DATA: Este archivo contiene datos de prueba para Fase 1.
/// TODO [FASE-2]: Reemplazar con datos reales desde Firestore
class MockSchedules {
  // Prevenir instanciación
  MockSchedules._();

  // ============================================================================
  // PLANTILLAS PREDEFINIDAS
  // ============================================================================

  /// Plantillas de horario disponibles para asignar a empleados
  static final List<Map<String, dynamic>> templates = [
    {
      'id': 'template_001',
      'name': 'Jornada Completa',
      'description': 'Lunes a viernes, 9:00-17:00',
      'weeklyHours': 40,
      'isTemplate': true,
      'usedByCount': 280,
      'weekSchedule': {
        'monday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '09:00', 'endTime': '17:00'},
          ],
          'breakMinutes': 60,
          'dailyHours': 8,
        },
        'tuesday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '09:00', 'endTime': '17:00'},
          ],
          'breakMinutes': 60,
          'dailyHours': 8,
        },
        'wednesday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '09:00', 'endTime': '17:00'},
          ],
          'breakMinutes': 60,
          'dailyHours': 8,
        },
        'thursday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '09:00', 'endTime': '17:00'},
          ],
          'breakMinutes': 60,
          'dailyHours': 8,
        },
        'friday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '09:00', 'endTime': '17:00'},
          ],
          'breakMinutes': 60,
          'dailyHours': 8,
        },
        'saturday': {
          'isWorkDay': false,
          'shifts': [],
          'breakMinutes': 0,
          'dailyHours': 0,
        },
        'sunday': {
          'isWorkDay': false,
          'shifts': [],
          'breakMinutes': 0,
          'dailyHours': 0,
        },
      },
      'createdAt': '2024-01-15',
      'createdBy': 'Admin',
    },
    {
      'id': 'template_002',
      'name': 'Jornada Tarde',
      'description': 'Lunes a viernes, 15:00-20:00',
      'weeklyHours': 25,
      'isTemplate': true,
      'usedByCount': 85,
      'weekSchedule': {
        'monday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '15:00', 'endTime': '20:00'},
          ],
          'breakMinutes': 0,
          'dailyHours': 5,
        },
        'tuesday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '15:00', 'endTime': '20:00'},
          ],
          'breakMinutes': 0,
          'dailyHours': 5,
        },
        'wednesday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '15:00', 'endTime': '20:00'},
          ],
          'breakMinutes': 0,
          'dailyHours': 5,
        },
        'thursday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '15:00', 'endTime': '20:00'},
          ],
          'breakMinutes': 0,
          'dailyHours': 5,
        },
        'friday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '15:00', 'endTime': '20:00'},
          ],
          'breakMinutes': 0,
          'dailyHours': 5,
        },
        'saturday': {
          'isWorkDay': false,
          'shifts': [],
          'breakMinutes': 0,
          'dailyHours': 0,
        },
        'sunday': {
          'isWorkDay': false,
          'shifts': [],
          'breakMinutes': 0,
          'dailyHours': 0,
        },
      },
      'createdAt': '2024-02-20',
      'createdBy': 'María García (RRHH)',
    },
    {
      'id': 'template_003',
      'name': 'Part-Time 15h',
      'description': 'Lun/Mié/Vie, 15:00-20:00',
      'weeklyHours': 15,
      'isTemplate': true,
      'usedByCount': 45,
      'weekSchedule': {
        'monday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '15:00', 'endTime': '20:00'},
          ],
          'breakMinutes': 0,
          'dailyHours': 5,
        },
        'tuesday': {
          'isWorkDay': false,
          'shifts': [],
          'breakMinutes': 0,
          'dailyHours': 0,
        },
        'wednesday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '15:00', 'endTime': '20:00'},
          ],
          'breakMinutes': 0,
          'dailyHours': 5,
        },
        'thursday': {
          'isWorkDay': false,
          'shifts': [],
          'breakMinutes': 0,
          'dailyHours': 0,
        },
        'friday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '15:00', 'endTime': '20:00'},
          ],
          'breakMinutes': 0,
          'dailyHours': 5,
        },
        'saturday': {
          'isWorkDay': false,
          'shifts': [],
          'breakMinutes': 0,
          'dailyHours': 0,
        },
        'sunday': {
          'isWorkDay': false,
          'shifts': [],
          'breakMinutes': 0,
          'dailyHours': 0,
        },
      },
      'createdAt': '2024-03-10',
      'createdBy': 'María García (RRHH)',
    },
  ];

  // ============================================================================
  // HORARIOS PERSONALIZADOS (EMPLEADOS)
  // ============================================================================

  /// Empleados con horarios personalizados (no usan plantillas)
  static final List<Map<String, dynamic>> customSchedules = [
    {
      'employeeId': 'EMP-042',
      'employeeName': 'Juan Pérez',
      'position': 'Profesor de Piano',
      'scheduleType': 'custom',
      'weeklyHours': 28,
      'customSchedule': {
        'monday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '09:00', 'endTime': '13:00'},
            {'startTime': '16:00', 'endTime': '20:00'},
          ],
          'dailyHours': 8,
        },
        'tuesday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '10:00', 'endTime': '18:00'},
          ],
          'dailyHours': 8,
        },
        'wednesday': {'isWorkDay': false, 'shifts': [], 'dailyHours': 0},
        'thursday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '10:00', 'endTime': '18:00'},
          ],
          'dailyHours': 8,
        },
        'friday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '09:00', 'endTime': '13:00'},
          ],
          'dailyHours': 4,
        },
        'saturday': {'isWorkDay': false, 'shifts': [], 'dailyHours': 0},
        'sunday': {'isWorkDay': false, 'shifts': [], 'dailyHours': 0},
      },
      'lastModified': '2025-03-01',
      'lastModifiedBy': 'María García (RRHH)',
    },
    {
      'employeeId': 'EMP-089',
      'employeeName': 'Ana López',
      'position': 'Profesora de Violín',
      'scheduleType': 'custom',
      'weeklyHours': 32,
      'customSchedule': {
        'monday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '10:00', 'endTime': '14:00'},
            {'startTime': '15:00', 'endTime': '19:00'},
          ],
          'dailyHours': 8,
        },
        'tuesday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '10:00', 'endTime': '14:00'},
            {'startTime': '15:00', 'endTime': '19:00'},
          ],
          'dailyHours': 8,
        },
        'wednesday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '10:00', 'endTime': '14:00'},
            {'startTime': '15:00', 'endTime': '19:00'},
          ],
          'dailyHours': 8,
        },
        'thursday': {
          'isWorkDay': true,
          'shifts': [
            {'startTime': '10:00', 'endTime': '14:00'},
            {'startTime': '15:00', 'endTime': '19:00'},
          ],
          'dailyHours': 8,
        },
        'friday': {'isWorkDay': false, 'shifts': [], 'dailyHours': 0},
        'saturday': {'isWorkDay': false, 'shifts': [], 'dailyHours': 0},
        'sunday': {'isWorkDay': false, 'shifts': [], 'dailyHours': 0},
      },
      'lastModified': '2025-02-15',
      'lastModifiedBy': 'Admin',
    },
  ];

  // ============================================================================
  // ASIGNACIONES DE HORARIOS (EMPLEADO → HORARIO)
  // ============================================================================

  /// Mapa de empleados y sus horarios asignados
  /// Si no está aquí, usa la plantilla por defecto (template_001)
  static final Map<String, Map<String, dynamic>> employeeSchedules = {
    'EMP-001': {
      'type': 'template',
      'templateId': 'template_001',
      'weeklyHours': 40,
    },
    'EMP-042': {'type': 'custom', 'templateId': null, 'weeklyHours': 28},
    'EMP-089': {'type': 'custom', 'templateId': null, 'weeklyHours': 32},
  };

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Obtiene el horario de un empleado por su ID
  static Map<String, dynamic>? getEmployeeSchedule(String employeeId) {
    final assignment = employeeSchedules[employeeId];

    if (assignment == null) {
      // Por defecto, usa Jornada Completa
      return {
        'type': 'template',
        'templateId': 'template_001',
        'weeklyHours': 40,
        'schedule': templates[0]['weekSchedule'],
        'templateName': 'Jornada Completa',
      };
    }

    if (assignment['type'] == 'template') {
      final template = templates.firstWhere(
        (t) => t['id'] == assignment['templateId'],
        orElse: () => templates[0],
      );
      return {
        'type': 'template',
        'templateId': template['id'],
        'weeklyHours': template['weeklyHours'],
        'schedule': template['weekSchedule'],
        'templateName': template['name'],
      };
    } else {
      // Horario personalizado
      final customSchedule = customSchedules.firstWhere(
        (s) => s['employeeId'] == employeeId,
        orElse: () => customSchedules[0],
      );
      return {
        'type': 'custom',
        'templateId': null,
        'weeklyHours': customSchedule['weeklyHours'],
        'schedule': customSchedule['customSchedule'],
        'templateName': 'Horario personalizado',
      };
    }
  }

  /// Formatea un día de la semana en español
  static String formatDayName(String dayKey) {
    final dayNames = {
      'monday': 'Lunes',
      'tuesday': 'Martes',
      'wednesday': 'Miércoles',
      'thursday': 'Jueves',
      'friday': 'Viernes',
      'saturday': 'Sábado',
      'sunday': 'Domingo',
    };
    return dayNames[dayKey] ?? dayKey;
  }

  /// Formatea los turnos de un día
  static String formatShifts(List<dynamic> shifts) {
    if (shifts.isEmpty) return 'Libre';

    return shifts
        .map((shift) {
          return '${shift['startTime']}-${shift['endTime']}';
        })
        .join(' / ');
  }
}
