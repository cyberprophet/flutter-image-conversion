import 'dart:html' as html;
import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<File> createFile(PlatformFile file) async {
  final bytes = file.bytes;
  if (bytes == null) {
    throw StateError('File bytes are unavailable on web. Use withData: true.');
  }

  final blob = html.Blob([bytes], _detectMimeType(file));
  final url = html.Url.createObjectUrlFromBlob(blob);

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
