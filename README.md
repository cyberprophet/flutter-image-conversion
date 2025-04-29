# flutter_image_conversion

A Flutter plugin that converts HEIC images to JPEG (or optionally PNG) on iOS using native Swift code.
Useful for preparing images for web uploads, social sharing, or ensuring cross-platform compatibility.

## Features

- ✅ Convert `.heic` files to `.jpeg`
- ✅ Resize images before conversion (default max width: 1080)
- ✅ Set compression quality (default: 0.7)
- ❌ HEIC is not supported on Android — Android will return `File` and log the attempt

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_image_conversion:
    git:
      url: https://github.com/cyberprophet/flutter-image-conversion.git
```

```dart
import 'package:flutter_image_conversion/flutter_image_conversion.dart';

// maxWidth to 1080px
// quality to 70%
Future<void> convertImage(File heicImage) async {
  final File file =
    await FlutterImageConversion.convertHeicToJpeg(heicImage);
}
```
