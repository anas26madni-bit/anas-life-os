import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';

@DataClassName('CalendarEventRow')
@TableIndex(name: 'idx_calendar_events_uuid', columns: {#uuid}, unique: true)
@TableIndex(
  name: 'idx_calendar_events_range',
  columns: {#startAt, #endAt, #isDeleted},
)
class CalendarEvents extends BusinessEntityTable {
  TextColumn get title => text().withLength(min: 1, max: 300)();
  TextColumn get description => text().nullable()();
  IntColumn get startAt => integer()();
  IntColumn get endAt => integer()();
  BoolColumn get allDay => boolean().withDefault(const Constant(false))();
  TextColumn get timezoneId =>
      text().withLength(min: 1, max: 100).withDefault(const Constant('UTC'))();
  TextColumn get location => text().nullable()();
  TextColumn get color => text().nullable()();
}
