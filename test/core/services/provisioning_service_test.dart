import 'package:control_horario/core/services/provisioning_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final request = ProvisioningRequest(
      operationId: 'op-1',
      email: 'ada@example.com',
      nombre: 'Ada',
      apellido1: 'Lovelace',
      role: 'employee');
  group('ProvisioningRequest', () {
    test('emits only required provided fields', () {
      expect(request.toJson(), <String, dynamic>{
        'operationId': 'op-1',
        'email': 'ada@example.com',
        'nombre': 'Ada',
        'apellido1': 'Lovelace',
        'role': 'employee'
      });
    });
    test('preserves every supported optional field without displayName', () {
      final map = ProvisioningRequest(
              operationId: 'op-2',
              email: 'grace@example.com',
              nombre: 'Grace',
              apellido1: 'Hopper',
              role: 'supervisor',
              apellido2: 'Murray',
              employeeId: 'E-1',
              dni: '123',
              telefono: '+54',
              cargo: 'Lead',
              departamento: 'Engineering',
              empresa: 'Example',
              scheduleId: 'schedule-1',
              calendarId: 'calendar-1',
              fechaInicio: '2025-01-01',
              fechaFin: '2025-12-31',
              supervisorId: 'supervisor-1',
              weeklyHours: 37.5,
              isSupervisor: true,
              isActive: false)
          .toJson();
      expect(map, <String, dynamic>{
        'operationId': 'op-2',
        'email': 'grace@example.com',
        'nombre': 'Grace',
        'apellido1': 'Hopper',
        'role': 'supervisor',
        'apellido2': 'Murray',
        'employeeId': 'E-1',
        'dni': '123',
        'telefono': '+54',
        'cargo': 'Lead',
        'departamento': 'Engineering',
        'empresa': 'Example',
        'scheduleId': 'schedule-1',
        'calendarId': 'calendar-1',
        'fechaInicio': '2025-01-01',
        'fechaFin': '2025-12-31',
        'supervisorId': 'supervisor-1',
        'weeklyHours': 37.5,
        'isSupervisor': true,
        'isActive': false
      });
      expect(map.containsKey('displayName'), isFalse);
    });
  });
  group('ProvisioningService', () {
    test('submits with its exact callable name and decodes every status',
        () async {
      for (final status in ProvisioningStatus.values) {
        final transport = _FakeTransport.responses(<Object?>[
          <String, dynamic>{'operationId': 'op-1', 'status': status.wireValue}
        ]);
        final result = await ProvisioningService(transport).submit(request);
        expect(transport.calls.single.name, 'submitProvisioning');
        expect(transport.calls.single.payload, request.toJson());
        expect((result as ProvisioningSubmissionResult).operationId, 'op-1');
        expect(result.status, status);
      }
    });
    test('maps malformed submit success to malformed response', () async {
      final result =
          await ProvisioningService(_FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'op-1'}
      ])).submit(request);
      expect(result, const ProvisioningFailure.malformedResponse());
    });
    test('reuses the exact operation id for repeated submit attempts',
        () async {
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'op-1', 'status': 'pending'},
        <String, dynamic>{'operationId': 'op-1', 'status': 'pending'}
      ]);
      final service = ProvisioningService(transport);
      await service.submit(request);
      await service.submit(request);
      expect(transport.calls, hasLength(2));
      expect(transport.calls[0].payload, request.toJson());
      expect(transport.calls[1].payload, request.toJson());
    });
    test('gets status with exact callable payload and omits null fingerprint',
        () async {
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{
          'operationId': 'op-1',
          'status': 'pending',
          'retryAfterSeconds': 3
        }
      ]);
      final result = await ProvisioningService(transport).getStatus('op-1');
      expect(transport.calls.single.name, 'getProvisioningStatus');
      expect(transport.calls.single.payload,
          <String, dynamic>{'operationId': 'op-1'});
      expect(result, isA<PendingProvisioningStatus>());
    });
    test('includes a provided fingerprint', () async {
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{
          'operationId': 'op-1',
          'status': 'pending',
          'retryAfterSeconds': 3
        }
      ]);
      await ProvisioningService(transport).getStatus('op-1', fingerprint: 'fp');
      expect(transport.calls.single.payload,
          <String, dynamic>{'operationId': 'op-1', 'fingerprint': 'fp'});
    });
    test('decodes all strict status variants and ignores extra keys', () async {
      final cases = <Object?>[
        <String, dynamic>{
          'operationId': 'op',
          'status': 'pending',
          'retryAfterSeconds': 1,
          'private': true
        },
        <String, dynamic>{
          'operationId': 'op',
          'status': 'active',
          'phase': 'auth_create',
          'retryAfterSeconds': 2
        },
        <String, dynamic>{
          'operationId': 'op',
          'status': 'completed',
          'userId': 'uid',
          'idempotent': true,
          'passwordResetLink': 'https://reset'
        },
        <String, dynamic>{
          'operationId': 'op',
          'status': 'failed',
          'terminalCode': 'internal'
        },
        <String, dynamic>{
          'operationId': 'op',
          'status': 'manual_recovery',
          'terminalCode': 'internal',
          'recoveryCode': 'recover'
        },
      ];
      final results = <ProvisioningResult>[];
      for (final response in cases) {
        results.add(await ProvisioningService(
            _FakeTransport.responses(<Object?>[response])).getStatus('op'));
      }
      expect(results[0], isA<PendingProvisioningStatus>());
      expect((results[1] as ActiveProvisioningStatus).phase,
          ProvisioningPhase.authCreate);
      expect((results[2] as CompletedProvisioningStatus).passwordResetLink,
          'https://reset');
      expect(results[3], isA<FailedProvisioningStatus>());
      expect((results[4] as ManualRecoveryProvisioningStatus).recoveryCode,
          'recover');
    });
    test('returns malformed response for invalid successful payloads',
        () async {
      final invalidResponses = <Object?>[
        null,
        <String, dynamic>{'operationId': 'op'},
        <String, dynamic>{'operationId': 1, 'status': 'pending'},
        <String, dynamic>{'operationId': 'op', 'status': 'unknown'},
        <String, dynamic>{
          'operationId': 'op',
          'status': 'active',
          'phase': 'unknown',
          'retryAfterSeconds': 1
        },
        <String, dynamic>{
          'operationId': 'op',
          'status': 'pending',
          'retryAfterSeconds': '1'
        },
        <String, dynamic>{
          'operationId': 'op',
          'status': 'completed',
          'userId': 'u',
          'idempotent': false,
          'passwordResetLink': 'link'
        },
        <String, dynamic>{
          'operationId': 'op',
          'status': 'failed',
          'terminalCode': 1
        },
        <String, dynamic>{
          'operationId': 'op',
          'status': 'manual_recovery',
          'terminalCode': 'x'
        }
      ];
      for (final response in invalidResponses) {
        expect(
            await ProvisioningService(
                _FakeTransport.responses(<Object?>[response])).getStatus('op'),
            const ProvisioningFailure.malformedResponse());
      }
    });
    test('maps the eight callable failures and unknown exceptions', () async {
      const mappings = <String, ProvisioningFailure>{
        'invalid-argument': ProvisioningFailure.invalidArgument(),
        'unauthenticated': ProvisioningFailure.unauthenticated(),
        'permission-denied': ProvisioningFailure.permissionDenied(),
        'already-exists': ProvisioningFailure.alreadyExists(),
        'aborted': ProvisioningFailure.aborted(),
        'not-found': ProvisioningFailure.notFound(),
        'internal': ProvisioningFailure.internal(),
        'unavailable': ProvisioningFailure.unavailable()
      };
      for (final entry in mappings.entries) {
        expect(
            await ProvisioningService(_FakeTransport.throwing(
                    CallableTransportFailure(entry.key)))
                .submit(request),
            entry.value);
      }
      expect(
          await ProvisioningService(_FakeTransport.throwing(
                  CallableTransportFailure('failed-precondition')))
              .submit(request),
          const ProvisioningFailure.unknown());
      expect(
          await ProvisioningService(
                  _FakeTransport.throwing(CallableTransportFailure('other')))
              .submit(request),
          const ProvisioningFailure.unknown());
      expect(
          await ProvisioningService(_FakeTransport.throwing(StateError('nope')))
              .submit(request),
          const ProvisioningFailure.unknown());
      expect(
          await ProvisioningService(_FakeTransport.throwing(
                  CallableTransportFailure('unavailable')))
              .getStatus('op'),
          const ProvisioningFailure.unavailable());
      expect(
          await ProvisioningService(
                  _FakeTransport.throwing(CallableTransportFailure('other')))
              .getStatus('op'),
          const ProvisioningFailure.unknown());
    });
  });
}

class _FakeTransport implements CallableTransport {
  _FakeTransport.responses(this._responses) : _error = null;
  _FakeTransport.throwing(this._error) : _responses = const <Object?>[];
  final List<Object?> _responses;
  final Object? _error;
  final calls = <_Call>[];
  @override
  Future<Object?> call(String name, Map<String, dynamic> payload) async {
    calls.add(_Call(name, payload));
    if (_error != null) throw _error;
    return _responses.removeAt(0);
  }
}

class _Call {
  const _Call(this.name, this.payload);
  final String name;
  final Map<String, dynamic> payload;
}
