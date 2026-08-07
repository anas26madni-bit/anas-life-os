import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';
import 'package:anas_life_os/features/search/data/repositories/drift_search_repository.dart';
import 'package:anas_life_os/features/search/domain/entities/search_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('search requires and uses a verified encrypted database session', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    final session = await database.verifySearchSession();
    final repository = DriftSearchRepository(
      session,
      clock: () => DateTime.utc(2026, 8, 7),
      uuidFactory: () => '00000000-0000-4000-8000-000000000007',
    );
    await _seedSearchDocuments(database);

    final mixed = (await repository.search(
      const SearchQuery(text: 'budget بجٹ'),
    ) as Success<List<SearchResultItem>>)
        .value;
    expect(mixed.map((item) => item.title), ['Budget بجٹ plan']);

    final filtered = (await repository.search(
      const SearchQuery(
        text: 'offline',
        entityTypes: {SearchEntityType.task},
        projectId: 7,
        tags: ['private'],
      ),
    ) as Success<List<SearchResultItem>>)
        .value;
    expect(filtered.single.entityId, 11);

    final saved = (await repository.save(
      const SavedSearchDraft(
        name: 'Private work',
        query: SearchQuery(text: 'offline', tags: ['private']),
      ),
    ) as Success<SavedSearch>)
        .value;
    expect(saved.query.tags, ['private']);
    expect((await repository.saved() as Success<List<SavedSearch>>).value, hasLength(1));
    expect((await repository.recent() as Success<List<RecentSearch>>).value, hasLength(2));

    await repository.deleteSaved(saved.id);
    expect((await repository.saved() as Success<List<SavedSearch>>).value, isEmpty);
  });

  test('hidden and deleted source content never enters the index', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftSearchRepository(await database.verifySearchSession());
    final now = DateTime.utc(2026, 8, 7).microsecondsSinceEpoch;
    await database.customStatement(
      'INSERT INTO documents(uuid,created_at,updated_at,title,description,hidden) '
      'VALUES (?,?,?,?,?,?)',
      ['00000000-0000-4000-8000-000000000001', now, now, 'Visible', 'allowed token', 0],
    );
    await database.customStatement(
      'INSERT INTO documents(uuid,created_at,updated_at,title,description,hidden) '
      'VALUES (?,?,?,?,?,?)',
      ['00000000-0000-4000-8000-000000000002', now, now, 'Hidden', 'secret token', 1],
    );

    final allowed = (await repository.search(
      const SearchQuery(text: 'token'),
    ) as Success<List<SearchResultItem>>)
        .value;
    expect(allowed.map((item) => item.title), ['Visible']);

    final indexed = await database.customSelect(
      "SELECT count(*) AS count FROM search_documents WHERE title='Hidden'",
    ).getSingle();
    expect(indexed.read<int>('count'), 0);
  });

  test('100,000 mixed-language records search within 300 ms p95', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftSearchRepository(await database.verifySearchSession());
    final now = DateTime.utc(2026, 8, 7).microsecondsSinceEpoch;
    await database.customStatement(
      'WITH RECURSIVE records(value) AS '
      '(SELECT 1 UNION ALL SELECT value+1 FROM records WHERE value<100000) '
      'INSERT INTO search_documents('
      'entity_type,entity_id,title,body,metadata,tag_keys,occurred_at,updated_at) '
      "SELECT 'note',value,CASE WHEN value%1000=0 THEN 'needle خاص '||value "
      "ELSE 'English اردو '||value END,'offline local knowledge','','',?,? FROM records",
      [now, now],
    );
    await repository.search(const SearchQuery(text: 'needle خاص'));

    final samples = <int>[];
    for (var index = 0; index < 20; index++) {
      final stopwatch = Stopwatch()..start();
      final result = await repository.search(const SearchQuery(text: 'needle خاص'));
      stopwatch.stop();
      expect(result, isA<Success<List<SearchResultItem>>>());
      samples.add(stopwatch.elapsedMilliseconds);
    }
    samples.sort();
    expect(samples[18], lessThan(300));
  }, timeout: const Timeout(Duration(minutes: 2)));
}

Future<void> _seedSearchDocuments(AppDatabase database) async {
  final now = DateTime.utc(2026, 8, 7).microsecondsSinceEpoch;
  await database.customStatement(
    'INSERT INTO search_documents('
    'entity_type,entity_id,title,body,metadata,tag_keys,project_id,occurred_at,updated_at) '
    'VALUES (?,?,?,?,?,?,?,?,?)',
    ['task', 11, 'Offline task', 'private work', '', '|private|', 7, now, now],
  );
  await database.customStatement(
    'INSERT INTO search_documents('
    'entity_type,entity_id,title,body,metadata,tag_keys,occurred_at,updated_at) '
    'VALUES (?,?,?,?,?,?,?,?)',
    ['project', 12, 'Budget بجٹ plan', 'budget بجٹ details', '', '', now, now],
  );
}
