import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/search_models.dart';
import '../../domain/services/voice_search_service.dart';

final universalSearchControllerProvider =
    AsyncNotifierProvider<UniversalSearchController, UniversalSearchState>(
      UniversalSearchController.new,
    );

final class UniversalSearchState {
  const UniversalSearchState({
    required this.query,
    required this.results,
    required this.recent,
    required this.saved,
    this.voiceUnavailable = false,
  });

  final SearchQuery query;
  final List<SearchResultItem> results;
  final List<RecentSearch> recent;
  final List<SavedSearch> saved;
  final bool voiceUnavailable;

  UniversalSearchState copyWith({
    SearchQuery? query,
    List<SearchResultItem>? results,
    List<RecentSearch>? recent,
    List<SavedSearch>? saved,
    bool? voiceUnavailable,
  }) => UniversalSearchState(
    query: query ?? this.query,
    results: results ?? this.results,
    recent: recent ?? this.recent,
    saved: saved ?? this.saved,
    voiceUnavailable: voiceUnavailable ?? this.voiceUnavailable,
  );
}

class UniversalSearchController extends AsyncNotifier<UniversalSearchState> {
  Timer? _debounce;

  @override
  Future<UniversalSearchState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final repository = await ref.watch(searchRepositoryProvider.future);
    return UniversalSearchState(
      query: const SearchQuery(),
      results: const [],
      recent: _unwrap(await repository.recent()),
      saved: _unwrap(await repository.saved()),
    );
  }

  void scheduleText(String text) {
    final current = state.value;
    if (current == null) return;
    final query = current.query.copyWith(text: text);
    state = AsyncData(current.copyWith(query: query, voiceUnavailable: false));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => execute(query));
  }

  Future<void> execute(SearchQuery query) async {
    _debounce?.cancel();
    final repository = await ref.read(searchRepositoryProvider.future);
    final previous = state.value;
    state = const AsyncLoading<UniversalSearchState>();
    state = await AsyncValue.guard(() async {
      final results = _unwrap(await repository.search(query));
      return UniversalSearchState(
        query: query,
        results: results,
        recent: _unwrap(await repository.recent()),
        saved: previous?.saved ?? _unwrap(await repository.saved()),
      );
    });
  }

  Future<void> saveCurrent(String name) async {
    final current = state.requireValue;
    final repository = await ref.read(searchRepositoryProvider.future);
    _unwrap(
      await repository.save(SavedSearchDraft(name: name, query: current.query)),
    );
    state = AsyncData(
      current.copyWith(saved: _unwrap(await repository.saved())),
    );
  }

  Future<void> deleteSaved(int id) async {
    final current = state.requireValue;
    final repository = await ref.read(searchRepositoryProvider.future);
    _unwrap(await repository.deleteSaved(id));
    state = AsyncData(
      current.copyWith(saved: _unwrap(await repository.saved())),
    );
  }

  Future<void> listen(VoiceSearchLocale locale) async {
    final current = state.requireValue;
    final service = ref.read(voiceSearchServiceProvider);
    final result = await service.listen(locale);
    switch (result) {
      case VoiceSearchTranscript(:final text):
        await execute(current.query.copyWith(text: text));
      case VoiceSearchUnavailable():
        state = AsyncData(current.copyWith(voiceUnavailable: true));
    }
  }

  T _unwrap<T>(Result<T> result) => switch (result) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw SearchOperationException(
      failure.safeMessage,
    ),
  };
}

final class SearchOperationException implements Exception {
  const SearchOperationException(this.message);
  final String message;
  @override
  String toString() => message;
}
