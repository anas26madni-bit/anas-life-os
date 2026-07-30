import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import '../../domain/entities/task_enums.dart';
import 'project_tables.dart';
import 'repeat_rule_table.dart';
import 'taxonomy_tables.dart';

@DataClassName('TaskRow')
@TableIndex(name: 'idx_tasks_uuid', columns: {#uuid}, unique: true)
@TableIndex(name: 'idx_tasks_title', columns: {#title})
@TableIndex(name: 'idx_tasks_status_due', columns: {#status, #dueAt})
@TableIndex(name: 'idx_tasks_project_status', columns: {#projectId, #status})
@TableIndex(name: 'idx_tasks_category', columns: {#categoryId})
@TableIndex(name: 'idx_tasks_parent_sort', columns: {#parentTaskId, #sortOrder})
@TableIndex(name: 'idx_tasks_pinned', columns: {#pinned})
@TableIndex(name: 'idx_tasks_favorite', columns: {#favorite})
@TableIndex(name: 'idx_tasks_updated_at', columns: {#updatedAt})
class Tasks extends BusinessEntityTable {
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get subcategoryId =>
      integer().nullable().references(Subcategories, #id)();
  IntColumn get parentTaskId => integer().nullable().references(Tasks, #id)();
  IntColumn get repeatRuleId =>
      integer().nullable().references(RepeatRules, #id)();
  TextColumn get title => text().withLength(min: 1, max: 300)();
  TextColumn get description => text().nullable()();
  TextColumn get status => textEnum<TaskStatus>()();
  TextColumn get preDeleteStatus => textEnum<TaskStatus>().nullable()();
  TextColumn get priority => textEnum<TaskPriority>()();
  IntColumn get energyLevel => integer().nullable()();
  IntColumn get difficulty => integer().nullable()();
  IntColumn get estimatedMinutes => integer().nullable()();
  IntColumn get actualMinutes => integer().nullable()();
  IntColumn get startAt => integer().nullable()();
  IntColumn get dueAt => integer().nullable()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get progress => integer().withDefault(const Constant(0))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isMandatory => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get voiceNoteCount => integer().withDefault(const Constant(0))();
  IntColumn get attachmentCount => integer().withDefault(const Constant(0))();
  IntColumn get subtaskCount => integer().withDefault(const Constant(0))();
  IntColumn get checklistCount => integer().withDefault(const Constant(0))();
  IntColumn get commentCount => integer().withDefault(const Constant(0))();
  IntColumn get customFieldCount => integer().withDefault(const Constant(0))();
}
