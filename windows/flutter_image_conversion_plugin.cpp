#include "flutter_image_conversion_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <iostream>
#include <memory>
#include <string>

#include "include/flutter_image_conversion/flutter_image_conversion_plugin_c_api.h"

namespace flutter_image_conversion {

void FlutterImageConversionPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_image_conversion",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<FlutterImageConversionPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterImageConversionPlugin::FlutterImageConversionPlugin() {}

FlutterImageConversionPlugin::~FlutterImageConversionPlugin() {}

void FlutterImageConversionPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    result->Success(flutter::EncodableValue("Windows"));
  } else if (method_call.method_name().compare("convertHeicToJpeg") == 0) {
    std::cout << "[FlutterImageConversion] HEIC conversion not supported on Windows" << std::endl;
    result->Success(flutter::EncodableValue());
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_image_conversion

void FlutterImageConversionPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_image_conversion::FlutterImageConversionPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
