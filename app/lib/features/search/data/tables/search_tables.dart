import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import '../../domain/entities/search_models.dart';

@DataClassName('SearchDocumentRow')
@TableIndex(
  name: 'idx_search_documents_entity',
  columns: {#entityType, #entityId},
  unique: true,
)
@TableIndex(
  name: 'idx_search_documents_filters',
  columns: {#entityType, #projectId, #occurredAt},
)
class SearchDocuments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => textEnum<SearchEntityType>()();
  IntColumn get entityId => integer()();
  TextColumn get title => text()();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get metadata => text().withDefault(const Constant(''))();
  TextColumn get tagKeys => text().withDefault(const Constant(''))();
  IntColumn get projectId => integer().nullable()();
  IntColumn get occurredAt => integer().nullable()();
  IntColumn get updatedAt => integer()();
}

@DataClassName('SearchIndexQueueRow')
@TableIndex(
  name: 'idx_search_queue_entity',
  columns: {#entityType, #entityId},
  unique: true,
)
class SearchIndexQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => textEnum<SearchEntityType>()();
  IntColumn get entityId => integer()();
}

@DataClassName('SearchHistoryRow')
@TableIndex(name: 'idx_search_history_searched', columns: {#searchedAt})
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get queryText => text()();
  TextColumn get filtersJson => text()();
  IntColumn get searchedAt => integer()();
  IntColumn get resultCount => integer()();
}

@DataClassName('SavedSearchRow')
@TableIndex(name: 'idx_saved_searches_name', columns: {#name}, unique: true)
class SavedSearches extends BusinessEntityTable {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get queryText => text()();
  TextColumn get filtersJson => text()();
  TextColumn get sortMode => textEnum<SearchSortMode>()();
}
