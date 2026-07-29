import 'package:anas_life_os/core/database/database_foundation_status.dart';
import 'package:anas_life_os/core/database/database_initializer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  test('verifies SQLCipher, foreign keys, and SQLite integrity', () async {
    final logger = FakeAppLogger();
    final initializer = DatabaseInitializer(logger);

    final report = await initializer.verifyFoundation();

    expect(report.status, DatabaseFoundationStatus.ready);
    expect(report.engineVersion, isNotEmpty);
    expect(report.cipherVersion, isNotEmpty);
    expect(logger.messages, contains('Database foundation verified'));
  });
}
