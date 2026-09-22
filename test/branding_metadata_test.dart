import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public platform metadata uses the canonical brand', () {
    final androidManifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
    final webIndex = File('web/index.html').readAsStringSync();
    final webManifest = File('web/manifest.json').readAsStringSync();

    expect(androidManifest, contains('android:label="controlhorario-rega"'));
    expect(
        infoPlist,
        contains(
            '<key>CFBundleDisplayName</key>\n\t<string>controlhorario-rega</string>'));
    expect(webIndex,
        contains('apple-mobile-web-app-title" content="controlhorario-rega"'));
    expect(webIndex, contains('<title>controlhorario-rega</title>'));
    expect(webManifest, contains('"name": "controlhorario-rega"'));
    expect(webManifest, contains('"short_name": "controlhorario-rega"'));

    expect(
        infoPlist,
        contains(
            '<key>CFBundleName</key>\n\t<string>control_horario</string>'));
    expect(
      infoPlist,
      contains(
          '<key>CFBundleIdentifier</key>\n\t<string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>'),
    );
    expect(androidManifest, contains('android:name=".MainActivity"'));
  });
}
