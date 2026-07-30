import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/database_foundation/data/repositories/drift_migration_history_repository.dart';
import 'package:anas_life_os/features/database_foundation/data/services/migration_coordinator.dart';
import 'package:anas_life_os/features/database_foundation/domain/entities/migration_record.dart';
import 'package:anas_life_os/features/database_foundation/domain/repositories/migration_history_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('commits a valid migration and records its outcome', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final history = DriftMigrationHistoryRepository(database);
    final coordinator = MigrationCoordinator(
      database,
      history,
      clock: () => DateTime.utc(2026, 7, 30),
      uuidFactory: () => '00000000-0000-7000-8000-000000000001',
    );

    final result = await coordinator.execute(
      fromVersion: 1,
      toVersion: 2,
      name: 'create_probe',
      operation: (db) async {
        await db.customStatement(
          'CREATE TABLE migration_probe '
          '(id INTEGER PRIMARY KEY, value TEXT NOT NULL);',
        );
      },
    );

    expect(result, isA<Success<MigrationRecord>>());
    final records = await history.getAll();
    expect(records.single.status, MigrationStatus.succeeded);
    expect(records.single.completedAt, isNotNull);
  });

  test('rolls back failed work and records a sanitized failure', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final history = DriftMigrationHistoryRepository(database);
    final coordinator = MigrationCoordinator(
      database,
      history,
      clock: () => DateTime.utc(2026, 7, 30),
      uuidFactory: () => '00000000-0000-7000-8000-000000000002',
    );

    final result = await coordinator.execute(
      fromVersion: 1,
      toVersion: 2,
      name: 'failing_probe',
      operation: (db) async {
        await db.customStatement(
          'CREATE TABLE rollback_probe '
          '(id INTEGER PRIMARY KEY, value TEXT NOT NULL);',
        );
        throw StateError('Injected migration failure.');
      },
    );

    expect(result, isA<FailureResult<MigrationRecord>>());
    final table = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'rollback_probe';",
        )
        .get();
    expect(table, isEmpty);
    expect((await history.getAll()).single.status, MigrationStatus.failed);
  });

  test('rejects non-sequential migrations before changing data', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final history = DriftMigrationHistoryRepository(database);
    final coordinator = MigrationCoordinator(database, history);

    final result = await coordinator.execute(
      fromVersion: 1,
      toVersion: 3,
      name: 'invalid_sequence',
      operation: (_) async {},
    );

    expect(result, isA<FailureResult<MigrationRecord>>());
    expect(await history.getAll(), isEmpty);
  });

  test('rejects invalid migration metadata', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final history = DriftMigrationHistoryRepository(database);
    final coordinator = MigrationCoordinator(database, history);

    final result = await coordinator.execute(
      fromVersion: -1,
      toVersion: 0,
      name: '',
      operation: (_) async {},
    );

    expect(result, isA<FailureResult<MigrationRecord>>());
    expect(await history.getAll(), isEmpty);
  });

  test('returns a safe failure when migration history cannot start', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final coordinator = MigrationCoordinator(
      database,
      _FailingMigrationHistory(failOnStart: true),
    );

    final result = await coordinator.execute(
      fromVersion: 1,
      toVersion: 2,
      name: 'probe',
      operation: (_) async {},
    );

    expect(result, isA<FailureResult<MigrationRecord>>());
    expect(
      (result as FailureResult<MigrationRecord>).failure.code,
      'migration_history_unavailable',
    );
  });

  test('returns a safe failure when migration outcome cannot be saved', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final coordinator = MigrationCoordinator(
      database,
      _FailingMigrationHistory(),
      clock: () => DateTime.utc(2026, 7, 30),
    );

    final result = await coordinator.execute(
      fromVersion: 1,
      toVersion: 2,
      name: 'probe',
      operation: (_) async {},
    );

    expect(result, isA<FailureResult<MigrationRecord>>());
    expect(
      (result as FailureResult<MigrationRecord>).failure.code,
      'migration_outcome_unavailable',
    );
  });
}

final class _FailingMigrationHistory implements MigrationHistoryRepository {
  _FailingMigrationHistory({this.failOnStart = false});

  final bool failOnStart;

  @override
  Future<MigrationRecord> recordStarted({
    required String uuid,
    required int fromVersion,
    required int toVersion,
    required String name,
    required DateTime startedAt,
  }) async {
    if (failOnStart) {
      throw StateError('Injected start failure.');
    }
    return MigrationRecord(
      id: 1,
      uuid: uuid,
      fromVersion: fromVersion,
      toVersion: toVersion,
      name: name,
      startedAt: startedAt,
      status: MigrationStatus.running,
    );
  }

  @override
  Future<MigrationRecord> complete({
    required int id,
    required MigrationStatus status,
    required DateTime completedAt,
  }) {
    throw StateError('Injected completion failure.');
  }

  @override
  Future<List<MigrationRecord>> getAll() async => const [];
}
