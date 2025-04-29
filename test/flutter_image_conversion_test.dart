import 'dart:io';

import 'package:flutter_image_conversion/flutter_image_conversion.dart';
import 'package:flutter_image_conversion/flutter_image_conversion_method_channel.dart';
import 'package:flutter_image_conversion/flutter_image_conversion_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterImageConversionPlatform
    with MockPlatformInterfaceMixin
    implements FlutterImageConversionPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<File> convertHeicToJpeg(File file) => Future.value(File('path'));
}

void main() {
  final FlutterImageConversionPlatform initialPlatform =
      FlutterImageConversionPlatform.instance;

  test('$MethodChannelFlutterImageConversion is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelFlutterImageConversion>());
  });

  test('getPlatformVersion', () async {
    FlutterImageConversion flutterImageConversionPlugin =
        FlutterImageConversion();
    MockFlutterImageConversionPlatform fakePlatform =
        MockFlutterImageConversionPlatform();
    FlutterImageConversionPlatform.instance = fakePlatform;

    expect(await flutterImageConversionPlugin.getPlatformVersion(), '42');
  });
}
