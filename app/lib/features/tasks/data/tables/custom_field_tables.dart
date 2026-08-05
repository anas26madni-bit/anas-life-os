import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import '../../domain/entities/task_enums.dart';
import 'project_tables.dart';
import 'task_table.dart';

@DataClassName('CustomFieldRow')
@TableIndex(
  name: 'idx_custom_fields_owner_sort',
  columns: {#ownerType, #sortOrder},
)
class CustomFields extends BusinessEntityTable {
  TextColumn get ownerType => textEnum<CustomFieldOwner>()();
  TextColumn get label => text().withLength(min: 1, max: 200)();
  TextColumn get fieldType => textEnum<CustomFieldType>()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  BoolColumn get isSearchable => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get validationJson => text().withDefault(const Constant('{}'))();
  TextColumn get choicesJson => text().withDefault(const Constant('[]'))();
}

@DataClassName('CustomFieldValueRow')
@TableIndex(name: 'idx_custom_field_values_task', columns: {#taskId})
@TableIndex(name: 'idx_custom_field_values_project', columns: {#projectId})
@TableIndex(
  name: 'idx_custom_field_values_unique_task',
  columns: {#customFieldId, #taskId},
  unique: true,
)
@TableIndex(
  name: 'idx_custom_field_values_unique_project',
  columns: {#customFieldId, #projectId},
  unique: true,
)
class CustomFieldValues extends BusinessEntityTable {
  IntColumn get customFieldId => integer().references(CustomFields, #id)();
  IntColumn get taskId => integer().nullable().references(Tasks, #id)();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  TextColumn get valueJson => text()();
}
