
import 'package:flutter/services.dart';

/// A Flutter plugin to check for security alerts
class SecurityPlus {
  static const MethodChannel _channel = MethodChannel('security_plus');

  /// Android Root checks
  /// this gets the value from native channel to flutter to know if phone is rooted
  static Future<bool> get isRooted async {
    final bool isRooted = await _channel.invokeMethod('isRooted');
    return isRooted;
  }

  /// iOS JailBroken checks
  /// this gets the value from native channel to flutter to know if phone is jail broken
  static Future<bool> get isJailBroken async {
    final bool isJailBroken = await _channel.invokeMethod('isJailBroken');
    return isJailBroken;
  }

  /// Android Emulator checks
  /// this gets the value from native channel to flutter to know if app is running on an Emulator
  static Future<bool> get isEmulator async {
    final bool isRooted = await _channel.invokeMethod('isEmulator');
    return isRooted;
  }

  /// Android on External Storage check
  /// this gets the value from native channel to flutter to know if app is running on an external storage
  static Future<bool> get isOnExternalStorage async {
    final bool isRooted = await _channel.invokeMethod('isOnExternalStorage');
    return isRooted;
  }

  /// Android Development mode check
  /// this gets the value from native channel to flutter to know if app is running in development environment
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
