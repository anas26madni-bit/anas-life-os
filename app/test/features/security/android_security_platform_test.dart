import 'package:anas_life_os/features/security/data/services/android_security_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/security');
  const platform = AndroidSecurityPlatform(channel: channel);
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'status') {
            return <String, Object>{
              'hasPin': true,
              'biometricAvailable': true,
              'failedAttempts': 5,
              'cooldownSeconds': 30,
            };
          }
          if (call.method == 'setSecureWindow') return null;
          return <String, Object>{
            'success': true,
            'failedAttempts': 0,
            'cooldownSeconds': 0,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('maps PIN, biometric, cooldown and secure-window operations', () async {
    final status = await platform.status();
    expect(status.hasPin, isTrue);
    expect(status.cooldownSeconds, 30);
    expect((await platform.configurePin('123456')).success, isTrue);
    expect((await platform.changePin('123456', '654321')).success, isTrue);
    expect((await platform.verifyPin('654321')).success, isTrue);
    expect(
      (await platform.authenticateBiometric(
        title: 'title',
        subtitle: 'subtitle',
        cancelLabel: 'cancel',
      )).success,
      isTrue,
    );
    expect((await platform.disablePin('654321')).success, isTrue);
    await platform.setSecureWindow(true);

    expect(
      calls.map((call) => call.method),
      containsAll(<String>[
        'status',
        'configurePin',
        'changePin',
        'verifyPin',
        'authenticateBiometric',
        'disablePin',
        'setSecureWindow',
      ]),
    );
    expect(calls.last.arguments, isTrue);
  });
}
