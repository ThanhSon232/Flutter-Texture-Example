import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var registry: FlutterTextureRegistry?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      if let controller : FlutterViewController? = window?.rootViewController as? FlutterViewController? {
          registry = controller!.engine?.textureRegistry
          let channel = FlutterMethodChannel(name: "flutter_example_texture", binaryMessenger: controller!.binaryMessenger)
          channel.setMethodCallHandler{(call: FlutterMethodCall, result: @escaping FlutterResult) in
              if call.method == "createTexture"{
                  var texture = SimpleFlutterTexture(color: UIColor.red, width: 400, height: 400)
                  var textureId = self.registry?.register(texture)
                  result(textureId)
              } else {
                  result(FlutterMethodNotImplemented)
              }
          }
      }
      

      
      
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class SimpleFlutterTexture: NSObject, FlutterTexture {
    private var pixelBuffer: CVPixelBuffer?
    
    init(color: UIColor, width: Int, height: Int) {
        super.init()
        self.pixelBuffer = SimpleFlutterTexture.createPixelBuffer(color: color, width: width, height: height)
    }
    
    static func createPixelBuffer(color: UIColor, width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA, // Định dạng pixel
            options as CFDictionary,
            &pixelBuffer
        )
        
        guard let buffer = pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        )
    
        if let context = context {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
            context.flush()
        }
        
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        return buffer
    }
    
    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        guard let pixelBuffer = pixelBuffer else {
            return nil
        }
        return Unmanaged<CVPixelBuffer>.passRetained(pixelBuffer)
    }
}
