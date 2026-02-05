import 'dart:io';

import 'package:file_picker/file_picker.dart';

Future<File> createFile(PlatformFile file) async {
  final path = file.path;
  if (path == null) {
    throw StateError('File path is unavailable on this platform.');
  }

  return File(path);
}
