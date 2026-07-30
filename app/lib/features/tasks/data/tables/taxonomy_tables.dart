import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';

@DataClassName('CategoryRow')
@TableIndex(name: 'idx_categories_name', columns: {#name}, unique: true)
@TableIndex(name: 'idx_categories_sort_order', columns: {#sortOrder})
class Categories extends BusinessEntityTable {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

@DataClassName('SubcategoryRow')
@TableIndex(name: 'idx_subcategories_category_name', columns: {#categoryId, #name}, unique: true)
class Subcategories extends BusinessEntityTable {
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('TagRow')
@TableIndex(name: 'idx_tags_name', columns: {#name}, unique: true)
class Tags extends BusinessEntityTable {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
}