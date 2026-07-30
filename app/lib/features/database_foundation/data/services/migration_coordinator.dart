import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/migration_record.dart';
import '../../domain/repositories/migration_history_repository.dart';
import '../database/app_database.dart';

typedef MigrationOperation = Future<void> Function(AppDatabase database);

final class MigrationCoordinator {
  MigrationCoordinator(
    this._database,
    this._history, {
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final MigrationHistoryRepository _history;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  Future<Result<MigrationRecord>> execute({
    required int fromVersion,
    required int toVersion,
    required String name,
    required MigrationOperation operation,
  }) async {
    final normalizedName = name.trim();
    if (fromVersion < 0 ||
        toVersion != fromVersion + 1 ||
        normalizedName.isEmpty) {
      return const FailureResult(
        DatabaseFailure(
          code: 'invalid_migration_sequence',
          safeMessage: 'The database migration sequence is invalid.',
        ),
      );
    }

    late final MigrationRecord started;
    try {
      started = await _history.recordStarted(
        uuid: _uuidFactory(),
        fromVersion: fromVersion,
        toVersion: toVersion,
        name: normalizedName,
        startedAt: _clock(),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'migration_history_unavailable',
          safeMessage: 'The database migration could not start safely.',
        ),
      );
    }

    try {
      await _database.transaction(() async {
        await operation(_database);
        await _database.verifyIntegrity();
      });
    } on Object {
      try {
        final failed = await _history.complete(
          id: started.id,
          status: MigrationStatus.failed,
          completedAt: _clock(),
        );
        return FailureResult(
          DatabaseFailure(
            code: 'migration_failed',
            safeMessage:
                'Database migration ${failed.fromVersion} to '
                '${failed.toVersion} failed safely.',
          ),
        );
      } on Object {
        return const FailureResult(
          DatabaseFailure(
            code: 'migration_outcome_unavailable',
            safeMessage:
                'The migration was rolled back, but its outcome could not be '
                'recorded.',
          ),
        );
      }
    }

    try {
      return Success(
        await _history.complete(
          id: started.id,
          status: MigrationStatus.succeeded,
          completedAt: _clock(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'migration_outcome_unavailable',
          safeMessage:
              'The migration completed, but its outcome could not be recorded.',
        ),
      );
    }
  }
}
