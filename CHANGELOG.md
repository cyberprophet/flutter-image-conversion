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
