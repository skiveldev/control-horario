import 'package:control_horario/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initializes Firebase before awaiting App Check activation', () async {
    final events = <String>[];

    await app.initializeFirebaseWithAppCheck(
      initializeFirebase: () async => events.add('firebase'),
      activateAppCheck: () async {
        expect(events, ['firebase']);
        events.add('app-check');
      },
    );

    expect(events, ['firebase', 'app-check']);
  });

  test('does not continue when App Check activation fails', () async {
    var continued = false;

    await expectLater(
      app
          .initializeFirebaseWithAppCheck(
            initializeFirebase: () async {},
            activateAppCheck: () async => throw StateError('activation failed'),
          )
          .then((_) => continued = true),
      throwsStateError,
    );

    expect(continued, isFalse);
  });

  test('awaits App Check activation instead of firing and forgetting',
      () async {
    var activationFinished = false;

    await app.initializeFirebaseWithAppCheck(
      initializeFirebase: () async {},
      activateAppCheck: () async {
        await Future<void>.delayed(Duration.zero);
        activationFinished = true;
      },
    );

    expect(activationFinished, isTrue);
  });
}
