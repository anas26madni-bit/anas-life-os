import '../../../../core/errors/result.dart';
import '../entities/backup_models.dart';

abstract interface class BackupRepository {
  Future<BackupSettings> loadSettings();
  Future<List<BackupRecord>> loadHistory();
  Future<Result<void>> saveSettings(BackupSettings settings, String passphrase);
  Future<Result<void>> createManualBackup(String destinationUri, String passphrase);
  Future<Result<void>> restore(String sourceUri, String passphrase);
}
