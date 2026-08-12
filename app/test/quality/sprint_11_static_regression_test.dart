import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'production code has no polling, unmanaged wake locks, or hardcoded UI colors',
    () {
      final violations = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (!entity.path.replaceAll(r'\', '/').contains('/presentation/')) {
          continue;
        }
        final source = entity.readAsStringSync();
        if (source.contains('Timer.periodic(') ||
            source.contains('WakeLock') ||
            RegExp(r'Colors\.(red|green|blue|black|white)').hasMatch(source)) {
          violations.add(entity.path);
        }
      }
      expect(violations, isEmpty);
    },
  );

  test(
    'Android background work is constrained and declares no location access',
    () {
      final kotlin = Directory('android/app/src/main/kotlin')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.kt'))
          .map((file) => file.readAsStringSync())
          .join('\n');
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(kotlin, isNot(contains('PowerManager.WakeLock')));
      expect(kotlin, contains('setRequiresBatteryNotLow(true)'));
      expect(kotlin, contains('setRequiresStorageNotLow(true)'));
      expect(manifest, isNot(contains('ACCESS_FINE_LOCATION')));
      expect(manifest, isNot(contains('ACCESS_COARSE_LOCATION')));
    },
  );
}
