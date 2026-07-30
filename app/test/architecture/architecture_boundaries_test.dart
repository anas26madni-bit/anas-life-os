import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('presentation does not import SQLite or Drift', () {
    final violations = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) {
        continue;
      }
      final normalized = file.path.replaceAll(r'\', '/');
      if (!normalized.contains('/presentation/') &&
          !normalized.contains('/startup/')) {
        continue;
      }
      final content = file.readAsStringSync();
      if (content.contains('package:drift/') ||
          content.contains('package:sqlite3/')) {
        violations.add(normalized);
      }
    }

    expect(violations, isEmpty);
  });

  test('Sprint 2 contains only database foundation feature source', () {
    final featureFiles = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.path.replaceAll(r'\', '/'));

    expect(
      featureFiles,
      everyElement(contains('/features/database_foundation/')),
    );
  });

  test('database foundation domain is independent from data and Flutter', () {
    final violations = <String>[];
    final domain = Directory('lib/features/database_foundation/domain');
    for (final file in domain.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) {
        continue;
      }
      final content = file.readAsStringSync();
      if (content.contains('/data/') ||
          content.contains('package:drift/') ||
          content.contains('package:flutter/')) {
        violations.add(file.path.replaceAll(r'\', '/'));
      }
    }

    expect(violations, isEmpty);
  });
}
