import Flutter
import UIKit

public class SecurityPlusPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "security_plus", binaryMessenger: registrar.messenger())
    let instance = SecurityPlusPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "isJailBroken" {
        result(isJailBroken())
    }
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
