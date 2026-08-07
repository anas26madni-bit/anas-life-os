enum SearchEntityType { task, project, note, document, attachment }

enum SearchSortMode { relevance, newest, oldest, title }

final class SearchQuery {
  const SearchQuery({
    this.text = '',
    this.entityTypes = const {},
    this.dateFrom,
    this.dateTo,
    this.projectId,
    this.tags = const [],
    this.sortMode = SearchSortMode.relevance,
    this.limit = 50,
    this.offset = 0,
  });

  final String text;
  final Set<SearchEntityType> entityTypes;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? projectId;
  final List<String> tags;
  final SearchSortMode sortMode;
  final int limit;
  final int offset;

  SearchQuery copyWith({
    String? text,
    Set<SearchEntityType>? entityTypes,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? projectId,
    List<String>? tags,
    SearchSortMode? sortMode,
    int? limit,
    int? offset,
    bool clearDates = false,
    bool clearProject = false,
  }) => SearchQuery(
    text: text ?? this.text,
    entityTypes: entityTypes ?? this.entityTypes,
    dateFrom: clearDates ? null : dateFrom ?? this.dateFrom,
    dateTo: clearDates ? null : dateTo ?? this.dateTo,
    projectId: clearProject ? null : projectId ?? this.projectId,
    tags: tags ?? this.tags,
    sortMode: sortMode ?? this.sortMode,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
  );
}

final class SearchResultItem {
  const SearchResultItem({
    required this.entityType,
    required this.entityId,
    required this.title,
    required this.updatedAt,
    this.summary,
    this.projectId,
    this.rank,
  });

  final SearchEntityType entityType;
  final int entityId;
  final String title;
  final String? summary;
  final int? projectId;
  final DateTime updatedAt;
  final double? rank;
}

final class SavedSearchDraft {
  const SavedSearchDraft({required this.name, required this.query});
  final String name;
  final SearchQuery query;
}

final class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.uuid,
    required this.name,
    required this.query,
    required this.createdAt,
    required this.updatedAt,
  });
  final int id;
  final String uuid;
  final String name;
  final SearchQuery query;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class RecentSearch {
  const RecentSearch({required this.query, required this.searchedAt});
  final SearchQuery query;
  final DateTime searchedAt;
}
