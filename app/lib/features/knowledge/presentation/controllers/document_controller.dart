import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/knowledge_document.dart';

final documentListControllerProvider =
    AsyncNotifierProvider<DocumentListController, List<KnowledgeDocument>>(
      DocumentListController.new,
    );

final documentDetailProvider = FutureProvider.family<KnowledgeDocument?, int>((
  ref,
  id,
) async {
  final repository = await ref.watch(documentRepositoryProvider.future);
  return _unwrap(await repository.findById(id));
});

class DocumentListController extends AsyncNotifier<List<KnowledgeDocument>> {
  String? _query;

  @override
  Future<List<KnowledgeDocument>> build() async {
    final repository = await ref.watch(documentRepositoryProvider.future);
    return _unwrap(await repository.list(query: _query, limit: 200));
  }

  Future<void> search(String value) async {
    _query = value.trim().isEmpty ? null : value.trim();
    await refresh();
  }

  Future<void> delete(int id) async {
    final repository = await ref.read(documentRepositoryProvider.future);
    _unwrap(await repository.softDelete(id));
    ref.invalidate(documentDetailProvider(id));
    await refresh();
  }

  Future<void> refresh() async => state = await AsyncValue.guard(build);
}

T _unwrap<T>(Result<T> result) => switch (result) {
  Success<T>(:final value) => value,
  FailureResult<T>(:final failure) => throw StateError(failure.safeMessage),
};
