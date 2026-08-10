import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/backup_models.dart';
import '../../domain/repositories/backup_repository.dart';

final class BackupViewState {
  const BackupViewState({required this.settings, required this.history});

  final BackupSettings settings;
  final List<BackupRecord> history;
}

final backupControllerProvider =
    AsyncNotifierProvider<BackupController, BackupViewState>(
      BackupController.new,
    );

class BackupController extends AsyncNotifier<BackupViewState> {
  @override
  Future<BackupViewState> build() async {
    final repository = await ref.watch(backupRepositoryProvider.future);
    return BackupViewState(
      settings: await repository.loadSettings(),
      history: await repository.loadHistory(),
    );
  }

  Future<String?> selectDestination() =>
      ref.read(backupPlatformProvider).selectDestination();

  Future<void> saveSettings(BackupSettings settings, String passphrase) async {
    await _mutate((repository) => repository.saveSettings(settings, passphrase));
  }

  Future<void> manualBackup(String destination, String passphrase) async {
    await _mutate(
      (repository) => repository.createManualBackup(destination, passphrase),
    );
  }

  Future<void> importAndRestore(String passphrase) async {
    final source = await ref.read(backupPlatformProvider).selectImport();
    if (source == null) return;
    await _mutate((repository) => repository.restore(source, passphrase));
    ref.invalidate(appDatabaseProvider);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  Future<void> _mutate(
    Future<Result<void>> Function(BackupRepository repository) operation,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(backupRepositoryProvider.future);
      final result = await operation(repository);
      switch (result) {
        case Success<void>():
          return BackupViewState(
            settings: await repository.loadSettings(),
            history: await repository.loadHistory(),
          );
        case FailureResult<void>(:final failure):
          throw BackupOperationException(failure.safeMessage);
      }
    });
  }
}

final class BackupOperationException implements Exception {
  const BackupOperationException(this.message);
  final String message;

  @override
  String toString() => message;
}
