# flutter_image_conversion

A Flutter plugin that converts HEIC images to JPEG format across multiple platforms.
Supports iOS, macOS, and Web with full conversion, plus Android and Windows with graceful fallback.

## Platform Support

| Platform | Status | Implementation | Conversion | Notes |
|----------|--------|----------------|------------|-------|
| **iOS** | ✅ Full | Swift (UIImage) | HEIC → JPEG | Resize + compression |
| **macOS** | ✅ Full | Swift (NSImage) | HEIC → JPEG | Resize + compression |
| **Web** | ✅ Full | Dart + JS (heic2any) | HEIC → JPEG | Browser-based WASM |
| **Android** | ⚠️ Stub | Kotlin | Returns original | Logs warning |
| **Windows** | ⚠️ Stub | C++ | Returns original | Logs warning |

## Features

- ✅ Convert `.heic` and `.heif` files to `.jpeg`
- ✅ Resize images before conversion (default max width: 1080px)
- ✅ Adjustable compression quality (default: 0.7)
- ✅ Multi-platform support (iOS, macOS, Web, Android, Windows)
- ✅ Graceful fallback on unsupported platforms
- ✅ Comprehensive test coverage

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_image_conversion:
    git:
      url: https://github.com/cyberprophet/flutter-image-conversion.git
```

Or from pub.dev (once published):

```yaml
dependencies:
  flutter_image_conversion: ^2.0.0
```

## Usage

### Basic Usage

```dart
import 'package:flutter_image_conversion/flutter_image_conversion.dart';
import 'dart:io';

final converter = FlutterImageConversion();

// Convert HEIC to JPEG
File heicFile = File('/path/to/image.heic');
File jpegFile = await converter.convertHeicToJpeg(heicFile);

// Use the converted file
print('Converted file: ${jpegFile.path}');
```

### Platform-Specific Behavior

```dart
// iOS/macOS: Returns converted JPEG file in temp directory
// Example: /tmp/converted_abc123.jpg

// Web: Returns File with blob URL
// Example: blob:http://localhost/converted-jpeg

// Android/Windows: Returns original file unchanged
// Logs warning: "HEIC conversion not supported on [Platform]"
```

### Get Platform Version

```dart
String? version = await converter.getPlatformVersion();
print('Platform: $version');
// iOS: "iOS 17.0"
// macOS: "macOS 14.0"
// Web: "Web"
// Android: "Android 14"
// Windows: "Windows"
```

## Platform Implementation Details

### iOS & macOS
- **Technology**: Swift with native ImageIO framework
- **Processing**:
  1. Load HEIC image using UIImage (iOS) or NSImage (macOS)
  2. Resize if width > 1080px (maintains aspect ratio)
  3. Convert to JPEG with 0.7 compression quality
  4. Save to temp directory as `converted_<UUID>.jpg`
- **Requirements**: iOS 12.0+, macOS 10.14+

### Web
- **Technology**: Dart + JavaScript interop with heic2any library
- **Processing**:
  1. Fetch image blob from URL
  2. Convert using heic2any (WASM-based)
  3. Create object URL for converted blob
  4. Return File with blob URL
- **Browser Support**: All modern browsers with WASM support
- **Fallback**: Returns original file if conversion fails

### Android & Windows
- **Technology**: Kotlin (Android), C++ (Windows)
- **Behavior**: 
  - Logs warning message
  - Returns original file unchanged
- **Reason**: HEIC is Apple-proprietary format, not natively supported

## Requirements

- **Dart**: ^3.8.1
- **Flutter**: >=3.32.0
- **iOS**: 12.0+
- **macOS**: 10.14+
- **Android**: SDK 21+ (Android 5.0+)
- **Web**: Modern browser with WASM support
- **Windows**: Windows 10+

## Example App

See the [example](example/) directory for a complete working application that demonstrates:
- Image selection from device gallery
- HEIC to JPEG conversion
- Display of converted images
- Platform-specific behavior

Run the example:

```bash
cd example
flutter run
```

## Testing

The package includes comprehensive test coverage:

```bash
# Run unit tests
flutter test

# Run integration tests
cd example
flutter test integration_test/
```

**Test Results**: ✅ 11/11 tests passing

## API Reference

### FlutterImageConversion

Main plugin class for image conversion.

#### Methods

##### `getPlatformVersion()`

Returns the platform version string.

```dart
Future<String?> getPlatformVersion()
```

**Returns**: Platform-specific version string (e.g., "iOS 17.0", "Web")

##### `convertHeicToJpeg(File file)`

Converts a HEIC image file to JPEG format.

```dart
Future<File> convertHeicToJpeg(File file)
```

**Parameters**:
- `file`: Input HEIC file to convert

**Returns**: 
- iOS/macOS/Web: Converted JPEG file
- Android/Windows: Original file unchanged

**Processing Details**:
- Max width: 1080px (auto-resize if larger)
- Aspect ratio: Maintained
- Compression quality: 0.7 (70%)
- Output format: JPEG
- Output location: Temporary directory (iOS/macOS), blob URL (Web)

## Technical Architecture

### Plugin Structure

```
flutter_image_conversion/
├── lib/
│   ├── flutter_image_conversion.dart           # Public API
│   ├── flutter_image_conversion_platform_interface.dart  # Platform interface
│   ├── flutter_image_conversion_method_channel.dart      # Method channel
│   └── flutter_image_conversion_web.dart       # Web implementation
├── ios/                                        # iOS native code
├── macos/                                      # macOS native code
├── android/                                    # Android native code
├── windows/                                    # Windows native code
├── web/                                        # Web assets
└── test/                                       # Unit tests
```

### Communication Flow

```
┌─────────────────────────────────────┐
│  Dart Layer (Public API)           │
│  FlutterImageConversion             │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│  Platform Interface                 │
│  FlutterImageConversionPlatform     │
└─────────────────┬───────────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
┌───────▼────────┐  ┌──────▼──────┐
│ Method Channel │  │ Web Direct  │
│ (iOS/Android)  │  │ (Dart+JS)   │
│ (macOS/Windows)│  │             │
└───────┬────────┘  └──────┬──────┘
        │                   │
┌───────▼────────┐  ┌──────▼──────┐
│ Native Code    │  │ heic2any.js │
│ Swift/Kotlin/  │  │ (WASM)      │
│ C++            │  │             │
└────────────────┘  └─────────────┘
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

## Support

For issues, questions, or suggestions, please file an issue on the [GitHub repository](https://github.com/cyberprophet/flutter-image-conversion/issues).
