import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_plus/security_plus.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([MethodChannel])
void main() {
  const MethodChannel channel = MethodChannel('security_plus');
  late Map<String, dynamic> mockResponses;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockResponses = {
      'isJailBroken': false,
      'isRooted': false,
      'isDevelopmentModeEnable': false,
      'isEmulator': false,
      'isMockLocationEnabled': false,
      'isOnExternalStorage': false,
    };

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return mockResponses[methodCall.method] ?? false;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Root Detection Tests', () {
    test('isRooted should return false for secure device', () async {
      mockResponses['isRooted'] = false;
      expect(await SecurityPlus.isRooted, false);
    });

    test('isRooted should return true for rooted device', () async {
      mockResponses['isRooted'] = true;
      expect(await SecurityPlus.isRooted, true);
    });

    test('isRooted should handle exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isRooted') {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        }
        return false;
      });

      expect(() => SecurityPlus.isRooted, throwsA(isA<PlatformException>()));
    });
  });

  group('Jailbreak Detection Tests', () {
    test('isJailBroken should return false for secure device', () async {
      mockResponses['isJailBroken'] = false;
      expect(await SecurityPlus.isJailBroken, false);
    });

    test('isJailBroken should return true for jailbroken device', () async {
      mockResponses['isJailBroken'] = true;
      expect(await SecurityPlus.isJailBroken, true);
    });

    test('isJailBroken should handle exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isJailBroken') {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        }
        return false;
      });

      expect(() => SecurityPlus.isJailBroken, throwsA(isA<PlatformException>()));
    });
  });

  group('Development Mode Tests', () {
    test('isDevelopmentModeEnable should return false for production mode', () async {
      mockResponses['isDevelopmentModeEnable'] = false;
      expect(await SecurityPlus.isDevelopmentModeEnable, false);
    });

    test('isDevelopmentModeEnable should return true for development mode', () async {
      mockResponses['isDevelopmentModeEnable'] = true;
      expect(await SecurityPlus.isDevelopmentModeEnable, true);
    });

    test('isDevelopmentModeEnable should handle exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isDevelopmentModeEnable') {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        }
        return false;
      });

      expect(() => SecurityPlus.isDevelopmentModeEnable, throwsA(isA<PlatformException>()));
    });
  });

  group('Emulator Detection Tests', () {
    test('isEmulator should return false for physical device', () async {
      mockResponses['isEmulator'] = false;
      expect(await SecurityPlus.isEmulator, false);
    });

    test('isEmulator should return true for emulator', () async {
      mockResponses['isEmulator'] = true;
      expect(await SecurityPlus.isEmulator, true);
    });

    test('isEmulator should handle exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isEmulator') {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        }
        return false;
      });

      expect(() => SecurityPlus.isEmulator, throwsA(isA<PlatformException>()));
    });
  });

  group('Mock Location Tests', () {
    test('isMockLocationEnabled should return false when disabled', () async {
      mockResponses['isMockLocationEnabled'] = false;
      expect(await SecurityPlus.isMockLocationEnabled, false);
    });

    test('isMockLocationEnabled should return true when enabled', () async {
      mockResponses['isMockLocationEnabled'] = true;
      expect(await SecurityPlus.isMockLocationEnabled, true);
    });

    test('isMockLocationEnabled should handle exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isMockLocationEnabled') {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        }
        return false;
      });

      expect(() => SecurityPlus.isMockLocationEnabled, throwsA(isA<PlatformException>()));
    });
  });

  group('External Storage Tests', () {
    test('isOnExternalStorage should return false for internal storage', () async {
      mockResponses['isOnExternalStorage'] = false;
      expect(await SecurityPlus.isOnExternalStorage, false);
    });

    test('isOnExternalStorage should return true for external storage', () async {
      mockResponses['isOnExternalStorage'] = true;
      expect(await SecurityPlus.isOnExternalStorage, true);
    });

    test('isOnExternalStorage should handle exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isOnExternalStorage') {
          throw PlatformException(code: 'ERROR', message: 'Test error');
        }
        return false;
      });

      expect(() => SecurityPlus.isOnExternalStorage, throwsA(isA<PlatformException>()));
    });
  });

  group('Multiple Security Checks', () {
    test('should handle multiple security checks in sequence', () async {
      mockResponses['isRooted'] = true;
      mockResponses['isEmulator'] = true;
      mockResponses['isMockLocationEnabled'] = true;

      expect(await SecurityPlus.isRooted, true);
      expect(await SecurityPlus.isEmulator, true);
      expect(await SecurityPlus.isMockLocationEnabled, true);
    });

    test('should handle mixed security states', () async {
      mockResponses['isRooted'] = false;
      mockResponses['isEmulator'] = true;
      mockResponses['isMockLocationEnabled'] = false;

      expect(await SecurityPlus.isRooted, false);
      expect(await SecurityPlus.isEmulator, true);
      expect(await SecurityPlus.isMockLocationEnabled, false);
    });
  });
}
