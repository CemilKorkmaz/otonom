import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.otonom.app/dynamic_icon",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        guard call.method == "setAlternateIcon",
              let args = call.arguments as? [String: Any],
              let iconKey = args["iconKey"] as? String else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard UIApplication.shared.supportsAlternateIcons else {
          result(false)
          return
        }
        UIApplication.shared.setAlternateIconName(iconKey) { error in
          result(error == nil)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
