import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para gestionar los marcadores de vacaciones en Firestore.
///
/// Colección: `employee_vacations/{autoId}`
/// Campos: employeeId, date (YYYY-MM-DD), markedBy, createdAt
///
/// En modo test (constructor `.test()`) se lanza StateError al acceder
/// a Firestore, obligando a sobreescribir los métodos en tests.
class VacationService {
  final FirebaseFirestore? _firestore;

  VacationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  VacationService.test() : _firestore = null;

  FirebaseFirestore get _requireFirestore {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError(
        'VacationService test double must override Firestore access methods',
      );
    }
    return firestore;
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      _requireFirestore.collection('employee_vacations');

  /// Añade un marcador de vacaciones para un empleado en una fecha.
  Future<void> addVacation({
    required String employeeId,
    required String date,
    required String markedBy,
  }) async {
    try {
      // Verificar si ya existe para no duplicar
      final existing = await _collection
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isEqualTo: date)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return;

      await _collection.add({
        'employeeId': employeeId,
        'date': date,
        'markedBy': markedBy,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al añadir vacación: $e');
    }
  }

  /// Elimina un marcador de vacaciones para un empleado en una fecha.
  Future<void> removeVacation({
    required String employeeId,
    required String date,
  }) async {
    try {
      final snapshot = await _collection
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isEqualTo: date)
          .limit(1)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Error al eliminar vacación: $e');
    }
  }

  /// Obtiene las fechas de vacaciones de un empleado para un mes.
  Future<Set<String>> getVacationDates(
    String employeeId,
    DateTime month,
  ) async {
    try {
      final startDate =
          '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
      final endDate =
          '${month.year}-${month.month.toString().padLeft(2, '0')}-31';

      final snapshot = await _collection
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .limit(1000)
          .get();

      return snapshot.docs.map((doc) => (doc.data())['date'] as String).toSet();
    } catch (e) {
      throw Exception('Error al obtener vacaciones: $e');
    }
  }
}
