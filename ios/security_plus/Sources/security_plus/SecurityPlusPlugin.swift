import Flutter
import UIKit

public class SecurityPlusPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "security_plus", binaryMessenger: registrar.messenger())
    let instance = SecurityPlusPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isJailBroken":
        result(isJailBroken())
    case "isEmulator":
        result(isEmulator())
    default:
        // Always reply so the Dart Future completes (throws MissingPluginException).
        result(FlutterMethodNotImplemented)
    }
  }

    /// Returns true when the app is running in the iOS Simulator.
    /// Simulator builds are compiled against the simulator SDK, so this
    /// compile-time check is exact and uses no private API.
    func isEmulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    func isJailBroken() -> Bool {
        return openURL() || written()
    }

   fileprivate func openURL() -> Bool {
        if let url = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
    return false
    }

   fileprivate func written() -> Bool {
        var erro: Error? = nil
        let stringToBeWritten = "This is a JB test."
        do {
            try stringToBeWritten.write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)
        } catch {
            erro = error
        }
        if erro == nil {
            return true
        } else {
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: "/private/jailbreak.txt")
            } catch {
            }
        }
        return false
    }
}
