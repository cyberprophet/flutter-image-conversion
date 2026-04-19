## 2.2.1

**Patch Release: Fix Windows Build Failure**

### Bug Fixes
- Fixed `flutter build windows` failure in downstream projects depending on `flutter_image_conversion`
  - Windows plugin is implemented with the C API pattern (exposes `FlutterImageConversionPluginCApiRegisterWithRegistrar` via `include/flutter_image_conversion/flutter_image_conversion_plugin_c_api.h`), but `pubspec.yaml` declared `pluginClass: FlutterImageConversionPlugin`, causing Flutter's tool to generate `generated_plugin_registrant.cc` that referenced a non-existent header and an undefined register function.
  - Changed Windows `pluginClass` from `FlutterImageConversionPlugin` to `FlutterImageConversionPluginCApi` so the generated registrant correctly includes `flutter_image_conversion_plugin_c_api.h` and calls `FlutterImageConversionPluginCApiRegisterWithRegistrar`.

### Notes
- No source code changes; `pubspec.yaml` manifest fix only.
- Fixes #6.

---

## 2.2.0

**Feature: WASM Compatibility**

### Breaking Changes (Web internals only)
- Migrated Web implementation from `dart:html` to `package:web` + `dart:js_interop`
- Now fully compatible with `flutter build web --wasm`

### Changes
- Replaced `dart:html` imports with `package:web/web.dart`
- Replaced `html.Blob`, `html.Url`, `html.FileReader` with `web.Blob`, `web.URL`, `web.Response` APIs
- Simplified blob-to-bytes conversion using `Response.arrayBuffer()` instead of `FileReader`
- Added `web: ^1.1.1` dependency

### Notes
- No public API changes — existing code works without modification
- All 11 tests passing

---

## 2.1.2

**Patch Release: Fix Web Bytes Conversion Bug**

### Bug Fixes
- 🐛 Fixed `convertHeicToJpegBytes()` on Web platform
  - Corrected FileReader.result type handling (ByteBuffer → Uint8List)
  - Added MIME type to Blob constructor for better heic2any compatibility
  - Fixed HEIC file detection using proper ISO-BMFF ftyp box parsing
  - Improved error handling with FileReader.onLoadEnd

### Example App
- ✨ Added test button for `convertHeicToJpegBytes()` method
  - Displays converted bytes size and hex preview
  - Helps verify Web platform functionality

### Technical Details
- Fixed bug where `reader.result as List<int>` failed (should be `ByteBuffer`)
- Changed Blob creation from `Blob([bytes])` to `Blob(<Object>[bytes], 'image/heic')`
- Replaced broken magic bytes check with proper ISO Base Media File Format parsing
- Now checks ftyp box at correct offset (4) and validates HEIF brand codes

---

## 2.1.1

**Patch Release: Fix pub.dev Deployment**

### Changes
- 🔧 Fixed GitHub Actions workflow for pub.dev deployment
  - Added OIDC authentication setup
  - Updated tag pattern for more specific matching
  - Improved workflow configuration

### Notes
- No code changes - deployment infrastructure update only
- Same functionality as v2.1.0

---

## 2.1.0

**New Feature: Uint8List-Based Conversion Method**

### New Features
- ✅ **convertHeicToJpegBytes()**: New method for direct Uint8List conversion
  - Accepts `Uint8List` input instead of `File`
  - Returns `Uint8List` output instead of `File`
  - Improved Web platform support (avoids File/blob URL handling issues)
  - Available on iOS, macOS, and Web platforms
  - Android and Windows return original bytes unchanged

### Improvements
- Better support for in-memory image processing workflows
- Reduced file I/O overhead for Web platform
- Cleaner API for applications that work with byte arrays

### Backward Compatibility
- ✅ Existing `convertHeicToJpeg(File)` method unchanged
- ✅ All existing code continues to work without modifications
- ✅ No breaking changes

---

## 2.0.0

**Major Update: Multi-Platform Support**

### New Features
- ✅ **macOS Support**: Full HEIC to JPEG conversion using NSImage
  - Resize to max 1080px width (maintains aspect ratio)
  - JPEG compression quality 0.7
  - Output to temp directory
- ✅ **Web Support**: HEIC to JPEG conversion using heic2any JavaScript library
  - Browser-based conversion via WASM
  - Returns blob URL for converted images
  - Graceful fallback on conversion failure
- ✅ **Windows Support**: Stub implementation with graceful fallback
  - Logs warning message
  - Returns original file unchanged

### Platform Support Matrix
| Platform | Status | Conversion |
|----------|--------|------------|
| iOS | ✅ Full Support | HEIC → JPEG |
| macOS | ✅ Full Support | HEIC → JPEG |
| Web | ✅ Full Support | HEIC → JPEG |
| Android | ⚠️ Stub | Returns original |
| Windows | ⚠️ Stub | Returns original |

### Test Coverage
- Added comprehensive unit tests for web platform (8 new tests)
- Updated integration tests for all platforms
- All 11 tests passing

### Breaking Changes
- None (backward compatible)

### Dependencies
- Updated SDK constraint to `^3.8.1` (Dart 3.8.1)
- Updated Flutter constraint to `>=3.32.0`
- Updated `plugin_platform_interface` to `^2.1.8`
- Updated `flutter_lints` to `^5.0.0`
- Added `flutter_web_plugins` dependency

---

## 1.0.0

**Initial Release**

- Initial release of `flutter_image_conversion`.
- Supports converting HEIC images to JPEG on **iOS** using native Swift code.
- Provides image resizing and adjustable compression quality before conversion.
- Designed for use in social media apps, web uploads, and other cross-platform image workflows.
- Android platform is stubbed with log output indicating that HEIC is not supported.
