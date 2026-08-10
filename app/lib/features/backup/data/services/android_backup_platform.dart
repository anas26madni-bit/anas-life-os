import 'package:flutter/services.dart';

import '../../domain/entities/backup_models.dart';
import '../../domain/services/backup_platform.dart';

final class AndroidBackupPlatform implements BackupPlatform {
  const AndroidBackupPlatform({
    this.channel = const MethodChannel('com.anaslifeos.app/backup'),
  });

  final MethodChannel channel;

  @override
  Future<String?> selectDestination() => channel.invokeMethod<String>('selectDestination');

  @override
  Future<String?> selectImport() => channel.invokeMethod<String>('selectImport');

  @override
  Future<BackupArchiveResult> createArchive({
    required String databaseSnapshotPath,
    required List<String> managedFilePaths,
    required String destinationUri,
    required String passphrase,
    required String backupName,
  }) async {
    final value = await channel.invokeMapMethod<String, Object?>('createArchive', {
      'databaseSnapshotPath': databaseSnapshotPath,
      'managedFilePaths': managedFilePaths,
      'destinationUri': destinationUri,
      'passphrase': passphrase,
      'backupName': backupName,
    });
    if (value == null) throw StateError('Backup result was unavailable.');
    return BackupArchiveResult(
      uri: value['uri']! as String,
      sizeBytes: value['sizeBytes']! as int,
      sha256: value['sha256']! as String,
    );
  }

  @override
  Future<RestoreArchiveResult> restoreArchive({
    required String sourceUri,
    required String passphrase,
  }) async {
    final count = await channel.invokeMethod<int>('restoreArchive', {
      'sourceUri': sourceUri,
      'passphrase': passphrase,
    });
    return RestoreArchiveResult(recordsRestored: count ?? 0);
  }

  @override
  Future<void> configureAutomatic({
    required BackupSettings settings,
    required String passphrase,
  }) => channel.invokeMethod<void>('configureAutomatic', {
    'destinationUri': settings.destinationUri,
    'frequency': settings.frequency.name,
    'retentionCount': settings.retentionCount,
    'passphrase': passphrase,
  });

  @override
  Future<void> disableAutomatic() => channel.invokeMethod<void>('disableAutomatic');
}
