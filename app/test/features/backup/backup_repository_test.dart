import 'dart:io';

import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/backup/data/repositories/drift_backup_repository.dart';
import 'package:anas_life_os/features/backup/domain/entities/backup_models.dart';
import 'package:anas_life_os/features/backup/domain/services/backup_platform.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('backup_repository_test_');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('defaults match approved automatic backup policy', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftBackupRepository(database, _FakeBackupPlatform(), () async => directory);

    final settings = await repository.loadSettings();

    expect(settings.automaticEnabled, isFalse);
    expect(settings.frequency, BackupFrequency.daily);
    expect(settings.retentionCount, 7);
  });

  test('validates and persists approved retention range', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final platform = _FakeBackupPlatform();
    final repository = DriftBackupRepository(database, platform, () async => directory);
    const settings = BackupSettings(
      automaticEnabled: true,
      frequency: BackupFrequency.weekly,
      retentionCount: 30,
      destinationUri: 'content://backup/tree',
    );

    expect(await repository.saveSettings(settings, 'secret'), isA<Success<void>>());
    expect((await repository.loadSettings()).frequency, BackupFrequency.weekly);
    expect(platform.configured, settings);

    const invalid = BackupSettings(
      automaticEnabled: false,
      frequency: BackupFrequency.daily,
      retentionCount: 31,
    );
    expect(await repository.saveSettings(invalid, ''), isA<FailureResult<void>>());
  });

  test('manual backup uses verified snapshot and records success', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final platform = _FakeBackupPlatform();
    final repository = DriftBackupRepository(database, platform, () async => directory);

    final result = await repository.createManualBackup('content://backup/tree', 'secret');

    expect(result, isA<Success<void>>());
    expect(platform.snapshotWasPresent, isTrue);
    final history = await repository.loadHistory();
    expect(history.single.status, BackupOperationStatus.succeeded);
    expect(history.single.automatic, isFalse);
  });

  test('wrong restore input fails without reporting success', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final platform = _FakeBackupPlatform()..failRestore = true;
    final repository = DriftBackupRepository(database, platform, () async => directory);

    final result = await repository.restore('content://backup/file', 'wrong');

    expect(result, isA<FailureResult<void>>());
  });
}

final class _FakeBackupPlatform implements BackupPlatform {
  BackupSettings? configured;
  bool snapshotWasPresent = false;
  bool failRestore = false;

  @override
  Future<BackupArchiveResult> createArchive({
    required String databaseSnapshotPath,
    required List<String> managedFilePaths,
    required String destinationUri,
    required String passphrase,
    required String backupName,
  }) async {
    snapshotWasPresent = File(databaseSnapshotPath).existsSync();
    return const BackupArchiveResult(
      uri: 'content://backup/file',
      sizeBytes: 2048,
      sha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );
  }

  @override
  Future<void> configureAutomatic({
    required BackupSettings settings,
    required String passphrase,
  }) async => configured = settings;

  @override
  Future<void> disableAutomatic() async {}

  @override
  Future<RestoreArchiveResult> restoreArchive({
    required String sourceUri,
    required String passphrase,
  }) async {
    if (failRestore) throw StateError('invalid archive');
    return const RestoreArchiveResult(recordsRestored: 1);
  }

  @override
  Future<String?> selectDestination() async => 'content://backup/tree';

  @override
  Future<String?> selectImport() async => 'content://backup/file';
}
