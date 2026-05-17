import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/overtime_request_model.dart';

/// Servicio para gestionar solicitudes de horas extra en Firestore
///
/// Maneja operaciones CRUD sobre la colección:
/// overtime_requests/{requestId}
class OvertimeService {
  final FirebaseFirestore? _firestore;

  OvertimeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  OvertimeService.test() : _firestore = null;

  FirebaseFirestore get _requireFirestore {
    final firestore = _firestore;
    if (firestore == null) {
      throw StateError(
        'OvertimeService test double must override Firestore access methods',
      );
    }
    return firestore;
  }

  /// Referencia a la colección de solicitudes de horas extra
  CollectionReference<Map<String, dynamic>> get _collection =>
      _requireFirestore.collection('overtime_requests');

  /// Crea una nueva solicitud de horas extra con estado pendiente
  Future<String> createRequest({
    required String userId,
    required DateTime weekStart,
    required double requestedHours,
  }) async {
    try {
      final docRef = await _collection.add({
        'userId': userId,
        'weekStart': Timestamp.fromDate(weekStart),
        'requestedHours': requestedHours,
        'status': OvertimeRequestStatus.pending.name,
        'createdAt': Timestamp.now(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear solicitud de horas extra: $e');
    }
  }

  /// Obtiene solicitudes para un usuario en una semana específica
  Future<List<OvertimeRequestModel>> getRequestsByUserAndWeek(
    String userId,
    DateTime weekStart,
  ) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('weekStart', isEqualTo: Timestamp.fromDate(weekStart))
          .limit(500)
          .get();

      return snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes: $e');
    }
  }

  /// Aprueba una solicitud de horas extra
  Future<void> approveRequest(String id, {required String approvedBy}) async {
    try {
      await _collection.doc(id).update({
        'status': OvertimeRequestStatus.approved.name,
        'approvedBy': approvedBy,
        'approvedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al aprobar solicitud: $e');
    }
  }

  /// Rechaza una solicitud de horas extra
  Future<void> rejectRequest(String id, {required String rejectedBy}) async {
    try {
      await _collection.doc(id).update({
        'status': OvertimeRequestStatus.rejected.name,
        'rejectedBy': rejectedBy,
        'rejectedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al rechazar solicitud: $e');
    }
  }

  /// Obtiene todas las solicitudes pendientes de aprobación
  Future<List<OvertimeRequestModel>> getPendingRequests() async {
    try {
      final snapshot = await _collection
          .where('status', isEqualTo: OvertimeRequestStatus.pending.name)
          .limit(500)
          .get();

      return snapshot.docs
          .map((doc) => OvertimeRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes pendientes: $e');
    }
  }
}
