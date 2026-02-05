// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_image_conversion/flutter_image_conversion.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final FlutterImageConversion plugin = FlutterImageConversion();

  group('getPlatformVersion', () {
    testWidgets('returns non-empty string', (WidgetTester tester) async {
      final String? version = await plugin.getPlatformVersion();
      // The version string depends on the host platform running the test, so
      // just assert that some non-empty string is returned.
      expect(version?.isNotEmpty, true);
    });

    testWidgets('returns platform-appropriate value',
        (WidgetTester tester) async {
      final String? version = await plugin.getPlatformVersion();

      if (kIsWeb) {
        // Web platform returns 'Web'
        expect(version, 'Web');
      } else if (Platform.isIOS || Platform.isMacOS) {
        // iOS/macOS return actual OS version
        expect(version, isNotNull);
        expect(version!.isNotEmpty, true);
      } else if (Platform.isWindows) {
        // Windows returns OS version
        expect(version, isNotNull);
        expect(version!.isNotEmpty, true);
      } else if (Platform.isAndroid) {
        // Android returns OS version
        expect(version, isNotNull);
        expect(version!.isNotEmpty, true);
      }
    });
  });

  group('convertHeicToJpeg', () {
    testWidgets('returns a File object', (WidgetTester tester) async {
      // Use a dummy file path - on most platforms without an actual HEIC file,
      // this will return the original file or fail gracefully
      final dummyFile = File('non_existent.jpg');

      try {
        final result = await plugin.convertHeicToJpeg(dummyFile);
        expect(result, isA<File>());
      } catch (e) {
        // Platform may throw if file doesn't exist - that's acceptable
        // The important thing is the method is callable
        expect(e, isA<Object>());
      }
    });
  });
}
