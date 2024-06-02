import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Impedir captura de tela
    if let flutterViewController = window?.rootViewController as? FlutterViewController {
      flutterViewController.view.isSecure = true
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}