import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import 'task_table.dart';

@DataClassName('ChecklistRow')
@TableIndex(name: 'idx_checklists_task_sort', columns: {#taskId, #sortOrder})
class Checklists extends BusinessEntityTable {
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get title => text().withLength(min: 1, max: 300)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('ChecklistItemRow')
@TableIndex(
  name: 'idx_checklist_items_list_sort',
  columns: {#checklistId, #sortOrder},
)
class ChecklistItems extends BusinessEntityTable {
  IntColumn get checklistId => integer().references(Checklists, #id)();
  TextColumn get title => text().withLength(min: 1, max: 300)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
