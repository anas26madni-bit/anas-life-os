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

  test('Sprint 1 contains no product feature source', () {
    final dartFiles = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    expect(dartFiles, isEmpty);
  });
}
