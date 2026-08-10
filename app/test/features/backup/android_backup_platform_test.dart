import 'package:anas_life_os/features/backup/data/services/android_backup_platform.dart';
import 'package:anas_life_os/features/backup/domain/entities/backup_models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/backup');
  const platform = AndroidBackupPlatform(channel: channel);
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return switch (call.method) {
            'selectDestination' => 'content://tree',
            'selectImport' => 'content://file',
            'createArchive' => <String, Object>{
              'uri': 'content://archive',
              'sizeBytes': 42,
              'sha256': 'checksum',
            },
            'restoreArchive' => 12,
            _ => null,
          };
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('maps storage selection and encrypted archive operations', () async {
    expect(await platform.selectDestination(), 'content://tree');
    expect(await platform.selectImport(), 'content://file');

    final archive = await platform.createArchive(
      databaseSnapshotPath: '/snapshot.db',
      managedFilePaths: const ['/managed.file'],
      destinationUri: 'content://tree',
      passphrase: 'secret',
      backupName: 'backup.alos',
    );
    expect(archive.uri, 'content://archive');
    expect(archive.sizeBytes, 42);
    expect(archive.sha256, 'checksum');

    final restore = await platform.restoreArchive(
      sourceUri: 'content://archive',
      passphrase: 'secret',
    );
    expect(restore.recordsRestored, 12);
    expect(calls.map((call) => call.method), containsAll(<String>[
      'selectDestination',
      'selectImport',
      'createArchive',
      'restoreArchive',
    ]));
  });

  test('maps automatic configuration and disable operations', () async {
    const settings = BackupSettings(
      automaticEnabled: true,
      frequency: BackupFrequency.weekly,
      retentionCount: 7,
      destinationUri: 'content://tree',
    );
    expect(settings.canSchedule, isTrue);

    await platform.configureAutomatic(settings: settings, passphrase: 'secret');
    await platform.disableAutomatic();

    expect(calls[0].method, 'configureAutomatic');
    expect(calls[0].arguments, containsPair('frequency', 'weekly'));
    expect(calls[1].method, 'disableAutomatic');
    expect(
      const BackupSettings(
        automaticEnabled: false,
        frequency: BackupFrequency.daily,
        retentionCount: 7,
      ).canSchedule,
      isFalse,
    );
  });

  test('rejects a missing native archive response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    expect(
      () => platform.createArchive(
        databaseSnapshotPath: '/snapshot.db',
        managedFilePaths: const [],
        destinationUri: 'content://tree',
        passphrase: 'secret',
        backupName: 'backup.alos',
      ),
      throwsStateError,
    );
  });
}
