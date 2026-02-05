import 'dart:io';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_image_conversion_method_channel.dart';

abstract class FlutterImageConversionPlatform extends PlatformInterface {
  /// Constructs a FlutterImageConversionPlatform.
  FlutterImageConversionPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterImageConversionPlatform _instance =
      MethodChannelFlutterImageConversion();

  /// The default instance of [FlutterImageConversionPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterImageConversion].
  static FlutterImageConversionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterImageConversionPlatform] when
  /// they register themselves.
  static set instance(FlutterImageConversionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<File> convertHeicToJpeg(File file);

  Future<Uint8List> convertHeicToJpegBytes(Uint8List bytes);
}
