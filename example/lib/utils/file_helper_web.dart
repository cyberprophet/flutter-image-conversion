import 'dart:io';
import 'dart:js_interop';

import 'package:file_picker/file_picker.dart';
import 'package:web/web.dart' as web;

Future<File> createFile(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes == null) {
    throw StateError('File bytes are unavailable on web. Use withData: true.');
  }

  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: _detectMimeType(file)),
  );
  final url = web.URL.createObjectURL(blob);

  return File(url);
}

String _detectMimeType(PlatformFile file) {
  final extension = (file.extension ?? _extensionFromName(file.name))
      .toLowerCase();
  if (extension == 'heic') {
    return 'image/heic';
  }
  if (extension == 'heif') {
    return 'image/heif';
  }
  return 'application/octet-stream';
}

String _extensionFromName(String name) {
  final dotIndex = name.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == name.length - 1) {
    return '';
  }
  return name.substring(dotIndex + 1);
}
