import '../../../../core/database/database_constants.dart';
import '../../domain/entities/database_backup_metadata.dart';
import '../../domain/repositories/database_metadata_repository.dart';
import '../database/app_database.dart';

final class DriftDatabaseMetadataRepository
    implements DatabaseMetadataRepository {
  const DriftDatabaseMetadataRepository(
    this._database, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<DatabaseBackupMetadata> createBackupMetadata() async {
    final engine = await _database
        .customSelect('SELECT sqlite_version() AS version;')
        .getSingle();
    final cipher = await _database
        .customSelect('PRAGMA cipher_version;')
        .getSingle();
    final schema = await _database
        .customSelect('PRAGMA user_version;')
        .getSingle();
    return DatabaseBackupMetadata(
      databaseName: DatabaseConstants.name,
      schemaVersion: schema.read<int>('user_version'),
      engineVersion: engine.read<String>('version'),
      cipherVersion: cipher.read<String>('cipher_version'),
      generatedAt: _clock().toUtc(),
    );
  }
}
