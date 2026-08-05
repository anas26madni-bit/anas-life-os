import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import '../../domain/entities/task_enums.dart';

@DataClassName('RepeatRuleRow')
@TableIndex(name: 'idx_repeat_rules_uuid', columns: {#uuid}, unique: true)
class RepeatRules extends BusinessEntityTable {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get frequency => textEnum<RepeatFrequency>()();
  IntColumn get recurrenceInterval =>
      integer().withDefault(const Constant(1))();
  IntColumn get weekdayMask => integer().withDefault(const Constant(0))();
  IntColumn get dayOfMonth => integer().nullable()();
  IntColumn get monthOfYear => integer().nullable()();
  TextColumn get timezoneId => text().withLength(min: 1, max: 100)();
  TextColumn get endType => textEnum<RepeatEndType>()();
  IntColumn get endAt => integer().nullable()();
  IntColumn get occurrenceLimit => integer().nullable()();
  TextColumn get seriesUuid => text().withLength(min: 36, max: 36)();
}
