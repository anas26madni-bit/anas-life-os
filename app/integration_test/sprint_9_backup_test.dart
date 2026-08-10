import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/backup/domain/entities/backup_models.dart';
import 'package:anas_life_os/features/backup/domain/services/backup_platform.dart';
import 'package:anas_life_os/features/backup/presentation/pages/backup_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/database_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Sprint 9 backup center loads on Android 11', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
          backupPlatformProvider.overrideWithValue(
            _IntegrationBackupPlatform(),
          ),
        ],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const BackupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BackupPage), findsOneWidget);
    expect(find.byIcon(Icons.backup_outlined), findsOneWidget);
  });
}

final class _IntegrationBackupPlatform implements BackupPlatform {
  @override
  Future<BackupArchiveResult> createArchive({
    required String databaseSnapshotPath,
    required List<String> managedFilePaths,
    required String destinationUri,
    required String passphrase,
    required String backupName,
  }) async => const BackupArchiveResult(
    uri: 'content://file',
    sizeBytes: 1,
    sha256: 'hash',
  );
  @override
  Future<void> configureAutomatic({
    required BackupSettings settings,
    required String passphrase,
  }) async {}
  @override
  Future<void> disableAutomatic() async {}
  @override
  Future<RestoreArchiveResult> restoreArchive({
    required String sourceUri,
    required String passphrase,
  }) async => const RestoreArchiveResult(recordsRestored: 0);
  @override
  Future<String?> selectDestination() async => 'content://tree';
  @override
  Future<String?> selectImport() async => 'content://file';
}
