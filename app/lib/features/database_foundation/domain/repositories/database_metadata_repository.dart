import '../entities/database_backup_metadata.dart';

abstract interface class DatabaseMetadataRepository {
  Future<DatabaseBackupMetadata> createBackupMetadata();
}
