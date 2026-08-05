import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';

@DataClassName('ProjectRow')
@TableIndex(name: 'idx_projects_title', columns: {#title})
@TableIndex(name: 'idx_projects_status_due', columns: {#status, #dueAt})
class Projects extends BusinessEntityTable {
  TextColumn get title => text().withLength(min: 1, max: 300)();
  TextColumn get description => text().nullable()();
  TextColumn get coverImage => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get budgetMinor => integer().nullable()();
  TextColumn get currencyCode => text().withLength(min: 3, max: 3).nullable()();
  IntColumn get startAt => integer().nullable()();
  IntColumn get dueAt => integer().nullable()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get ownerName => text().nullable()();
}
