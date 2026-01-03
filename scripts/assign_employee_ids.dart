// Script para asignar employeeIds secuenciales a todos los usuarios
// 
// Uso:
// 1. Asegurarte de que Firebase esté configurado
// 2. Ejecutar: dart run scripts/assign_employee_ids.dart
//
// Este script:
// - Busca todos los usuarios con employeeId vacío
// - Les asigna IDs secuenciales: EMP-001, EMP-002, etc.
// - En orden de fecha de creación (createdAt)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  print('🚀 Iniciando asignación de employeeIds...\n');

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // 1. Obtener todos los usuarios con employeeId vacío
  print('📋 Buscando usuarios sin employeeId...');
  final snapshot = await firestore
      .collection('users')
      .where('employeeId', '==', '')
      .orderBy('createdAt')  // En orden de creación
      .get();

  if (snapshot.docs.isEmpty) {
    print('✅ No hay usuarios sin employeeId. Todo listo!');
    return;
  }

  print('📊 Encontrados ${snapshot.docs.length} usuarios sin employeeId\n');

  // 2. Encontrar el último employeeId existente para continuar la secuencia
  final existingSnapshot = await firestore
      .collection('users')
      .where('employeeId', '!=', '')
      .orderBy('employeeId', descending: true)
      .limit(1)
      .get();

  int startNumber = 1;
  if (existingSnapshot.docs.isNotEmpty) {
    final lastId = existingSnapshot.docs.first.data()['employeeId'] as String;
    if (lastId.startsWith('EMP-')) {
      final numberPart = lastId.substring(4);
      final lastNumber = int.tryParse(numberPart) ?? 0;
      startNumber = lastNumber + 1;
      print('🔢 Último employeeId existente: $lastId');
      print('🔢 Comenzando desde: EMP-${startNumber.toString().padLeft(3, '0')}\n');
    }
  }

  // 3. Asignar IDs secuenciales
  print('⏳ Asignando employeeIds...\n');
  
  int counter = startNumber;
  int successful = 0;
  int failed = 0;

  for (var doc in snapshot.docs) {
    final employeeId = 'EMP-${counter.toString().padLeft(3, '0')}';
    final email = doc.data()['email'] as String? ?? 'sin email';
    final displayName = doc.data()['displayName'] as String? ?? 'sin nombre';
    
    try {
      await doc.reference.update({'employeeId': employeeId});
      print('✅ $employeeId → $displayName ($email)');
      successful++;
      counter++;
    } catch (e) {
      print('❌ ERROR al asignar $employeeId a $email: $e');
      failed++;
    }
  }

  // 4. Resumen
  print('\n' + '=' * 60);
  print('📊 RESUMEN:');
  print('   Procesados: ${snapshot.docs.length}');
  print('   Exitosos:   $successful ✅');
  print('   Fallidos:   $failed ❌');
  print('=' * 60);
  print('\n🎉 Proceso completado!');
}



