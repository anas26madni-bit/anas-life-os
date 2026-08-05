import 'package:drift/drift.dart';

import '../../domain/entities/task_enums.dart';
import 'task_table.dart';
import 'taxonomy_tables.dart';

@DataClassName('TaskTagRow')
@TableIndex(
  name: 'idx_task_tags_pair',
  columns: {#taskId, #tagId},
  unique: true,
)
class TaskTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();
  IntColumn get createdAt => integer()();
}

@DataClassName('TaskDependencyRow')
@TableIndex(
  name: 'idx_task_dependencies_pair',
  columns: {#taskId, #dependsOnTaskId},
  unique: true,
)
@TableIndex(name: 'idx_task_dependencies_reverse', columns: {#dependsOnTaskId})
class TaskDependencies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  @ReferenceName('outgoingDependencies')
  IntColumn get taskId => integer().references(Tasks, #id)();

  @ReferenceName('incomingDependencies')
  IntColumn get dependsOnTaskId => integer().references(Tasks, #id)();
  TextColumn get dependencyType => textEnum<DependencyType>()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

@DataClassName('TaskStateHistoryRow')
@TableIndex(
  name: 'idx_task_state_history_task_changed',
  columns: {#taskId, #changedAt},
)
class TaskStateHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get previousState => textEnum<TaskStatus>().nullable()();
  TextColumn get newState => textEnum<TaskStatus>()();
  TextColumn get reason => text().nullable()();
  TextColumn get changedBy => text().nullable()();
  IntColumn get changedAt => integer()();
  IntColumn get createdAt => integer()();
}

@DataClassName('TaskChangeHistoryRow')
@TableIndex(
  name: 'idx_task_history_task_changed',
  columns: {#taskId, #changedAt},
)
class TaskHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get action => text().withLength(min: 1, max: 100)();
  TextColumn get changedField => text().nullable()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  IntColumn get changedAt => integer()();
  IntColumn get createdAt => integer()();

  @override
  String get tableName => 'task_history';
}
