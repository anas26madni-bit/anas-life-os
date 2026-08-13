import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final appRoot = Directory.current.path.endsWith('${Platform.pathSeparator}app')
      ? Directory.current
      : Directory('app');

  String read(String relativePath) =>
      File('${appRoot.path}${Platform.pathSeparator}$relativePath')
          .readAsStringSync();

  test('Version 1 release identity and hardened candidate build are fixed', () {
    final pubspec = read('pubspec.yaml');
    final gradle = read('android/app/build.gradle.kts');

    expect(pubspec, contains('version: 1.0.0+12'));
    expect(gradle, contains('signingConfig = signingConfigs.getByName("debug")'));
    expect(gradle, contains('isMinifyEnabled = true'));
    expect(gradle, contains('isShrinkResources = true'));
    expect(gradle, contains('proguard-android-optimize.txt'));
  });

  test('release manifest retains offline and privacy boundaries', () {
    final manifest = read('android/app/src/main/AndroidManifest.xml');

    expect(manifest, isNot(contains('android.permission.INTERNET')));
    expect(manifest, isNot(contains('android.permission.ACCESS_FINE_LOCATION')));
    expect(manifest, isNot(contains('android:usesCleartextTraffic="true"')));
    expect(manifest, contains('android:allowBackup="false"'));
  });

  test('Future Release packages and routes remain absent', () {
    final pubspec = read('pubspec.yaml');
    final router = read('lib/core/router/app_router.dart');

    for (final forbidden in <String>[
      'firebase_',
      'http:',
      'dio:',
      'wear:',
      'cloud_',
    ]) {
      expect(pubspec, isNot(contains(forbidden)));
    }
    for (final forbidden in <String>[
      '/ai',
      '/plugins',
      '/cloud',
      '/wear',
    ]) {
      expect(router, isNot(contains(forbidden)));
    }
  });
}
