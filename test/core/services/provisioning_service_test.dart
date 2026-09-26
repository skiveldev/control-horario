import 'dart:async';

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

  group('ProvisioningWorkflow', () {
    test('persists a factory operation id before submit and polls with delays',
        () async {
      final storage = _FakeStorage();
      final delays = <Duration>[];
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'generated', 'status': 'pending'},
        <String, dynamic>{
          'operationId': 'generated',
          'status': 'pending',
          'retryAfterSeconds': 3,
        },
        <String, dynamic>{
          'operationId': 'generated',
          'status': 'active',
          'phase': 'auth_create',
          'retryAfterSeconds': 1,
        },
        <String, dynamic>{
          'operationId': 'generated',
          'status': 'completed',
          'userId': 'uid',
          'idempotent': true,
          'passwordResetLink': 'https://reset',
        },
      ]);
      final workflow = ProvisioningWorkflow(
        ProvisioningService(transport),
        storage: storage,
        operationIdFactory: () => 'generated',
        sleeper: (delay) async => delays.add(delay),
        jitter: (delay) => delay,
      );

      final result = await workflow.submit(_requestFor);

      expect(storage.savedIds, <String>['generated']);
      expect(transport.calls.first.payload['operationId'], 'generated');
      expect(delays, <Duration>[
        Duration(seconds: 1),
        Duration(seconds: 3),
        Duration(seconds: 4),
      ]);
      expect(result, isA<CompletedProvisioningStatus>());
    });

    test('recovers a persisted id through status without resubmitting',
        () async {
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{
          'operationId': 'saved',
          'status': 'failed',
          'terminalCode': 'internal',
        },
      ]);
      final workflow = ProvisioningWorkflow(
        ProvisioningService(transport),
        storage: _FakeStorage(initialId: 'saved'),
        operationIdFactory: () => 'unused',
        sleeper: (_) async {},
      );

      final result = await workflow.recover();

      expect(transport.calls.single.name, 'getProvisioningStatus');
      expect(result, isA<FailedProvisioningStatus>());
    });

    test('does not poll terminal submit results and retains the id on failure',
        () async {
      final storage = _FakeStorage();
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'generated', 'status': 'completed'},
      ]);
      final workflow = ProvisioningWorkflow(
        ProvisioningService(transport),
        storage: storage,
        operationIdFactory: () => 'generated',
        sleeper: (_) async => fail('terminal submit must not sleep'),
      );

      final result = await workflow.submit(_requestFor);

      expect(result, isA<ProvisioningSubmissionResult>());
      expect(transport.calls, hasLength(1));
      expect(storage.savedIds, <String>['generated']);
    });

    test('cancellation stops observation without clearing the persisted id',
        () async {
      final storage = _FakeStorage();
      late ProvisioningWorkflow workflow;
      workflow = ProvisioningWorkflow(
        ProvisioningService(_FakeTransport.responses(<Object?>[
          <String, dynamic>{'operationId': 'generated', 'status': 'pending'},
        ])),
        storage: storage,
        operationIdFactory: () => 'generated',
        sleeper: (_) async => workflow.cancel(),
      );

      final result = await workflow.submit(_requestFor);

      expect(result, isA<ProvisioningSubmissionResult>());
      expect(storage.savedIds, <String>['generated']);
    });

    test('caps local delays and never lets backend retry shorten them',
        () async {
      final delays = <Duration>[];
      final pending = <String, dynamic>{
        'operationId': 'generated',
        'status': 'pending',
        'retryAfterSeconds': 1,
      };
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'generated', 'status': 'pending'},
        pending,
        pending,
        pending,
        pending,
        <String, dynamic>{
          'operationId': 'generated',
          'status': 'pending',
          'retryAfterSeconds': 20,
        },
        <String, dynamic>{
          'operationId': 'generated',
          'status': 'completed',
          'userId': 'uid',
          'idempotent': true,
          'passwordResetLink': 'https://reset',
        },
      ]);
      final workflow = ProvisioningWorkflow(
        ProvisioningService(transport),
        storage: _FakeStorage(),
        operationIdFactory: () => 'generated',
        sleeper: (delay) async => delays.add(delay),
        jitter: (delay) => delay,
      );

      await workflow.submit(_requestFor);

      expect(delays, <Duration>[
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
        Duration(seconds: 8),
        Duration(seconds: 15),
        Duration(seconds: 20),
      ]);
    });

    test('waits for durable persistence before starting submit', () async {
      final saveGate = Completer<void>();
      final storage = _FakeStorage(saveGate: saveGate.future);
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'generated', 'status': 'completed'},
      ]);
      final workflow = ProvisioningWorkflow(
        ProvisioningService(transport),
        storage: storage,
        operationIdFactory: () => 'generated',
      );

      final result = workflow.submit(_requestFor);
      await storage.saveStarted.future;
      expect(transport.calls, isEmpty);

      saveGate.complete();
      expect(await result, isA<ProvisioningSubmissionResult>());
    });

    test('jitter changes local delay while backend retry remains a lower bound',
        () async {
      final delays = <Duration>[];
      final workflow = ProvisioningWorkflow(
        ProvisioningService(_FakeTransport.responses(<Object?>[
          <String, dynamic>{'operationId': 'generated', 'status': 'pending'},
          <String, dynamic>{
            'operationId': 'generated',
            'status': 'pending',
            'retryAfterSeconds': 5,
          },
          <String, dynamic>{
            'operationId': 'generated',
            'status': 'completed',
            'userId': 'uid',
            'idempotent': true,
            'passwordResetLink': 'https://reset',
          },
        ])),
        storage: _FakeStorage(),
        operationIdFactory: () => 'generated',
        sleeper: (delay) async => delays.add(delay),
        jitter: (delay) => delay + const Duration(seconds: 2),
      );

      await workflow.submit(_requestFor);

      expect(delays, <Duration>[Duration(seconds: 3), Duration(seconds: 5)]);
    });

    test('terminal statuses and failures stop polling', () async {
      for (final status in <ProvisioningStatus>[
        ProvisioningStatus.completed,
        ProvisioningStatus.failed,
        ProvisioningStatus.manualRecovery,
      ]) {
        final transport = _FakeTransport.responses(<Object?>[
          <String, dynamic>{
            'operationId': 'generated',
            'status': status.wireValue
          },
        ]);
        final result = await ProvisioningWorkflow(
          ProvisioningService(transport),
          storage: _FakeStorage(),
          operationIdFactory: () => 'generated',
          sleeper: (_) async => fail('terminal submit must not sleep'),
        ).submit(_requestFor);
        expect(result, isA<ProvisioningSubmissionResult>());
        expect(transport.calls, hasLength(1));
      }

      for (final error in <Object?>[
        const CallableTransportFailure('invalid-argument'),
        const CallableTransportFailure('unauthenticated'),
        const CallableTransportFailure('permission-denied'),
        const CallableTransportFailure('already-exists'),
        const CallableTransportFailure('aborted'),
        const CallableTransportFailure('not-found'),
        const CallableTransportFailure('internal'),
        const CallableTransportFailure('unavailable'),
        StateError('unknown'),
      ]) {
        final submitTransport = _FakeTransport.throwing(error);
        final submitResult = await ProvisioningWorkflow(
          ProvisioningService(submitTransport),
          storage: _FakeStorage(),
          operationIdFactory: () => 'generated',
        ).submit(_requestFor);
        expect(submitResult, isA<ProvisioningFailure>());
        expect(submitTransport.calls, hasLength(1));

        final statusTransport = _FakeTransport.responses(<Object?>[
          <String, dynamic>{'operationId': 'generated', 'status': 'pending'},
        ])
          ..nextError = error
          ..errorAfterCalls = 1;
        final statusResult = await ProvisioningWorkflow(
          ProvisioningService(statusTransport),
          storage: _FakeStorage(),
          operationIdFactory: () => 'generated',
          sleeper: (_) async {},
        ).submit(_requestFor);
        expect(statusResult, isA<ProvisioningFailure>());
        expect(statusTransport.calls, hasLength(2));
      }
    });

    test('malformed submit and status responses stop polling', () async {
      final submitTransport = _FakeTransport.responses(<Object?>[null]);
      final submitResult = await ProvisioningWorkflow(
        ProvisioningService(submitTransport),
        storage: _FakeStorage(),
        operationIdFactory: () => 'generated',
      ).submit(_requestFor);
      expect(submitResult, const ProvisioningFailure.malformedResponse());
      expect(submitTransport.calls, hasLength(1));

      final statusTransport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'generated', 'status': 'pending'},
        null,
      ]);
      final statusResult = await ProvisioningWorkflow(
        ProvisioningService(statusTransport),
        storage: _FakeStorage(),
        operationIdFactory: () => 'generated',
        sleeper: (_) async {},
      ).submit(_requestFor);
      expect(statusResult, const ProvisioningFailure.malformedResponse());
      expect(statusTransport.calls, hasLength(2));
    });

    test('pause during an active delay blocks the next status call', () async {
      final delayStarted = Completer<void>();
      final delayFinished = Completer<void>();
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'generated', 'status': 'pending'},
        <String, dynamic>{
          'operationId': 'generated',
          'status': 'completed',
          'userId': 'uid',
          'idempotent': true,
          'passwordResetLink': 'https://reset',
        },
      ]);
      final workflow = ProvisioningWorkflow(
        ProvisioningService(transport),
        storage: _FakeStorage(),
        operationIdFactory: () => 'generated',
        sleeper: (_) async {
          delayStarted.complete();
          await delayFinished.future;
        },
      );

      final result = workflow.submit(_requestFor);
      await delayStarted.future;
      workflow.pause();
      delayFinished.complete();
      await Future<void>.value();
      await Future<void>.value();
      expect(transport.calls, hasLength(1));

      workflow.resume();
      expect(await result, isA<CompletedProvisioningStatus>());
    });

    test('pause defers observation until resumed', () async {
      final gate = Completer<void>();
      final transport = _FakeTransport.responses(<Object?>[
        <String, dynamic>{'operationId': 'generated', 'status': 'pending'},
        <String, dynamic>{
          'operationId': 'generated',
          'status': 'completed',
          'userId': 'uid',
          'idempotent': true,
          'passwordResetLink': 'https://reset',
        },
      ]);
      final workflow = ProvisioningWorkflow(
        ProvisioningService(transport),
        storage: _FakeStorage(),
        operationIdFactory: () => 'generated',
        sleeper: (_) => gate.future,
      );
      workflow.pause();

      final result = workflow.submit(_requestFor);
      await Future<void>.delayed(Duration.zero);
      expect(transport.calls, hasLength(1));

      workflow.resume();
      gate.complete();
      expect(await result, isA<CompletedProvisioningStatus>());
    });
  });
}

ProvisioningRequest _requestFor(String operationId) => ProvisioningRequest(
      operationId: operationId,
      email: 'ada@example.com',
      nombre: 'Ada',
      apellido1: 'Lovelace',
      role: 'employee',
    );

class _FakeStorage implements ProvisioningOperationStorage {
  _FakeStorage({this.initialId, this.saveGate});

  final String? initialId;
  final Future<void>? saveGate;
  final savedIds = <String>[];
  final saveStarted = Completer<void>();

  @override
  Future<String?> readOperationId() async => initialId;

  @override
  Future<void> saveOperationId(String operationId) async {
    savedIds.add(operationId);
    saveStarted.complete();
    await saveGate;
  }
}

class _FakeTransport implements CallableTransport {
  _FakeTransport.responses(this._responses) : _error = null;
  _FakeTransport.throwing(this._error) : _responses = const <Object?>[];
  final List<Object?> _responses;
  final Object? _error;
  Object? nextError;
  int? errorAfterCalls;
  final calls = <_Call>[];
  @override
  Future<Object?> call(String name, Map<String, dynamic> payload) async {
    calls.add(_Call(name, payload));
    if (_error != null) throw _error;
    if (nextError != null && calls.length > (errorAfterCalls ?? 0)) {
      throw nextError!;
    }
    return _responses.removeAt(0);
  }
}

class _Call {
  const _Call(this.name, this.payload);
  final String name;
  final Map<String, dynamic> payload;
}
