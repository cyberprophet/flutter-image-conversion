import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'flutter_image_conversion_platform_interface.dart';

class FlutterImageConversionWeb extends FlutterImageConversionPlatform {
  static void registerWith(Registrar registrar) {
    FlutterImageConversionPlatform.instance = FlutterImageConversionWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return 'Web';
  }

  @override
  Future<File> convertHeicToJpeg(File file) async {
    try {
      final response = await html.window.fetch(file.path);
      final blob = await response.blob();

      final isHeic = blob.type.toLowerCase().contains('heic') ||
          blob.type.toLowerCase().contains('heif') ||
          file.path.toLowerCase().contains('.heic') ||
          file.path.toLowerCase().contains('.heif');

      if (!isHeic) {
        return file;
      }

      final convertedBlob = await _convertHeicBlob(blob);
      final objectUrl = html.Url.createObjectUrlFromBlob(convertedBlob);

      return File(objectUrl);
    } catch (e) {
      print('[FlutterImageConversion] Web conversion failed: $e');
      return file;
    }
  }

  Future<html.Blob> _convertHeicBlob(html.Blob heicBlob) async {
    final options = <String, dynamic>{
      'blob': heicBlob,
      'toType': 'image/jpeg',
      'quality': 0.7,
    }.jsify() as JSObject;

    final promise = heic2any(options);
    final result = await promise.toDart;

    return result as html.Blob;
  }
}

@JS('heic2any')
external JSPromise<JSAny?> heic2any(JSObject options);
