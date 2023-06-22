import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security_plus/security_plus.dart';

void main() {
  const MethodChannel channel = MethodChannel('security_plus');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isJailBroken', () async {
    expect(await SecurityPlus.isJailBroken, '42');
  });
}
