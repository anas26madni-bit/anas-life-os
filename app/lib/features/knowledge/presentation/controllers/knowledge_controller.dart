import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/knowledge_enums.dart';
import '../../domain/entities/knowledge_note.dart';
import '../../domain/repositories/knowledge_repository.dart';

final knowledgeListControllerProvider =
    AsyncNotifierProvider<KnowledgeListController, List<KnowledgeNote>>(
      KnowledgeListController.new,
    );

class KnowledgeListController extends AsyncNotifier<List<KnowledgeNote>> {
  KnowledgeNoteType? _type;
  String? _query;

  @override
  Future<List<KnowledgeNote>> build() async {
    final repository = await ref.watch(knowledgeRepositoryProvider.future);
    _unwrap(await repository.ensureDefaultSpace());
    return _unwrap(await repository.list(type: _type, query: _query));
  }

  Future<void> create({
    required String title,
    required String content,
    required KnowledgeNoteType type,
    required KnowledgeContentFormat format,
  }) async {
    await _mutate((repository) async {
      final spaceId = _unwrap(await repository.ensureDefaultSpace());
      return repository.create(
        KnowledgeNoteDraft(
          spaceId: spaceId,
          title: title,
          content: content,
          type: type,
          format: format,
        ),
      );
    });
  }

  Future<void> setFavorite(int id, bool favorite) async {
    await _mutate((repository) => repository.setFavorite(id, favorite));
  }

  Future<void> delete(int id) async {
    await _mutate((repository) => repository.softDelete(id));
  }

  Future<void> filter(KnowledgeNoteType? type) async {
    _type = type;
    await refresh();
  }

  Future<void> search(String value) async {
    _query = value.trim().isEmpty ? null : value.trim();
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<KnowledgeNote>>();
    state = await AsyncValue.guard(build);
  }

  Future<void> _mutate(
    Future<Result<KnowledgeNote>> Function(KnowledgeRepository repository)
    operation,
  ) async {
    state = const AsyncLoading<List<KnowledgeNote>>();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(knowledgeRepositoryProvider.future);
      _unwrap(await operation(repository));
      return _unwrap(await repository.list(type: _type, query: _query));
    });
  }

  T _unwrap<T>(Result<T> result) => switch (result) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw KnowledgeOperationException(
      failure.safeMessage,
    ),
  };
}

final class KnowledgeOperationException implements Exception {
  const KnowledgeOperationException(this.message);
  final String message;
  @override
  String toString() => message;
}
