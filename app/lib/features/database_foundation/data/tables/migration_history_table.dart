import 'package:drift/drift.dart';

import '../../domain/entities/migration_record.dart';

@DataClassName('MigrationHistoryRow')
@TableIndex(name: 'idx_migration_history_uuid', columns: {#uuid}, unique: true)
@TableIndex(
  name: 'idx_migration_history_status_started_at',
  columns: {#status, #startedAt},
)
class MigrationHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 36, max: 36)();

  IntColumn get fromVersion => integer()();

  IntColumn get toVersion => integer()();

  TextColumn get migrationName => text().withLength(min: 1, max: 200)();

  IntColumn get startedAt => integer()();

  IntColumn get completedAt => integer().nullable()();

  TextColumn get status => textEnum<MigrationStatus>()();

  @override
  String get tableName => 'migration_history';
}
