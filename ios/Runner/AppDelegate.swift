import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var pendingFile: String?
  private var fileHandlerChannel: FlutterMethodChannel?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Check if app was launched with a file
    if let url = launchOptions?[.url] as? URL {
      pendingFile = url.path
    }
    
    // Set up method channel for file handling
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    fileHandlerChannel = FlutterMethodChannel(
      name: "com.yahrtzeit.manager/file_handler",
      binaryMessenger: controller.binaryMessenger
    )
    
    fileHandlerChannel?.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getInitialFile" || call.method == "getFileFromIntent" {
        let file = self.pendingFile
        self.pendingFile = nil // Clear after access
        result(file)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    // Handle file opening when app is already running
    pendingFile = url.path
    
    // Notify Flutter if channel is ready
    fileHandlerChannel?.invokeMethod("handleFile", arguments: url.path)
    
    return true
  }
}
