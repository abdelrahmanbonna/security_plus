
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
}
