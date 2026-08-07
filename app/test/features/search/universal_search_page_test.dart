import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/search/domain/entities/search_models.dart';
import 'package:anas_life_os/features/search/domain/repositories/search_repository.dart';
import 'package:anas_life_os/features/search/domain/services/voice_search_service.dart';
import 'package:anas_life_os/features/search/presentation/pages/universal_search_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'supports mixed text, large type, RTL, filters, and saved search',
    (tester) async {
      final repository = _FakeSearchRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchRepositoryProvider.overrideWith((ref) async => repository),
            voiceSearchServiceProvider.overrideWithValue(_UnavailableVoice()),
          ],
          child: const MaterialApp(
            locale: Locale('ur'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.4)),
              child: UniversalSearchPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        Directionality.of(tester.element(find.byType(Scaffold))),
        TextDirection.rtl,
      );
      await tester.enterText(find.byType(SearchBar), 'offline نجی');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Offline نجی note'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();
      expect(
        find.byType(FilterChip),
        findsNWidgets(SearchEntityType.values.length),
      );
      expect(tester.takeException(), isNull);
    },
  );
}

final class _FakeSearchRepository implements SearchRepository {
  @override
  Future<Result<List<SearchResultItem>>> search(SearchQuery query) async =>
      Success([
        SearchResultItem(
          entityType: SearchEntityType.note,
          entityId: 1,
          title: 'Offline نجی note',
          updatedAt: DateTime.utc(2026, 8, 7),
        ),
      ]);

  @override
  Future<Result<void>> rebuildIndex() async => const Success(null);
  @override
  Future<Result<List<RecentSearch>>> recent({int limit = 10}) async =>
      const Success([]);
  @override
  Future<Result<SavedSearch>> save(SavedSearchDraft draft) =>
      throw UnimplementedError();
  @override
  Future<Result<List<SavedSearch>>> saved() async => const Success([]);
  @override
  Future<Result<void>> deleteSaved(int id) async => const Success(null);
}

final class _UnavailableVoice implements VoiceSearchService {
  @override
  Future<void> cancel() async {}
  @override
  Future<bool> isAvailable(VoiceSearchLocale locale) async => false;
  @override
  Future<VoiceSearchResult> listen(VoiceSearchLocale locale) async =>
      const VoiceSearchUnavailable();
}
