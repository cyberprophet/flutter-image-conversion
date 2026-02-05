import Cocoa
import FlutterMacOS

public class FlutterImageConversionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_image_conversion", binaryMessenger: registrar.messenger)
    let instance = FlutterImageConversionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)

    case "convertHeicToJpeg":
      guard
        let args = call.arguments as? [String: Any],
        let path = args["path"] as? String
      else {
        result(nil)
        return
      }

      let url = URL(fileURLWithPath: path)

      guard let image = NSImage(contentsOf: url),
            let resizedImage = resizeImageIfNeeded(image: image, maxWidth: 1080),
            let jpegData = resizedImage.jpegData(compressionQuality: 0.7)
      else {
        result(FlutterError(code: "IMAGE_PROCESSING_FAILED", message: "Failed to process image", details: nil))

        return
      }

      let tempDir = NSTemporaryDirectory()
      let outputPath = "\(tempDir)converted_\(UUID().uuidString).jpg"
      let outputURL = URL(fileURLWithPath: outputPath)

      do {
        try jpegData.write(to: outputURL)

        result(outputPath)
      } catch {
        result(nil)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func resizeImageIfNeeded(image: NSImage, maxWidth: CGFloat) -> NSImage? {
    let size = image.size

    guard size.width > maxWidth else { return image }

    let scale = maxWidth / size.width
    let newSize = CGSize(width: size.width * scale, height: size.height * scale)

    let resizedImage = NSImage(size: newSize)
    resizedImage.lockFocus()
    image.draw(in: NSRect(origin: .zero, size: newSize))
    resizedImage.unlockFocus()

    return resizedImage
  }
}

extension NSImage {
  func jpegData(compressionQuality: CGFloat) -> Data? {
    guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
      return nil
    }
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
  }
}
