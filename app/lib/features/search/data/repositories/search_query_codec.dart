import 'dart:convert';

import '../../domain/entities/search_models.dart';

abstract final class SearchQueryCodec {
  static String encode(SearchQuery query) => jsonEncode({
    'entityTypes': query.entityTypes.map((type) => type.name).toList(),
    'dateFrom': query.dateFrom?.toUtc().microsecondsSinceEpoch,
    'dateTo': query.dateTo?.toUtc().microsecondsSinceEpoch,
    'projectId': query.projectId,
    'tags': query.tags,
    'sortMode': query.sortMode.name,
  });

  static SearchQuery decode(String text, String filtersJson) {
    final json = jsonDecode(filtersJson) as Map<String, Object?>;
    final entityNames = (json['entityTypes'] as List<Object?>? ?? const [])
        .whereType<String>()
        .toSet();
    return SearchQuery(
      text: text,
      entityTypes: SearchEntityType.values
          .where((type) => entityNames.contains(type.name))
          .toSet(),
      dateFrom: _date(json['dateFrom']),
      dateTo: _date(json['dateTo']),
      projectId: json['projectId'] as int?,
      tags: (json['tags'] as List<Object?>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      sortMode: SearchSortMode.values.firstWhere(
        (mode) => mode.name == json['sortMode'],
        orElse: () => SearchSortMode.relevance,
      ),
    );
  }

  static DateTime? _date(Object? value) => value is int
      ? DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
      : null;
}
