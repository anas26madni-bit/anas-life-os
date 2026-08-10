import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';

final projectListControllerProvider =
    AsyncNotifierProvider<ProjectListController, List<ProjectEntity>>(
      ProjectListController.new,
    );

final projectDetailProvider = FutureProvider.family<ProjectEntity?, int>((
  ref,
  id,
) async {
  final repository = await ref.watch(projectRepositoryProvider.future);
  return _unwrap(await repository.findById(id));
});

class ProjectListController extends AsyncNotifier<List<ProjectEntity>> {
  @override
  Future<List<ProjectEntity>> build() async {
    final repository = await ref.watch(projectRepositoryProvider.future);
    return _unwrap(await repository.list(limit: 200));
  }

  Future<void> create({
    required String title,
    String? description,
    DateTime? dueAt,
  }) => _mutate(
    (repository) =>
        repository.create(title: title, description: description, dueAt: dueAt),
  );

  Future<void> updateProject(
    int id, {
    required String title,
    String? description,
    int? budgetMinor,
    String? currencyCode,
    DateTime? dueAt,
  }) => _mutate(
    (repository) => repository.update(
      id,
      title: title,
      description: description,
      budgetMinor: budgetMinor,
      currencyCode: currencyCode,
      dueAt: dueAt,
    ),
    detailId: id,
  );

  Future<void> archive(int id) =>
      _mutate((repository) => repository.archive(id), detailId: id);

  Future<void> delete(int id) =>
      _mutate((repository) => repository.softDelete(id), detailId: id);

  Future<void> refresh() async => state = await AsyncValue.guard(build);

  Future<void> _mutate<T>(
    Future<Result<T>> Function(ProjectRepository repository) operation, {
    int? detailId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(projectRepositoryProvider.future);
      _unwrap(await operation(repository));
      if (detailId != null) ref.invalidate(projectDetailProvider(detailId));
      return _unwrap(await repository.list(limit: 200));
    });
  }
}

T _unwrap<T>(Result<T> result) => switch (result) {
  Success<T>(:final value) => value,
  FailureResult<T>(:final failure) => throw StateError(failure.safeMessage),
};
