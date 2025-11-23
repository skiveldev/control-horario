import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script para poblar usuarios de prueba en Firebase
/// 
/// Crea usuarios en Firebase Auth y documentos correspondientes en Firestore.
/// 
/// Ejecutar con:
/// ```bash
/// dart scripts/seed_users.dart
/// ```
/// 
/// NOTA: Requiere que Firebase esté configurado y el archivo
/// firebase_options.dart esté presente.
void main() async {
  print('🌱 Iniciando seeding de usuarios...\n');

  try {
    // Inicializar Firebase
    // NOTA: Debes ajustar esto según tu configuración de Firebase
    await Firebase.initializeApp();
    print('✅ Firebase inicializado\n');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
    print('   Asegúrate de ejecutar "flutterfire configure" primero.\n');
    return;
  }

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Usuarios de prueba para el MVP
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

  int createdCount = 0;
  int errorCount = 0;

  for (final userData in users) {
    try {
      print('📝 Creando usuario: ${userData['email']}...');
      
      // Crear usuario en Firebase Auth
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: userData['email'] as String,
        password: userData['password'] as String,
      );

      // Crear documento en Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'employeeId': userData['employeeId'],
        'email': userData['email'],
        'displayName': userData['displayName'],
        'role': userData['role'],
        'weeklyHours': userData['weeklyHours'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('   ✅ Usuario creado exitosamente');
      print('      UID: ${userCredential.user!.uid}');
      print('      Email: ${userData['email']}');
      print('      Role: ${userData['role']}\n');
      
      createdCount++;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('   ⚠️  El email ${userData['email']} ya existe (omitiendo)\n');
      } else {
        print('   ❌ Error creando ${userData['email']}: ${e.message}\n');
        errorCount++;
      }
    } catch (e) {
      print('   ❌ Error inesperado creando ${userData['email']}: $e\n');
      errorCount++;
    }
  }

  // Resumen final
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🎉 Seeding completado!');
  print('   ✅ Creados: $createdCount usuarios');
  if (errorCount > 0) {
    print('   ❌ Errores: $errorCount');
  }
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  print('Usuarios disponibles para login:');
  for (final userData in users) {
    print('   📧 ${userData['email']} / ${userData['password']} (${userData['role']})');
  }
  print('');
}




