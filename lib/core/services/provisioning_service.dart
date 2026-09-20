import 'package:cloud_functions/cloud_functions.dart';

/// Narrow boundary for invoking protected Firebase callable functions.
///
/// Application services depend on this interface so tests can provide a fake
/// without initializing Firebase platform channels.
abstract interface class CallableTransport {
  Future<Object?> call(String name, Map<String, dynamic> payload);
}

/// Production [CallableTransport] backed by the official FlutterFire SDK.
class FirebaseCallableTransport implements CallableTransport {
  FirebaseCallableTransport({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<Object?> call(String name, Map<String, dynamic> payload) async {
    final result = await _functions.httpsCallable(name).call<Object?>(payload);
    return result.data;
  }
}
