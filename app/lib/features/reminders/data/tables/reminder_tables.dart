import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import '../../../tasks/data/tables/repeat_rule_table.dart';
import '../../../tasks/data/tables/task_table.dart';
import '../../domain/entities/reminder_enums.dart';

@DataClassName('ReminderRow')
@TableIndex(name: 'idx_reminders_uuid', columns: {#uuid}, unique: true)
@TableIndex(name: 'idx_reminders_task', columns: {#taskId})
@TableIndex(name: 'idx_reminders_schedule', columns: {#enabled, #scheduledAt})
class Reminders extends BusinessEntityTable {
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get message => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get scheduledAt => integer()();
  TextColumn get timezoneId => text().withLength(min: 1, max: 100)();
  IntColumn get repeatRuleId =>
      integer().nullable().references(RepeatRules, #id)();
  TextColumn get sound => text().nullable()();
  BoolColumn get vibration => boolean().withDefault(const Constant(true))();
  BoolColumn get flash => boolean().withDefault(const Constant(false))();
  BoolColumn get voiceEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get fullScreen => boolean().withDefault(const Constant(false))();
  TextColumn get priority => textEnum<ReminderPriority>()();
  IntColumn get snoozeMinutes => integer().withDefault(const Constant(10))();
  IntColumn get maxSnoozes => integer().withDefault(const Constant(3))();
  BoolColumn get autoSnooze => boolean().withDefault(const Constant(false))();
  IntColumn get escalationStep => integer().withDefault(const Constant(0))();
}

@DataClassName('ReminderHistoryRow')
@TableIndex(
  name: 'idx_reminder_history_reminder',
  columns: {#reminderId, #occurredAt},
)
@TableIndex(
  name: 'idx_reminder_history_occurrence_action',
  columns: {#occurrenceUuid, #action},
  unique: true,
)
class ReminderHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  IntColumn get reminderId => integer().references(Reminders, #id)();
  TextColumn get occurrenceUuid => text().withLength(min: 36, max: 36)();
  TextColumn get action => textEnum<ReminderAction>()();
  IntColumn get occurredAt => integer()();
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
}
