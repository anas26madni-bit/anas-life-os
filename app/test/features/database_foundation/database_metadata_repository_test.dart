import 'package:anas_life_os/core/database/database_constants.dart';
import 'package:anas_life_os/features/database_foundation/data/repositories/drift_database_metadata_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('creates backup-ready metadata without reading user data', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final generatedAt = DateTime.utc(2026, 7, 30);
    final repository = DriftDatabaseMetadataRepository(
      database,
      clock: () => generatedAt,
    );

    final metadata = await repository.createBackupMetadata();

    expect(metadata.databaseName, DatabaseConstants.name);
    expect(metadata.schemaVersion, DatabaseConstants.schemaVersion);
    expect(metadata.engineVersion, isNotEmpty);
    expect(metadata.cipherVersion, isNotEmpty);
    expect(metadata.generatedAt, generatedAt);
  });
}
