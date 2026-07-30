import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task_use_cases.dart';

final taskUseCasesProvider = FutureProvider<TaskUseCases>((ref) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  return TaskUseCases(repository);
});

final taskListControllerProvider =
    AsyncNotifierProvider<TaskListController, List<TaskEntity>>(
      TaskListController.new,
    );

class TaskListController extends AsyncNotifier<List<TaskEntity>> {
  @override
  Future<List<TaskEntity>> build() async {
    final useCases = await ref.watch(taskUseCasesProvider.future);
    return _unwrap(await useCases.list());
  }

  Future<void> create(TaskDraft draft) async {
    await _mutate((useCases) => useCases.create(draft));
  }

  Future<void> complete(int id) async {
    await _mutate((useCases) => useCases.complete(id));
  }

  Future<void> archive(int id) async {
    await _mutate((useCases) => useCases.archive(id));
  }

  Future<void> delete(int id) async {
    await _mutate((useCases) => useCases.delete(id));
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<TaskEntity>>();
    state = await AsyncValue.guard(build);
  }

  Future<void> _mutate(
    Future<Result<TaskEntity>> Function(TaskUseCases useCases) operation,
  ) async {
    final previous = state;
    state = const AsyncLoading<List<TaskEntity>>().copyWithPrevious(previous);
    state = await AsyncValue.guard(() async {
      final useCases = await ref.read(taskUseCasesProvider.future);
      _unwrap(await operation(useCases));
      return _unwrap(await useCases.list());
    });
  }

  T _unwrap<T>(Result<T> result) => switch (result) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw TaskOperationException(
      failure.safeMessage,
    ),
  };
}

final class TaskOperationException implements Exception {
  const TaskOperationException(this.message);

  final String message;

  @override
  String toString() => message;
}
