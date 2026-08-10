import 'dart:io';

import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/backup_models.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/services/backup_platform.dart';

final class DriftBackupRepository implements BackupRepository {
  DriftBackupRepository(
    this._database,
    this._platform,
    this._databaseDirectory, {
    DateTime Function()? clock,
    UuidGenerator? uuidGenerator,
  }) : _clock = clock ?? DateTime.now,
       _uuid = uuidGenerator ?? UuidGenerator();

  final AppDatabase _database;
  final BackupPlatform _platform;
  final Future<Directory> Function() _databaseDirectory;
  final DateTime Function() _clock;
  final UuidGenerator _uuid;

  @override
  Future<BackupSettings> loadSettings() async {
    final row = await (_database.select(_database.backupProfiles)
          ..where((table) => table.id.equals(1)))
        .getSingleOrNull();
    if (row == null) return _defaults;
    return BackupSettings(
      automaticEnabled: row.automaticEnabled,
      frequency: BackupFrequency.values.byName(row.frequency),
      retentionCount: row.retentionCount,
      destinationUri: row.destinationUri,
    );
  }

  @override
  Future<List<BackupRecord>> loadHistory() async {
    final rows = await (_database.select(_database.backupHistory)
          ..orderBy([(row) => OrderingTerm.desc(row.startedAt)]))
        .get();
    return rows
        .map(
          (row) => BackupRecord(
            id: row.id,
            name: row.backupName,
            automatic: row.automatic,
            status: BackupOperationStatus.values.byName(row.status),
            startedAt: _date(row.startedAt),
            completedAt: row.completedAt == null ? null : _date(row.completedAt!),
            sizeBytes: row.backupSize,
            safeError: row.errorCode,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Result<void>> saveSettings(
    BackupSettings settings,
    String passphrase,
  ) async {
    if (settings.retentionCount < 1 || settings.retentionCount > 30) {
      return const FailureResult(
        ValidationFailure(
          code: 'backup_retention_invalid',
          safeMessage: 'Backup retention must be between 1 and 30.',
        ),
      );
    }
    if (settings.canSchedule && passphrase.isEmpty) {
      return const FailureResult(
        ValidationFailure(
          code: 'backup_passphrase_required',
          safeMessage: 'A backup passphrase is required.',
        ),
      );
    }
    try {
      final now = _micros(_clock());
      await _database.into(_database.backupProfiles).insertOnConflictUpdate(
        BackupProfilesCompanion.insert(
          id: const Value(1),
          uuid: _uuid.generate(),
          profileName: 'default',
          automaticEnabled: Value(settings.automaticEnabled),
          frequency: Value(settings.frequency.name),
          retentionCount: Value(settings.retentionCount),
          destinationUri: Value(settings.destinationUri),
          createdAt: now,
          updatedAt: now,
        ),
      );
      if (settings.canSchedule) {
        await _platform.configureAutomatic(
          settings: settings,
          passphrase: passphrase,
        );
      } else {
        await _platform.disableAutomatic();
      }
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'backup_settings_failed',
          safeMessage: 'Backup settings could not be saved safely.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> createManualBackup(
    String destinationUri,
    String passphrase,
  ) async {
    if (passphrase.isEmpty) return _passphraseFailure;
    final started = _clock().toUtc();
    final name = 'anas-life-os-${started.toIso8601String().replaceAll(':', '-')}.alos';
    final historyId = await _startBackup(name, started);
    File? snapshot;
    try {
      final directory = await _databaseDirectory();
      snapshot = File('${directory.path}${Platform.pathSeparator}backup_snapshot.db');
      if (await snapshot.exists()) await snapshot.delete();
      await _database.customStatement('PRAGMA wal_checkpoint(FULL);');
      final escapedPath = snapshot.path.replaceAll("'", "''");
      await _database.customStatement("VACUUM INTO '$escapedPath';");
      final files = await _managedFilePaths();
      final result = await _platform.createArchive(
        databaseSnapshotPath: snapshot.path,
        managedFilePaths: files,
        destinationUri: destinationUri,
        passphrase: passphrase,
        backupName: name,
      );
      await (_database.update(_database.backupHistory)
            ..where((row) => row.id.equals(historyId)))
          .write(
            BackupHistoryCompanion(
              destinationUri: Value(result.uri),
              backupSize: Value(result.sizeBytes),
              checksumSha256: Value(result.sha256),
              completedAt: Value(_micros(_clock())),
              status: const Value('succeeded'),
            ),
          );
      return const Success(null);
    } on Object {
      await _failBackup(historyId);
      return const FailureResult(
        DatabaseFailure(
          code: 'backup_create_failed',
          safeMessage: 'The backup failed safely. Existing data was not changed.',
        ),
      );
    } finally {
      if (snapshot != null && await snapshot.exists()) await snapshot.delete();
    }
  }

  @override
  Future<Result<void>> restore(String sourceUri, String passphrase) async {
    if (passphrase.isEmpty) return _passphraseFailure;
    final started = _clock().toUtc();
    final id = await _database.into(_database.restoreHistory).insert(
      RestoreHistoryCompanion.insert(
        uuid: _uuid.generate(),
        sourceUri: sourceUri,
        startedAt: _micros(started),
        status: 'running',
      ),
    );
    try {
      final result = await _platform.restoreArchive(
        sourceUri: sourceUri,
        passphrase: passphrase,
      );
      await (_database.update(_database.restoreHistory)
            ..where((row) => row.id.equals(id)))
          .write(
            RestoreHistoryCompanion(
              completedAt: Value(_micros(_clock())),
              status: const Value('succeeded'),
              recordsRestored: Value(result.recordsRestored),
            ),
          );
      return const Success(null);
    } on Object {
      await (_database.update(_database.restoreHistory)
            ..where((row) => row.id.equals(id)))
          .write(
            RestoreHistoryCompanion(
              completedAt: Value(_micros(_clock())),
              status: const Value('failed'),
              errorCode: const Value('restore_validation_failed'),
            ),
          );
      return const FailureResult(
        DatabaseFailure(
          code: 'restore_failed',
          safeMessage: 'Restore failed safely. Existing data was preserved.',
        ),
      );
    }
  }

  Future<int> _startBackup(String name, DateTime started) =>
      _database.into(_database.backupHistory).insert(
        BackupHistoryCompanion.insert(
          uuid: _uuid.generate(),
          backupName: name,
          automatic: false,
          startedAt: _micros(started),
          status: 'running',
        ),
      );

  Future<void> _failBackup(int id) =>
      (_database.update(_database.backupHistory)..where((row) => row.id.equals(id))).write(
        BackupHistoryCompanion(
          completedAt: Value(_micros(_clock())),
          status: const Value('failed'),
          errorCode: const Value('backup_create_failed'),
        ),
      );

  Future<List<String>> _managedFilePaths() async {
    final rows = await _database.customSelect(
      'SELECT storage_path FROM attachments WHERE is_deleted = 0 '
      'UNION SELECT storage_path FROM attachment_versions '
      'UNION SELECT storage_path FROM document_versions',
      readsFrom: {
        _database.attachments,
        _database.attachmentVersions,
        _database.documentVersions,
      },
    ).get();
    return rows
        .map((row) => row.read<String>('storage_path'))
        .where((path) => File(path).existsSync())
        .toSet()
        .toList(growable: false);
  }

  static const _defaults = BackupSettings(
    automaticEnabled: false,
    frequency: BackupFrequency.daily,
    retentionCount: 7,
  );
  static const Result<void> _passphraseFailure = FailureResult(
    ValidationFailure(
      code: 'backup_passphrase_required',
      safeMessage: 'A backup passphrase is required.',
    ),
  );
  int _micros(DateTime value) => value.toUtc().microsecondsSinceEpoch;
  DateTime _date(int value) =>
      DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
}
