import 'dart:async';
import 'dart:io';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

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
      final response = await web.window.fetch(file.path.toJS).toDart;
      final blob = await response.blob().toDart;

      final isHeic =
          blob.type.toLowerCase().contains('heic') ||
          blob.type.toLowerCase().contains('heif') ||
          file.path.toLowerCase().contains('.heic') ||
          file.path.toLowerCase().contains('.heif');

      if (!isHeic) {
        return file;
      }

      final convertedBlob = await _convertHeicBlob(blob);
      final objectUrl = web.URL.createObjectURL(convertedBlob);

      return File(objectUrl);
    } catch (e) {
      if (kDebugMode) {
        print('[FlutterImageConversion] Web conversion failed: $e');
      }
      return file;
    }
  }

  @override
  Future<Uint8List> convertHeicToJpegBytes(Uint8List bytes) async {
    // Fast-path: if it doesn't look like HEIC/HEIF, don't touch it.
    if (!_looksLikeHeicOrHeif(bytes)) return bytes;

    try {
      // Providing a MIME type helps libraries that check blob.type.
      final blob = web.Blob(
        [bytes.toJS].toJS,
        web.BlobPropertyBag(type: 'image/heic'),
      );

      final convertedBlob = await _convertHeicBlob(blob);

      // Use Response API to read blob bytes (simpler than FileReader).
      final response = web.Response(convertedBlob);
      final arrayBuffer = await response.arrayBuffer().toDart;
      return arrayBuffer.toDart.asUint8List();
    } catch (e) {
      // Best-effort fallback: leave bytes unchanged if conversion fails.
      // ignore: avoid_print
      print('[FlutterImageConversion] Web bytes conversion failed: $e');
      return bytes;
    }
  }

  bool _looksLikeHeicOrHeif(Uint8List bytes) {
    // ISO BMFF header needs at least: size(4) + 'ftyp'(4) + major_brand(4)
    if (bytes.length < 12) return false;

    // In ISO BMFF, box type 'ftyp' is at offset 4 (bytes[4..7]), not [0..3].
    final isFtyp =
        bytes[4] == 0x66 && // f
        bytes[5] == 0x74 && // t
        bytes[6] == 0x79 && // y
        bytes[7] == 0x70; // p
    if (!isFtyp) return false;

    String brandAt(int offset) =>
        String.fromCharCodes(bytes.sublist(offset, offset + 4));

    // Major brand is at offset 8..11.
    final majorBrand = brandAt(8);

    // Keep this set conservative to avoid misclassifying MP4/QuickTime.
    const heifBrands = <String>{
      'heic', // HEIC image
      'heix', // HEIC image sequence
      'mif1', // HEIF (base)
      'msf1', // HEIF sequence (base)
    };

    if (heifBrands.contains(majorBrand)) return true;

    // Compatible brands start after: minor_version (4 bytes) at offset 12..15,
    // so compatible list begins at offset 16.
    // Scan a small prefix to avoid work; ftyp box is typically very early.
    final max = bytes.length < 64 ? bytes.length : 64;
    for (var i = 16; i + 4 <= max; i += 4) {
      if (heifBrands.contains(brandAt(i))) return true;
    }

    return false;
  }

  Future<web.Blob> _convertHeicBlob(web.Blob heicBlob) async {
    final options =
        <String, dynamic>{
              'blob': heicBlob,
              'toType': 'image/jpeg',
              'quality': 0.7,
            }.jsify()
            as JSObject;

    final promise = heic2any(options);
    final result = await promise.toDart;

    return result as web.Blob;
  }
}

@JS('heic2any')
external JSPromise<JSAny?> heic2any(JSObject options);
