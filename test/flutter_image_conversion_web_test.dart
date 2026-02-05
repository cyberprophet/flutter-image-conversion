import 'dart:io';

import 'package:flutter_image_conversion/flutter_image_conversion.dart';
import 'package:flutter_image_conversion/flutter_image_conversion_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock that simulates the Web platform implementation.
///
/// [FlutterImageConversionWeb] cannot be imported directly in VM tests
/// because it depends on `dart:html` and `dart:js_interop`.
/// This mock replicates the Web platform contract:
/// - getPlatformVersion() returns 'Web'
/// - convertHeicToJpeg() returns a File (simulating blob URL conversion)
class MockWebPlatform
    with MockPlatformInterfaceMixin
    implements FlutterImageConversionPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('Web');

  @override
  Future<File> convertHeicToJpeg(File file) async {
    // Simulate web behavior: HEIC files get converted (new blob URL path),
    // non-HEIC files are returned as-is
    final isHeic = file.path.toLowerCase().contains('.heic') ||
        file.path.toLowerCase().contains('.heif');

    if (!isHeic) {
      return file;
    }

    // Simulate successful conversion returning a blob URL
    return File('blob:http://localhost/converted-jpeg');
  }
}

/// Mock that simulates Web conversion failure (returns original file).
class MockWebPlatformWithConversionFailure
    with MockPlatformInterfaceMixin
    implements FlutterImageConversionPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('Web');

  @override
  Future<File> convertHeicToJpeg(File file) async {
    // Simulate web behavior on conversion failure: return original file
    return file;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterImageConversionWeb', () {
    late FlutterImageConversion plugin;
    late MockWebPlatform webPlatform;

    setUp(() {
      plugin = FlutterImageConversion();
      webPlatform = MockWebPlatform();
      FlutterImageConversionPlatform.instance = webPlatform;
    });

    group('getPlatformVersion', () {
      test('returns "Web"', () async {
        final version = await plugin.getPlatformVersion();
        expect(version, 'Web');
      });

      test('returns non-null value', () async {
        final version = await plugin.getPlatformVersion();
        expect(version, isNotNull);
      });
    });

    group('convertHeicToJpeg', () {
      test('converts HEIC file and returns new File', () async {
        final heicFile = File('/path/to/image.heic');
        final result = await plugin.convertHeicToJpeg(heicFile);

        expect(result, isA<File>());
        expect(result.path, contains('blob:'));
        expect(result.path, isNot(equals(heicFile.path)));
      });

      test('converts HEIF file and returns new File', () async {
        final heifFile = File('/path/to/image.heif');
        final result = await plugin.convertHeicToJpeg(heifFile);

        expect(result, isA<File>());
        expect(result.path, contains('blob:'));
        expect(result.path, isNot(equals(heifFile.path)));
      });

      test('returns original file for non-HEIC formats', () async {
        final jpegFile = File('/path/to/image.jpeg');
        final result = await plugin.convertHeicToJpeg(jpegFile);

        expect(result, isA<File>());
        expect(result.path, equals(jpegFile.path));
      });

      test('returns original file for PNG format', () async {
        final pngFile = File('/path/to/image.png');
        final result = await plugin.convertHeicToJpeg(pngFile);

        expect(result, isA<File>());
        expect(result.path, equals(pngFile.path));
      });

      test('handles case-insensitive HEIC extension', () async {
        final upperHeicFile = File('/path/to/image.HEIC');
        final result = await plugin.convertHeicToJpeg(upperHeicFile);

        expect(result, isA<File>());
        expect(result.path, contains('blob:'));
      });
    });

    group('convertHeicToJpeg with conversion failure', () {
      late MockWebPlatformWithConversionFailure failurePlatform;

      setUp(() {
        failurePlatform = MockWebPlatformWithConversionFailure();
        FlutterImageConversionPlatform.instance = failurePlatform;
      });

      test('returns original file on conversion failure', () async {
        final heicFile = File('/path/to/image.heic');
        final result = await plugin.convertHeicToJpeg(heicFile);

        expect(result, isA<File>());
        expect(result.path, equals(heicFile.path));
      });
    });
  });
}
