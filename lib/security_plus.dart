
import 'package:flutter/services.dart';

class SecurityPlus {
  static const MethodChannel _channel = MethodChannel('security_plus');

  // Android Root checks
  static Future<bool> get isRooted async {
    final bool isRooted = await _channel.invokeMethod('isRooted');
    return isRooted;
  }

  // iOS JailBroken checks
  static Future<bool> get isJailBroken async {
    final bool isJailBroken = await _channel.invokeMethod('isJailBroken');
    return isJailBroken;
  }

  // Android Emulator checks
  static Future<bool> get isEmulator async {
    final bool isRooted = await _channel.invokeMethod('isEmulator');
    return isRooted;
  }

  // Android on External Storage checks
  static Future<bool> get isOnExternalStorage async {
    final bool isRooted = await _channel.invokeMethod('isOnExternalStorage');
    return isRooted;
  }

  // Android Development mode checks
  static Future<bool> get isDevelopmentModeEnable async {
    final bool isRooted = await _channel.invokeMethod('isDevelopmentModeEnable');
    return isRooted;
  }

  // Android Mocked Location checks
  // static Future<bool> get isMockedLocation async {
  //   final bool isRooted = await _channel.invokeMethod('isMockedLocation');
  //   return isRooted;
  // }
}
