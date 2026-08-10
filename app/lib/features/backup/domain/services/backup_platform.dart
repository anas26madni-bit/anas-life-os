import '../entities/backup_models.dart';

abstract interface class BackupPlatform {
  Future<String?> selectDestination();
  Future<String?> selectImport();

  Future<BackupArchiveResult> createArchive({
    required String databaseSnapshotPath,
    required List<String> managedFilePaths,
    required String destinationUri,
    required String passphrase,
    required String backupName,
  });

  Future<RestoreArchiveResult> restoreArchive({
    required String sourceUri,
    required String passphrase,
  });

  Future<void> configureAutomatic({
    required BackupSettings settings,
    required String passphrase,
  });

  Future<void> disableAutomatic();
}
