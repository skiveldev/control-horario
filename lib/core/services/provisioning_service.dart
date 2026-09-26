import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Narrow boundary for invoking protected Firebase callable functions.
///
/// Application services depend on this interface so tests can provide a fake
/// without initializing Firebase platform channels.
abstract interface class CallableTransport {
  Future<Object?> call(String name, Map<String, dynamic> payload);
}

/// Transport-level failure containing only a stable callable error code.
class CallableTransportFailure implements Exception {
  const CallableTransportFailure(this.code);

  final String code;
}

/// Production [CallableTransport] backed by the official FlutterFire SDK.
class FirebaseCallableTransport implements CallableTransport {
  FirebaseCallableTransport({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<Object?> call(String name, Map<String, dynamic> payload) async {
    try {
      final result =
          await _functions.httpsCallable(name).call<Object?>(payload);
      return result.data;
    } on FirebaseFunctionsException catch (error) {
      throw CallableTransportFailure(error.code);
    }
  }
}

class ProvisioningRequest {
  const ProvisioningRequest({
    required this.operationId,
    required this.email,
    required this.nombre,
    required this.apellido1,
    required this.role,
    this.apellido2,
    this.employeeId,
    this.dni,
    this.telefono,
    this.cargo,
    this.departamento,
    this.empresa,
    this.scheduleId,
    this.calendarId,
    this.fechaInicio,
    this.fechaFin,
    this.supervisorId,
    this.weeklyHours,
    this.isSupervisor,
    this.isActive,
  });

  final String operationId;
  final String email;
  final String nombre;
  final String apellido1;
  final String role;
  final String? apellido2;
  final String? employeeId;
  final String? dni;
  final String? telefono;
  final String? cargo;
  final String? departamento;
  final String? empresa;
  final String? scheduleId;
  final String? calendarId;
  final String? fechaInicio;
  final String? fechaFin;
  final String? supervisorId;
  final num? weeklyHours;
  final bool? isSupervisor;
  final bool? isActive;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'operationId': operationId,
      'email': email,
      'nombre': nombre,
      'apellido1': apellido1,
      'role': role,
    };
    _put(payload, 'apellido2', apellido2);
    _put(payload, 'employeeId', employeeId);
    _put(payload, 'dni', dni);
    _put(payload, 'telefono', telefono);
    _put(payload, 'cargo', cargo);
    _put(payload, 'departamento', departamento);
    _put(payload, 'empresa', empresa);
    _put(payload, 'scheduleId', scheduleId);
    _put(payload, 'calendarId', calendarId);
    _put(payload, 'fechaInicio', fechaInicio);
    _put(payload, 'fechaFin', fechaFin);
    _put(payload, 'supervisorId', supervisorId);
    _put(payload, 'weeklyHours', weeklyHours);
    _put(payload, 'isSupervisor', isSupervisor);
    _put(payload, 'isActive', isActive);
    return payload;
  }

  static void _put(Map<String, dynamic> payload, String key, Object? value) {
    if (value != null) payload[key] = value;
  }
}

enum ProvisioningStatus {
  pending('pending'),
  active('active'),
  completed('completed'),
  failed('failed'),
  manualRecovery('manual_recovery');

  const ProvisioningStatus(this.wireValue);
  final String wireValue;
}

enum ProvisioningPhase {
  authPreflight('auth_preflight'),
  authCreate('auth_create'),
  profileCommit('profile_commit');

  const ProvisioningPhase(this.wireValue);
  final String wireValue;
}

sealed class ProvisioningResult {
  const ProvisioningResult();
}

class ProvisioningSubmissionResult extends ProvisioningResult {
  const ProvisioningSubmissionResult({
    required this.operationId,
    required this.status,
  });

  final String operationId;
  final ProvisioningStatus status;
}

sealed class ProvisioningStatusResult extends ProvisioningResult {
  const ProvisioningStatusResult({
    required this.operationId,
    required this.status,
  });

  final String operationId;
  final ProvisioningStatus status;
}

class PendingProvisioningStatus extends ProvisioningStatusResult {
  const PendingProvisioningStatus({
    required super.operationId,
    required this.retryAfterSeconds,
  }) : super(status: ProvisioningStatus.pending);

  final int retryAfterSeconds;
}

class ActiveProvisioningStatus extends ProvisioningStatusResult {
  const ActiveProvisioningStatus({
    required super.operationId,
    required this.phase,
    required this.retryAfterSeconds,
  }) : super(status: ProvisioningStatus.active);

  final ProvisioningPhase phase;
  final int retryAfterSeconds;
}

class CompletedProvisioningStatus extends ProvisioningStatusResult {
  const CompletedProvisioningStatus({
    required super.operationId,
    required this.userId,
    required this.passwordResetLink,
  }) : super(status: ProvisioningStatus.completed);

  final String userId;
  final String passwordResetLink;
  bool get idempotent => true;
}

class FailedProvisioningStatus extends ProvisioningStatusResult {
  const FailedProvisioningStatus({
    required super.operationId,
    required this.terminalCode,
  }) : super(status: ProvisioningStatus.failed);

  final String terminalCode;
}

class ManualRecoveryProvisioningStatus extends ProvisioningStatusResult {
  const ManualRecoveryProvisioningStatus({
    required super.operationId,
    required this.terminalCode,
    required this.recoveryCode,
  }) : super(status: ProvisioningStatus.manualRecovery);

  final String terminalCode;
  final String recoveryCode;
}

class ProvisioningFailure extends ProvisioningResult {
  const ProvisioningFailure._(this.code);

  const ProvisioningFailure.invalidArgument() : this._('invalid-argument');
  const ProvisioningFailure.unauthenticated() : this._('unauthenticated');
  const ProvisioningFailure.permissionDenied() : this._('permission-denied');
  const ProvisioningFailure.alreadyExists() : this._('already-exists');
  const ProvisioningFailure.aborted() : this._('aborted');
  const ProvisioningFailure.notFound() : this._('not-found');
  const ProvisioningFailure.internal() : this._('internal');
  const ProvisioningFailure.unavailable() : this._('unavailable');
  const ProvisioningFailure.malformedResponse() : this._('malformed-response');
  const ProvisioningFailure.unknown() : this._('unknown');

  final String code;

  @override
  bool operator ==(Object other) =>
      other is ProvisioningFailure && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// Durable local storage for an in-flight provisioning operation identifier.
abstract interface class ProvisioningOperationStorage {
  Future<void> saveOperationId(String operationId);
  Future<String?> readOperationId();
}

/// Production storage backed by SharedPreferences.
class SharedPreferencesProvisioningOperationStorage
    implements ProvisioningOperationStorage {
  SharedPreferencesProvisioningOperationStorage({
    Future<SharedPreferences>? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance();

  static const _key = 'provisioning.operationId';
  final Future<SharedPreferences> _preferences;

  @override
  Future<String?> readOperationId() async =>
      (await _preferences).getString(_key);

  @override
  Future<void> saveOperationId(String operationId) async {
    await (await _preferences).setString(_key, operationId);
  }
}

typedef ProvisioningRequestBuilder = ProvisioningRequest Function(
  String operationId,
);
typedef ProvisioningSleeper = Future<void> Function(Duration delay);
typedef ProvisioningJitter = Duration Function(Duration delay);

/// Coordinates durable submission recovery and local status observation.
class ProvisioningWorkflow {
  ProvisioningWorkflow(
    this._service, {
    required ProvisioningOperationStorage storage,
    required String Function() operationIdFactory,
    ProvisioningSleeper? sleeper,
    ProvisioningJitter? jitter,
  })  : _storage = storage,
        _operationIdFactory = operationIdFactory,
        _sleeper = sleeper ?? Future<void>.delayed,
        _jitter = jitter ?? _identityJitter;

  final ProvisioningService _service;
  final ProvisioningOperationStorage _storage;
  final String Function() _operationIdFactory;
  final ProvisioningSleeper _sleeper;
  final ProvisioningJitter _jitter;
  Completer<void>? _resumeSignal;
  bool _cancelled = false;

  Future<ProvisioningResult> submit(ProvisioningRequestBuilder request) async {
    _cancelled = false;
    final operationId = _operationIdFactory();
    await _storage.saveOperationId(operationId);
    final result = await _service.submit(request(operationId));
    if (result is ProvisioningFailure ||
        result is! ProvisioningSubmissionResult) {
      return result;
    }
    if (_isTerminal(result.status)) return result;
    return _observe(operationId, result);
  }

  /// Resumes observation of the durable operation without resubmitting it.
  Future<ProvisioningResult?> recover({String? fingerprint}) async {
    _cancelled = false;
    final operationId = await _storage.readOperationId();
    if (operationId == null) return null;
    final result =
        await _service.getStatus(operationId, fingerprint: fingerprint);
    if (result is ProvisioningFailure || result is! ProvisioningStatusResult) {
      return result;
    }
    return _isTerminal(result.status) ? result : _observe(operationId, result);
  }

  /// Stops local observation only; the durable ID remains available for recovery.
  void cancel() {
    _cancelled = true;
    resume();
  }

  void pause() {
    _resumeSignal ??= Completer<void>();
  }

  void resume() {
    final signal = _resumeSignal;
    _resumeSignal = null;
    if (signal != null && !signal.isCompleted) signal.complete();
  }

  Future<ProvisioningResult> _observe(
    String operationId,
    ProvisioningResult latest,
  ) async {
    var attempt = 0;
    var retryAfterSeconds = _retryAfterSeconds(latest);
    while (!_cancelled) {
      await _waitUntilResumed();
      if (_cancelled) break;
      final localDelay = _jitter(_localDelay(attempt));
      final backendDelay = Duration(seconds: retryAfterSeconds ?? 0);
      await _sleeper(localDelay >= backendDelay ? localDelay : backendDelay);
      await _waitUntilResumed();
      if (_cancelled) break;

      final result = await _service.getStatus(operationId);
      if (result is ProvisioningFailure ||
          result is! ProvisioningStatusResult) {
        return result;
      }
      latest = result;
      if (_isTerminal(result.status)) return result;
      retryAfterSeconds = _retryAfterSeconds(result);
      attempt += 1;
    }
    return latest;
  }

  Future<void> _waitUntilResumed() async {
    while (_resumeSignal != null && !_cancelled) {
      await _resumeSignal!.future;
    }
  }

  static Duration _identityJitter(Duration delay) => delay;

  static Duration _localDelay(int attempt) => Duration(
        seconds: switch (attempt) {
          0 => 1,
          1 => 2,
          2 => 4,
          3 => 8,
          _ => 15,
        },
      );

  static int? _retryAfterSeconds(ProvisioningResult result) => switch (result) {
        PendingProvisioningStatus(:final retryAfterSeconds) =>
          retryAfterSeconds,
        ActiveProvisioningStatus(:final retryAfterSeconds) => retryAfterSeconds,
        _ => null,
      };

  static bool _isTerminal(ProvisioningStatus status) => switch (status) {
        ProvisioningStatus.pending || ProvisioningStatus.active => false,
        ProvisioningStatus.completed ||
        ProvisioningStatus.failed ||
        ProvisioningStatus.manualRecovery =>
          true,
      };
}

class ProvisioningService {
  const ProvisioningService(this._transport);

  final CallableTransport _transport;

  Future<ProvisioningResult> submit(ProvisioningRequest request) async {
    final response = await _call('submitProvisioning', request.toJson());
    if (response is ProvisioningFailure) return response;
    final map = _map(response);
    if (map == null) return const ProvisioningFailure.malformedResponse();
    final operationId = _string(map, 'operationId');
    final status = _status(_string(map, 'status'));
    if (operationId == null || status == null) {
      return const ProvisioningFailure.malformedResponse();
    }
    return ProvisioningSubmissionResult(
        operationId: operationId, status: status);
  }

  Future<ProvisioningResult> getStatus(
    String operationId, {
    String? fingerprint,
  }) async {
    final payload = <String, dynamic>{'operationId': operationId};
    if (fingerprint != null) payload['fingerprint'] = fingerprint;
    final response = await _call('getProvisioningStatus', payload);
    if (response is ProvisioningFailure) return response;
    return _decodeStatus(response);
  }

  Future<Object?> _call(String name, Map<String, dynamic> payload) async {
    try {
      return await _transport.call(name, payload);
    } on CallableTransportFailure catch (error) {
      return _failureFor(error.code);
    } catch (_) {
      return const ProvisioningFailure.unknown();
    }
  }

  ProvisioningResult _decodeStatus(Object? response) {
    final map = _map(response);
    final operationId = map == null ? null : _string(map, 'operationId');
    final status = map == null ? null : _status(_string(map, 'status'));
    if (map == null || operationId == null || status == null) {
      return const ProvisioningFailure.malformedResponse();
    }
    switch (status) {
      case ProvisioningStatus.pending:
        final retryAfterSeconds = _int(map, 'retryAfterSeconds');
        return retryAfterSeconds == null
            ? const ProvisioningFailure.malformedResponse()
            : PendingProvisioningStatus(
                operationId: operationId,
                retryAfterSeconds: retryAfterSeconds,
              );
      case ProvisioningStatus.active:
        final phase = _phase(_string(map, 'phase'));
        final retryAfterSeconds = _int(map, 'retryAfterSeconds');
        return phase == null || retryAfterSeconds == null
            ? const ProvisioningFailure.malformedResponse()
            : ActiveProvisioningStatus(
                operationId: operationId,
                phase: phase,
                retryAfterSeconds: retryAfterSeconds,
              );
      case ProvisioningStatus.completed:
        final userId = _string(map, 'userId');
        final idempotent = map['idempotent'];
        final passwordResetLink = _string(map, 'passwordResetLink');
        return userId == null || idempotent != true || passwordResetLink == null
            ? const ProvisioningFailure.malformedResponse()
            : CompletedProvisioningStatus(
                operationId: operationId,
                userId: userId,
                passwordResetLink: passwordResetLink,
              );
      case ProvisioningStatus.failed:
        final terminalCode = _string(map, 'terminalCode');
        return terminalCode == null
            ? const ProvisioningFailure.malformedResponse()
            : FailedProvisioningStatus(
                operationId: operationId,
                terminalCode: terminalCode,
              );
      case ProvisioningStatus.manualRecovery:
        final terminalCode = _string(map, 'terminalCode');
        final recoveryCode = _string(map, 'recoveryCode');
        return terminalCode == null || recoveryCode == null
            ? const ProvisioningFailure.malformedResponse()
            : ManualRecoveryProvisioningStatus(
                operationId: operationId,
                terminalCode: terminalCode,
                recoveryCode: recoveryCode,
              );
    }
  }

  static Map<Object?, Object?>? _map(Object? value) =>
      value is Map ? Map<Object?, Object?>.from(value) : null;

  static String? _string(Map<Object?, Object?> map, String key) {
    final value = map[key];
    return value is String ? value : null;
  }

  static int? _int(Map<Object?, Object?> map, String key) {
    final value = map[key];
    return value is int ? value : null;
  }

  static ProvisioningStatus? _status(String? value) {
    for (final status in ProvisioningStatus.values) {
      if (status.wireValue == value) return status;
    }
    return null;
  }

  static ProvisioningPhase? _phase(String? value) {
    for (final phase in ProvisioningPhase.values) {
      if (phase.wireValue == value) return phase;
    }
    return null;
  }

  static ProvisioningFailure _failureFor(String code) => switch (code) {
        'invalid-argument' => const ProvisioningFailure.invalidArgument(),
        'unauthenticated' => const ProvisioningFailure.unauthenticated(),
        'permission-denied' => const ProvisioningFailure.permissionDenied(),
        'already-exists' => const ProvisioningFailure.alreadyExists(),
        'aborted' => const ProvisioningFailure.aborted(),
        'not-found' => const ProvisioningFailure.notFound(),
        'internal' => const ProvisioningFailure.internal(),
        'unavailable' => const ProvisioningFailure.unavailable(),
        _ => const ProvisioningFailure.unknown(),
      };
}
