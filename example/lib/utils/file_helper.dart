import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'file_helper_io.dart' if (dart.library.html) 'file_helper_web.dart';

Future<File> fileFromPlatform(PlatformFile file) {
  return createFile(file);
}
