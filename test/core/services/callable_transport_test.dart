import 'package:control_horario/core/services/provisioning_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transport uses the named callable with the exact provided map',
      () async {
    final payload = <String, dynamic>{'requestId': 'request-1'};
    final transport = _RecordingCallableTransport();

    await transport.call('provisionUser', payload);

    expect(transport.name, 'provisionUser');
    expect(identical(transport.payload, payload), isTrue);
  });

  test('a fake transport works without Firebase platform channels', () async {
    final transport = _RecordingCallableTransport();

    await transport.call('status', <String, dynamic>{});

    expect(transport.name, 'status');
  });
}

class _RecordingCallableTransport implements CallableTransport {
  String? name;
  Map<String, dynamic>? payload;

  @override
  Future<Object?> call(String name, Map<String, dynamic> payload) async {
    this.name = name;
    this.payload = payload;
    return null;
  }
}
