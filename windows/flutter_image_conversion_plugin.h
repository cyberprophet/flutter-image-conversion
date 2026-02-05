#ifndef FLUTTER_PLUGIN_FLUTTER_IMAGE_CONVERSION_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_IMAGE_CONVERSION_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_image_conversion {

class FlutterImageConversionPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterImageConversionPlugin();
  virtual ~FlutterImageConversionPlugin();

  FlutterImageConversionPlugin(const FlutterImageConversionPlugin&) = delete;
  FlutterImageConversionPlugin& operator=(const FlutterImageConversionPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_image_conversion

#endif  // FLUTTER_PLUGIN_FLUTTER_IMAGE_CONVERSION_PLUGIN_H_
