import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/search/data/repositories/drift_search_repository.dart';
import 'package:anas_life_os/features/search/data/services/android_voice_search_service.dart';
import 'package:anas_life_os/features/search/domain/entities/search_models.dart';
import 'package:anas_life_os/features/search/domain/services/voice_search_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/database_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('encrypted search and Android 11 typed fallback work offline', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftSearchRepository(
      await database.verifySearchSession(),
    );
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    await database.customStatement(
      'INSERT INTO search_documents('
      'entity_type,entity_id,title,body,metadata,tag_keys,occurred_at,updated_at) '
      'VALUES (?,?,?,?,?,?,?,?)',
      ['note', 1, 'Offline اردو', 'private local search', '', '', now, now],
    );

    final results =
        (await repository.search(const SearchQuery(text: 'Offline اردو'))
                as Success<List<SearchResultItem>>)
            .value;
    expect(results.single.entityId, 1);

    const voice = AndroidVoiceSearchService();
    expect(
      await voice.listen(VoiceSearchLocale.urdu),
      isA<VoiceSearchUnavailable>(),
    );
    await database.verifyIntegrity();
  });
}
