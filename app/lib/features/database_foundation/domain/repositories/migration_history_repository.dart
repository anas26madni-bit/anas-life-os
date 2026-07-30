import '../entities/migration_record.dart';

abstract interface class MigrationHistoryRepository {
  Future<MigrationRecord> recordStarted({
    required String uuid,
    required int fromVersion,
    required int toVersion,
    required String name,
    required DateTime startedAt,
  });

  Future<MigrationRecord> complete({
    required int id,
    required MigrationStatus status,
    required DateTime completedAt,
  });

  Future<List<MigrationRecord>> getAll();
}
