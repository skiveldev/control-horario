/// Script simplificado para poblar usuarios de prueba en Firebase
/// 
/// Este script muestra las credenciales que necesitas crear manualmente
/// en Firebase Console ya que no podemos ejecutar el script completo
/// debido a problemas con el SDK de Flutter.
/// 
/// INSTRUCCIONES:
/// 1. Ve a Firebase Console: https://console.firebase.google.com
/// 2. Selecciona tu proyecto
/// 3. Ve a Authentication > Users
/// 4. Haz clic en "Add user" para cada uno de estos usuarios:

void main() {
  print('🌱 USUARIOS DE PRUEBA PARA CREAR EN FIREBASE CONSOLE\n');
  print('═══════════════════════════════════════════════════════════════\n');

  final users = [
    {
      'email': 'admin@escuela.com',
      'password': 'admin123',
      'displayName': 'Admin Sistema',
      'employeeId': 'EMP-001',
      'role': 'admin',
      'weeklyHours': 40.0,
    },
    {
      'email': 'rrhh@escuela.com',
      'password': 'rrhh123',
      'displayName': 'RRHH Responsable',
      'employeeId': 'EMP-002',
      'role': 'rrhh',
      'weeklyHours': 40.0,
    },
    {
      'email': 'empleado@escuela.com',
      'password': 'empleado123',
      'displayName': 'Juan Pérez',
      'employeeId': 'EMP-003',
      'role': 'employee',
      'weeklyHours': 40.0,
    },
    {
      'email': 'maria@escuela.com',
      'password': 'maria123',
      'displayName': 'María García',
      'employeeId': 'EMP-004',
      'role': 'employee',
      'weeklyHours': 25.0,
    },
    {
      'email': 'carlos@escuela.com',
      'password': 'carlos123',
      'displayName': 'Carlos López',
      'employeeId': 'EMP-005',
      'role': 'employee',
      'weeklyHours': 15.0,
    },
  ];

  print('📋 PASO 1: CREAR USUARIOS EN FIREBASE AUTHENTICATION');
  print('─────────────────────────────────────────────────────────────\n');

  for (int i = 0; i < users.length; i++) {
    final user = users[i];
    print('${i + 1}. Usuario ${user['role']}:');
    print('   Email:    ${user['email']}');
    print('   Password: ${user['password']}');
    print('   Nombre:   ${user['displayName']}\n');
  }

  print('═══════════════════════════════════════════════════════════════\n');
  print('📋 PASO 2: CREAR DOCUMENTOS EN FIRESTORE');
  print('─────────────────────────────────────────────────────────────\n');
  print('Después de crear cada usuario en Authentication, anota su UID.');
  print('Luego ve a Firestore Database y crea estos documentos:\n');
  print('Colección: users');
  print('Documento ID: {UID del usuario creado}\n');
  
  print('Campos a agregar a cada documento:\n');
  for (final user in users) {
    print('Para ${user['email']}:');
    print('  {');
    print('    "userId": "{UID_del_usuario}",');
    print('    "employeeId": "${user['employeeId']}",');
    print('    "email": "${user['email']}",');
    print('    "displayName": "${user['displayName']}",');
    print('    "role": "${user['role']}",');
    print('    "weeklyHours": ${user['weeklyHours']},');
    print('    "isActive": true,');
    print('    "createdAt": {timestamp actual}');
    print('  }\n');
  }

  print('═══════════════════════════════════════════════════════════════\n');
  print('💡 ALTERNATIVA RÁPIDA:');
  print('─────────────────────────────────────────────────────────────\n');
  print('Puedes usar la consola de Firebase y ejecutar este código en');
  print('Cloud Functions para crear los usuarios automáticamente.\n');
  
  print('✅ Usuarios listos para crear manualmente en Firebase Console!');
  print('═══════════════════════════════════════════════════════════════\n');
}

