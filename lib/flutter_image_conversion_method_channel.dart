import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_image_conversion_platform_interface.dart';

/// An implementation of [FlutterImageConversionPlatform] that uses method channels.
class MethodChannelFlutterImageConversion
    extends FlutterImageConversionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_image_conversion');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<File> convertHeicToJpeg(File file) async {
    final String? convertedPath = await methodChannel.invokeMethod(
      'convertHeicToJpeg',
      {'path': file.path},
    );
    return convertedPath != null ? File(convertedPath) : file;
  }
}
