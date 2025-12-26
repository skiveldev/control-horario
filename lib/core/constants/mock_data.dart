/// Datos mock para Fase 1
///
/// Contiene datos de prueba para simular el funcionamiento de la app.
/// TODO [FASE-2]: Reemplazar con datos reales de Firebase
class MockData {
  MockData._();

  // ============================================================================
  // USUARIO ACTUAL (Mock)
  // ============================================================================

  static const Map<String, dynamic> currentUser = {
    'id': 'EMP-2024-001',
    'name': 'María García López',
    'email': 'maria.garcia@escuelamusica.com',
    'role': 'empleado', // 'empleado', 'admin', 'rrhh'
    'position': 'Desarrolladora Frontend Senior',
    'department': 'Tecnología',
    'avatarUrl': null, // En producción, URL de Firebase Storage
    'joinDate': '2022-03-15',
    'schedule': '09:00 - 18:00',
    'workHoursPerDay': 8.0,
  };

  // ============================================================================
  // ESTADO DE FICHAJE ACTUAL
  // ============================================================================

  static const Map<String, dynamic> currentClockingStatus = {
    'date': '2025-11-18',
    'hasEntrance': true,
    'entranceTime': '09:00',
    'hasExit': false,
    'exitTime': null,
    'hasPause': false,
    'pauseTime': null,
    'hasReturn': false,
    'returnTime': null,
    'totalWorkedHours': 5.5,
    'totalBreakMinutes': 30,
    'status': 'activo', // 'sin_fichar', 'activo', 'en_pausa', 'completo'
    'estimatedExit': '18:00',
  };

  // ============================================================================
  // RESUMEN DEL DÍA
  // ============================================================================

  static const Map<String, dynamic> todaySummary = {
    'totalHours': 5.5,
    'expectedHours': 8.0,
    'breakTime': 30, // minutos
    'entranceTime': '09:00',
    'estimatedExit': '18:00',
    'isComplete': false,
  };

  // ============================================================================
  // REGISTROS RECIENTES
  // ============================================================================

  static const List<Map<String, dynamic>> recentRecords = [
    {
      'date': '2023-12-07',
      'entrance': '09:00',
      'exit': '18:00',
      'total': '8.3h',
      'status': 'completo',
    },
    {
      'date': '2023-11-07',
      'entrance': '08:45',
      'exit': '17:30',
      'total': '8.0h',
      'status': 'completo',
    },
    {
      'date': '2023-10-07',
      'entrance': '09:15',
      'exit': '18:30',
      'total': '8.2h',
      'status': 'completo',
    },
    {
      'date': '2023-07-07',
      'entrance': '09:00',
      'exit': '16:45',
      'total': '7.0h',
      'status': 'incompleto',
    },
    {
      'date': '2023-06-07',
      'entrance': '09:30',
      'exit': '18:15',
      'total': '8.0h',
      'status': 'completo',
    },
  ];

  // ============================================================================
  // CALENDARIO MENSUAL (Noviembre 2025)
  // ============================================================================

  static const Map<int, String> calendarDays = {
    // Días con estado especial
    6: 'festivo', // Jueves 6
    12: 'festivo', // Miércoles 12
    13: 'festivo', // Jueves 13
    14: 'festivo', // Viernes 14
    18: 'activo', // Hoy (martes 18) - día actual
    22: 'evento', // Sábado 22
    25: 'festivo', // Martes 25
    // Los demás días son normales o vacaciones
  };

  // ============================================================================
  // RESUMEN SEMANAL
  // ============================================================================

  static const Map<String, dynamic> weeklySummary = {
    'totalHours': 37.5,
    'expectedHours': 40.0,
    'days': [
      {'day': 'L', 'hours': 8.0, 'status': 'completo'},
      {'day': 'M', 'hours': 8.5, 'status': 'completo'},
      {'day': 'X', 'hours': 8.0, 'status': 'completo'},
      {'day': 'J', 'hours': 7.5, 'status': 'incompleto'},
      {'day': 'V', 'hours': 5.5, 'status': 'activo'}, // Hoy
    ],
  };

  // ============================================================================
  // ACCIONES RÁPIDAS
  // ============================================================================

  static const List<Map<String, dynamic>> quickActions = [
    {
      'id': 'request_vacation',
      'title': 'Solicitar vacaciones',
      'icon': 'calendar_month',
      'color': 'info',
      'enabled': true,
    },
    {
      'id': 'edit_record',
      'title': 'Editar registro',
      'icon': 'edit',
      'color': 'secondary',
      'enabled': true,
    },
    {
      'id': 'view_reports',
      'title': 'Ver reportes',
      'icon': 'assessment',
      'color': 'accent',
      'enabled': false,
    },
  ];

  // ============================================================================
  // EMPLEADOS (Para panel admin)
  // ============================================================================

  static const List<Map<String, dynamic>> employees = [
    {
      'id': 'EMP-001',
      'name': 'María García López',
      'position': 'Desarrolladora Frontend Senior',
      'department': 'Tecnología',
      'email': 'maria.garcia@escuela.com',
      'status': 'activo',
      'isClockedIn': true,
    },
    {
      'id': 'EMP-002',
      'name': 'Juan Pérez Martínez',
      'position': 'Profesor de Piano',
      'department': 'Docente',
      'email': 'juan.perez@escuela.com',
      'status': 'activo',
      'isClockedIn': true,
    },
    {
      'id': 'EMP-003',
      'name': 'Ana Rodríguez Santos',
      'position': 'Profesora de Violín',
      'department': 'Docente',
      'email': 'ana.rodriguez@escuela.com',
      'status': 'activo',
      'isClockedIn': false,
    },
    {
      'id': 'EMP-004',
      'name': 'Carlos López Fernández',
      'position': 'Coordinador Académico',
      'department': 'Administración',
      'email': 'carlos.lopez@escuela.com',
      'status': 'activo',
      'isClockedIn': true,
    },
    {
      'id': 'EMP-005',
      'name': 'Laura Martín Ruiz',
      'position': 'Administradora RRHH',
      'department': 'Recursos Humanos',
      'email': 'laura.martin@escuela.com',
      'status': 'activo',
      'isClockedIn': true,
    },
    {
      'id': 'EMP-006',
      'name': 'David Sánchez Gómez',
      'position': 'Profesor de Guitarra',
      'department': 'Docente',
      'email': 'david.sanchez@escuela.com',
      'status': 'vacaciones',
      'isClockedIn': false,
    },
    {
      'id': 'EMP-007',
      'name': 'Elena Torres Díaz',
      'position': 'Profesora de Canto',
      'department': 'Docente',
      'email': 'elena.torres@escuela.com',
      'status': 'activo',
      'isClockedIn': true,
    },
    {
      'id': 'EMP-008',
      'name': 'Miguel Ángel Ruiz',
      'position': 'Director',
      'department': 'Administración',
      'email': 'miguel.ruiz@escuela.com',
      'status': 'activo',
      'isClockedIn': false,
    },
  ];

  // ============================================================================
  // ESTADÍSTICAS ADMIN
  // ============================================================================

  static const Map<String, dynamic> adminStats = {
    'totalEmployees': 500,
    'clockedInToday': 485,
    'absencesToday': 3,
    'pendingRequests': 12,
    'incompleteRecords': 5,
  };

  // ============================================================================
  // ACTIVIDAD SEMANAL (Para gráfico)
  // ============================================================================

  static const Map<String, int> weeklyActivity = {
    'Lun': 420,
    'Mar': 450,
    'Mie': 480,
    'Jue': 470,
    'Vie': 490,
    'Sab': 410,
    'Dom': 380,
  };

  // ============================================================================
  // SOLICITUDES RECIENTES (Para lista)
  // ============================================================================

  static const List<Map<String, String>> recentRequests = [
    {
      'name': 'Usuario 1',
      'type': 'Solicitud de vacaciones',
      'status': 'Pendiente',
    },
    {
      'name': 'Usuario 2',
      'type': 'Solicitud de vacaciones',
      'status': 'Pendiente',
    },
    {
      'name': 'Usuario 3',
      'type': 'Solicitud de vacaciones',
      'status': 'Pendiente',
    },
  ];

  // ============================================================================
  // ALERTAS DE CONTROL (Para panel)
  // ============================================================================

  static const List<Map<String, String>> controlAlerts = [
    {
      'type': 'warning',
      'title': 'Fichajes Incompletos',
      'message': '3 empleados no han registrado su salida ayer.',
    },
    {
      'type': 'success',
      'title': 'Sistema operativo',
      'message': 'El terminal de acceso Norte está funcionando correctamente.',
    },
  ];
}
