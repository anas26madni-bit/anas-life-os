import 'dart:typed_data';

import 'package:anas_life_os/core/database/android_database_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.anaslifeos.app/database');
  const platform = AndroidDatabasePlatform(channel: channel);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('retrieves a persistent 256-bit database key', () async {
    final expected = Uint8List.fromList(List<int>.generate(32, (index) => index));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'loadOrCreateDatabaseKey');
          return expected;
        });

    final key = await platform.loadOrCreate();

    expect(key.hexadecimal, expected.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join());
  });

  test('fails closed when Android returns no key', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);

    expect(platform.loadOrCreate, throwsA(isA<PlatformException>()));
  });

  test('uses the Android no-backup database directory', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'databaseDirectory');
          return '/private/no_backup';
        });

    expect((await platform.databaseDirectory()).path, '/private/no_backup');
  });
}
