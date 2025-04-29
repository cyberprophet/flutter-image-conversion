import 'dart:io';

import 'flutter_image_conversion_platform_interface.dart';

class FlutterImageConversion {
  Future<String?> getPlatformVersion() {
    return FlutterImageConversionPlatform.instance.getPlatformVersion();
  }

  Future<File> convertHeicToJpeg(File file) {
    return FlutterImageConversionPlatform.instance.convertHeicToJpeg(file);
  }
}
