import 'package:drift/drift.dart';

@DataClassName('BackupProfileRow')
class BackupProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  TextColumn get profileName => text().withLength(min: 1, max: 100)();
  BoolColumn get automaticEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get frequency => text().withDefault(const Constant('daily'))();
  IntColumn get retentionCount => integer().withDefault(const Constant(7))();
  TextColumn get destinationUri => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

@DataClassName('BackupHistoryRow')
@TableIndex(name: 'idx_backup_history_started', columns: {#startedAt})
class BackupHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  IntColumn get profileId => integer().nullable().references(BackupProfiles, #id)();
  TextColumn get backupName => text().withLength(min: 1, max: 200)();
  BoolColumn get automatic => boolean()();
  TextColumn get destinationUri => text().nullable()();
  IntColumn get backupSize => integer().nullable()();
  TextColumn get checksumSha256 => text().nullable()();
  IntColumn get startedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get errorCode => text().nullable()();
}

@DataClassName('RestoreHistoryRow')
class RestoreHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  TextColumn get sourceUri => text()();
  IntColumn get startedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get status => text()();
  IntColumn get recordsRestored => integer().nullable()();
  TextColumn get errorCode => text().nullable()();
}
