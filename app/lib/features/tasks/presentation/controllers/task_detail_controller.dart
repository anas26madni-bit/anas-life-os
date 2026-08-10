import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_entity.dart';
import 'task_list_controller.dart';

final taskDetailProvider = FutureProvider.family<TaskEntity?, int>((ref, id) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  return _unwrap(await repository.findById(id));
});

final class TaskDetailActions {
  const TaskDetailActions(this.ref);

  final Ref ref;

  Future<void> update(int id, TaskDraft draft) async {
    final repository = await ref.read(taskRepositoryProvider.future);
    _unwrap(await repository.update(id, draft));
    ref.invalidate(taskDetailProvider(id));
    ref.invalidate(taskListControllerProvider);
  }

  Future<void> duplicate(int id) async {
    final repository = await ref.read(taskRepositoryProvider.future);
    _unwrap(await repository.duplicate(id));
    ref.invalidate(taskListControllerProvider);
  }

  Future<void> addTag(int id, String tag) async {
    final repository = await ref.read(taskSupportRepositoryProvider.future);
    _unwrap(await repository.attachTag(taskId: id, name: tag));
  }

  Future<void> addChecklist(int id, String title) async {
    final repository = await ref.read(taskSupportRepositoryProvider.future);
    _unwrap(await repository.createChecklist(taskId: id, title: title));
  }
}

final taskDetailActionsProvider = Provider(TaskDetailActions.new);

T _unwrap<T>(Result<T> result) => switch (result) {
  Success<T>(:final value) => value,
  FailureResult<T>(:final failure) => throw StateError(failure.safeMessage),
};
