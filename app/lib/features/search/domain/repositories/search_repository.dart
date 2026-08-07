import '../../../../core/errors/result.dart';
import '../entities/search_models.dart';

abstract interface class SearchRepository {
  Future<Result<List<SearchResultItem>>> search(SearchQuery query);
  Future<Result<void>> rebuildIndex();
  Future<Result<List<RecentSearch>>> recent({int limit = 10});
  Future<Result<SavedSearch>> save(SavedSearchDraft draft);
  Future<Result<List<SavedSearch>>> saved();
  Future<Result<void>> deleteSaved(int id);
}
