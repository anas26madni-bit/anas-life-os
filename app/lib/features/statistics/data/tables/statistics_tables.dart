import 'package:drift/drift.dart';

import '../../../tasks/data/tables/project_tables.dart';

@DataClassName('DailyStatisticsRow')
@TableIndex(
  name: 'idx_daily_statistics_scope_period',
  columns: {#scopeKey, #periodStartUtc},
  unique: true,
)
@TableIndex(name: 'idx_daily_statistics_project', columns: {#projectId})
class DailyStatisticsProjections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get scopeKey => text().withLength(min: 3, max: 64)();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  IntColumn get periodStartUtc => integer()();
  IntColumn get periodEndUtc => integer()();
  IntColumn get timezoneOffsetMinutes => integer()();
  IntColumn get eligibleCount => integer()();
  IntColumn get completedByEndCount => integer()();
  IntColumn get onTimeCount => integer()();
  IntColumn get delayTotalMicroseconds => integer()();
  IntColumn get delaySampleCount => integer()();
  IntColumn get rebuiltAt => integer()();
}
