import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/search_models.dart';
import '../../domain/repositories/search_repository.dart';
import 'search_query_codec.dart';

final class DriftSearchRepository implements SearchRepository {
  DriftSearchRepository(
    VerifiedSearchDatabaseSession session, {
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _database = session.database,
       _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  @override
  Future<Result<List<SearchResultItem>>> search(SearchQuery query) async {
    final validation = _validate(query);
    if (validation != null) return FailureResult(validation);
    try {
      await _synchronize();
      final built = _buildQuery(query);
      final rows = await _database
          .customSelect(built.sql, variables: built.variables)
          .get();
      final results = rows
          .map(
            (row) => SearchResultItem(
              entityType: SearchEntityType.values.byName(
                row.read<String>('entity_type'),
              ),
              entityId: row.read<int>('entity_id'),
              title: row.read<String>('title'),
              summary: _summary(row.read<String>('body')),
              projectId: row.readNullable<int>('project_id'),
              updatedAt: _date(row.read<int>('updated_at')),
              rank: row.readNullable<double>('rank'),
            ),
          )
          .toList(growable: false);
      await _recordHistory(query, results.length);
      return Success(results);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'search_failed',
          safeMessage: 'Private search results could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> rebuildIndex() async {
    try {
      await _database.transaction(() async {
        await _database.customStatement('DELETE FROM search_documents;');
        await _enqueueAll();
        await _synchronize();
        await _database.customStatement(
          "INSERT INTO search_fts(search_fts) VALUES ('optimize');",
        );
      });
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'search_rebuild_failed',
          safeMessage: 'The encrypted search index could not be rebuilt.',
        ),
      );
    }
  }

  @override
  Future<Result<List<RecentSearch>>> recent({int limit = 10}) async {
    if (limit < 1 || limit > 50) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_recent_search_limit',
          safeMessage: 'The recent-search limit is invalid.',
        ),
      );
    }
    try {
      final rows = await (_database.select(_database.searchHistory)
            ..orderBy([(row) => OrderingTerm.desc(row.searchedAt)])
            ..limit(limit))
          .get();
      return Success(
        rows
            .map(
              (row) => RecentSearch(
                query: SearchQueryCodec.decode(row.queryText, row.filtersJson),
                searchedAt: _date(row.searchedAt),
              ),
            )
            .toList(growable: false),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'recent_search_failed',
          safeMessage: 'Recent searches could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<SavedSearch>> save(SavedSearchDraft draft) async {
    if (draft.name.trim().isEmpty || draft.name.trim().length > 200) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_saved_search_name',
          safeMessage: 'Enter a saved-search name of 200 characters or fewer.',
        ),
      );
    }
    final validation = _validate(draft.query);
    if (validation != null) return FailureResult(validation);
    try {
      final now = _now;
      final id = await _database.into(_database.savedSearches).insert(
            SavedSearchesCompanion.insert(
              uuid: _uuidFactory(),
              name: draft.name.trim(),
              queryText: draft.query.text.trim(),
              filtersJson: SearchQueryCodec.encode(draft.query),
              sortMode: draft.query.sortMode,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return Success(await _savedById(id));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'saved_search_failed',
          safeMessage: 'The saved search could not be stored.',
        ),
      );
    }
  }

  @override
  Future<Result<List<SavedSearch>>> saved() async {
    try {
      final rows = await (_database.select(_database.savedSearches)
            ..where((row) => row.isDeleted.equals(false))
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .get();
      return Success(rows.map(_mapSaved).toList(growable: false));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'saved_search_list_failed',
          safeMessage: 'Saved searches could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteSaved(int id) async {
    try {
      final updated = await (_database.update(
        _database.savedSearches,
      )..where((row) => row.id.equals(id) & row.isDeleted.equals(false))).write(
        SavedSearchesCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(_now),
          updatedAt: Value(_now),
        ),
      );
      if (updated != 1) throw StateError('Saved search does not exist.');
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'saved_search_delete_failed',
          safeMessage: 'The saved search could not be removed.',
        ),
      );
    }
  }

  Future<void> _synchronize() => _database.transaction(() async {
    for (final statement in _projectionStatements) {
      await _database.customStatement(statement);
    }
    await _database.customStatement('DELETE FROM search_index_queue;');
  });

  Future<void> _enqueueAll() async {
    for (final source in const {
      'tasks': 'task',
      'projects': 'project',
      'knowledge_notes': 'note',
      'documents': 'document',
      'attachments': 'attachment',
    }.entries) {
      await _database.customStatement(
        'INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) '
        "SELECT '${source.value}',id FROM ${source.key};",
      );
    }
  }

  _BuiltSearchQuery _buildQuery(SearchQuery query) {
    final variables = <Variable>[];
    final where = <String>[];
    final match = _ftsMatch(query.text);
    final from = match == null
        ? 'FROM search_documents d'
        : 'FROM search_documents d JOIN search_fts ON search_fts.rowid=d.id';
    final rank = match == null
        ? 'NULL AS rank'
        : 'bm25(search_fts,8.0,2.0,1.0,1.5) AS rank';
    if (match != null) {
      where.add('search_fts MATCH ?');
      variables.add(Variable.withString(match));
    }
    if (query.entityTypes.isNotEmpty) {
      where.add(
        'd.entity_type IN (${List.filled(query.entityTypes.length, '?').join(',')})',
      );
      variables.addAll(
        query.entityTypes.map((type) => Variable.withString(type.name)),
      );
    }
    if (query.dateFrom != null) {
      where.add('d.occurred_at>=?');
      variables.add(Variable.withInt(_micros(query.dateFrom!)));
    }
    if (query.dateTo != null) {
      where.add('d.occurred_at<?');
      variables.add(Variable.withInt(_micros(query.dateTo!)));
    }
    if (query.projectId != null) {
      where.add('d.project_id=?');
      variables.add(Variable.withInt(query.projectId!));
    }
    for (final tag in _normalizedTags(query.tags)) {
      where.add("instr(d.tag_keys,?)>0");
      variables.add(Variable.withString('|$tag|'));
    }
    final order = switch (query.sortMode) {
      SearchSortMode.relevance when match != null =>
        'rank ASC,d.updated_at DESC,d.entity_type ASC,d.entity_id ASC',
      SearchSortMode.oldest =>
        'd.updated_at ASC,d.entity_type ASC,d.entity_id ASC',
      SearchSortMode.title =>
        'd.title COLLATE NOCASE ASC,d.entity_type ASC,d.entity_id ASC',
      _ => 'd.updated_at DESC,d.entity_type ASC,d.entity_id ASC',
    };
    variables
      ..add(Variable.withInt(query.limit))
      ..add(Variable.withInt(query.offset));
    return _BuiltSearchQuery(
      'SELECT d.entity_type,d.entity_id,d.title,d.body,d.project_id,'
      'd.updated_at,$rank $from '
      '${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')} '} '
      'ORDER BY $order LIMIT ? OFFSET ?',
      variables,
    );
  }

  Future<void> _recordHistory(SearchQuery query, int count) async {
    await _database.into(_database.searchHistory).insert(
          SearchHistoryCompanion.insert(
            queryText: query.text.trim(),
            filtersJson: SearchQueryCodec.encode(query),
            searchedAt: _now,
            resultCount: count,
          ),
        );
  }

  Future<SavedSearch> _savedById(int id) async => _mapSaved(
    await (_database.select(
      _database.savedSearches,
    )..where((row) => row.id.equals(id))).getSingle(),
  );

  SavedSearch _mapSaved(SavedSearchRow row) => SavedSearch(
    id: row.id,
    uuid: row.uuid,
    name: row.name,
    query: SearchQueryCodec.decode(row.queryText, row.filtersJson),
    createdAt: _date(row.createdAt),
    updatedAt: _date(row.updatedAt),
  );

  ValidationFailure? _validate(SearchQuery query) {
    if (query.text.length > 500 || query.limit < 1 || query.limit > 200) {
      return const ValidationFailure(
        code: 'invalid_search_query',
        safeMessage: 'The search request is invalid.',
      );
    }
    if (query.offset < 0 ||
        (query.dateFrom != null &&
            query.dateTo != null &&
            !query.dateTo!.isAfter(query.dateFrom!))) {
      return const ValidationFailure(
        code: 'invalid_search_filter',
        safeMessage: 'The search filters are invalid.',
      );
    }
    if (_normalizedTags(query.tags).length != query.tags.length) {
      return const ValidationFailure(
        code: 'invalid_search_tags',
        safeMessage: 'Search tags must be unique and non-empty.',
      );
    }
    return null;
  }

  String? _ftsMatch(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'["*:^()\[\]{}]'), ' ')
        .trim();
    final tokens = sanitized
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .take(20)
        .toList(growable: false);
    if (tokens.isEmpty) return null;
    return tokens.map((token) => '"$token"*').join(' AND ');
  }

  List<String> _normalizedTags(List<String> tags) => tags
      .map((tag) => tag.trim().toLowerCase())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList(growable: false);

  String? _summary(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) return null;
    return normalized.length <= 160
        ? normalized
        : '${normalized.substring(0, 157)}...';
  }

  int get _now => _micros(_clock());
  int _micros(DateTime value) => value.toUtc().microsecondsSinceEpoch;
  DateTime _date(int value) =>
      DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
}

final class _BuiltSearchQuery {
  const _BuiltSearchQuery(this.sql, this.variables);
  final String sql;
  final List<Variable> variables;
}

const _projectionStatements = <String>[
  "DELETE FROM search_documents WHERE entity_type='task' AND entity_id IN (SELECT entity_id FROM search_index_queue WHERE entity_type='task')",
  "INSERT INTO search_documents(entity_type,entity_id,title,body,metadata,tag_keys,project_id,occurred_at,updated_at) SELECT 'task',t.id,t.title,coalesce(t.description,''),t.status||' '||t.priority,coalesce('|'||(SELECT group_concat(lower(g.name),'|') FROM task_tags x JOIN tags g ON g.id=x.tag_id WHERE x.task_id=t.id)||'|',''),t.project_id,coalesce(t.due_at,t.completed_at,t.updated_at),t.updated_at FROM tasks t JOIN search_index_queue q ON q.entity_type='task' AND q.entity_id=t.id WHERE t.is_deleted=0 AND t.status<>'deleted'",
  "DELETE FROM search_documents WHERE entity_type='project' AND entity_id IN (SELECT entity_id FROM search_index_queue WHERE entity_type='project')",
  "INSERT INTO search_documents(entity_type,entity_id,title,body,metadata,tag_keys,project_id,occurred_at,updated_at) SELECT 'project',p.id,p.title,coalesce(p.description,''),p.status,'',p.id,coalesce(p.due_at,p.updated_at),p.updated_at FROM projects p JOIN search_index_queue q ON q.entity_type='project' AND q.entity_id=p.id WHERE p.is_deleted=0",
  "DELETE FROM search_documents WHERE entity_type='note' AND entity_id IN (SELECT entity_id FROM search_index_queue WHERE entity_type='note')",
  "INSERT INTO search_documents(entity_type,entity_id,title,body,metadata,tag_keys,project_id,occurred_at,updated_at) SELECT 'note',n.id,n.title,n.content,coalesce(n.summary,'')||' '||n.note_type,coalesce('|'||(SELECT group_concat(lower(g.name),'|') FROM knowledge_note_tags x JOIN knowledge_tags g ON g.id=x.tag_id WHERE x.note_id=n.id)||'|',''),n.project_id,n.updated_at,n.updated_at FROM knowledge_notes n JOIN search_index_queue q ON q.entity_type='note' AND q.entity_id=n.id WHERE n.is_deleted=0",
  "DELETE FROM search_documents WHERE entity_type='document' AND entity_id IN (SELECT entity_id FROM search_index_queue WHERE entity_type='document')",
  "INSERT INTO search_documents(entity_type,entity_id,title,body,metadata,tag_keys,project_id,occurred_at,updated_at) SELECT 'document',d.id,d.title,coalesce(d.description,''),coalesce((SELECT group_concat(m.metadata_key||' '||m.metadata_value,' ') FROM document_metadata m WHERE m.document_id=d.id),''),'',NULL,d.updated_at,d.updated_at FROM documents d JOIN search_index_queue q ON q.entity_type='document' AND q.entity_id=d.id WHERE d.is_deleted=0 AND d.hidden=0",
  "DELETE FROM search_documents WHERE entity_type='attachment' AND entity_id IN (SELECT entity_id FROM search_index_queue WHERE entity_type='attachment')",
  "INSERT INTO search_documents(entity_type,entity_id,title,body,metadata,tag_keys,project_id,occurred_at,updated_at) SELECT 'attachment',a.id,a.file_name,coalesce(a.original_file_name,''),coalesce(a.extension,'')||' '||coalesce(a.mime_type,''),coalesce('|'||(SELECT group_concat(lower(l.name),'|') FROM attachment_label_map x JOIN attachment_labels l ON l.id=x.label_id WHERE x.attachment_id=a.id)||'|',''),a.project_id,a.created_at,a.updated_at FROM attachments a JOIN search_index_queue q ON q.entity_type='attachment' AND q.entity_id=a.id WHERE a.is_deleted=0 AND a.is_hidden=0",
];
