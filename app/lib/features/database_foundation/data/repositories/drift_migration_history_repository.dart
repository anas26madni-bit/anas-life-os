import 'package:drift/drift.dart';

import '../../domain/entities/migration_record.dart';
import '../../domain/repositories/migration_history_repository.dart';
import '../database/app_database.dart';

final class DriftMigrationHistoryRepository
    implements MigrationHistoryRepository {
  const DriftMigrationHistoryRepository(this._database);

  final AppDatabase _database;

  @override
  Future<MigrationRecord> recordStarted({
    required String uuid,
    required int fromVersion,
    required int toVersion,
    required String name,
    required DateTime startedAt,
  }) async {
    final id = await _database
        .into(_database.migrationHistory)
        .insert(
          MigrationHistoryCompanion.insert(
            uuid: uuid,
            fromVersion: fromVersion,
            toVersion: toVersion,
            migrationName: name,
            startedAt: startedAt.toUtc().microsecondsSinceEpoch,
            status: MigrationStatus.running,
          ),
        );
    return MigrationRecord(
      id: id,
      uuid: uuid,
      fromVersion: fromVersion,
      toVersion: toVersion,
      name: name,
      startedAt: startedAt.toUtc(),
      status: MigrationStatus.running,
    );
  }

  @override
  Future<MigrationRecord> complete({
    required int id,
    required MigrationStatus status,
    required DateTime completedAt,
  }) async {
    if (status == MigrationStatus.running) {
      throw ArgumentError.value(
        status,
        'status',
        'A completed migration cannot remain running.',
      );
    }
    final statement = _database.update(_database.migrationHistory)
      ..where((table) => table.id.equals(id));
    final affected = await statement.write(
      MigrationHistoryCompanion(
        status: Value(status),
        completedAt: Value(completedAt.toUtc().microsecondsSinceEpoch),
      ),
    );
    if (affected != 1) {
      throw StateError('Migration history record $id was not found.');
    }
    final row = await (_database.select(
      _database.migrationHistory,
    )..where((table) => table.id.equals(id))).getSingle();
    return _map(row);
  }

  @override
  Future<List<MigrationRecord>> getAll() async {
    final query = _database.select(_database.migrationHistory)
      ..orderBy([(table) => OrderingTerm.asc(table.startedAt)]);
    return (await query.get()).map(_map).toList(growable: false);
  }

  MigrationRecord _map(MigrationHistoryRow row) => MigrationRecord(
    id: row.id,
    uuid: row.uuid,
    fromVersion: row.fromVersion,
    toVersion: row.toVersion,
    name: row.migrationName,
    startedAt: DateTime.fromMicrosecondsSinceEpoch(row.startedAt, isUtc: true),
    completedAt: row.completedAt == null
        ? null
        : DateTime.fromMicrosecondsSinceEpoch(row.completedAt!, isUtc: true),
    status: row.status,
  );
}
