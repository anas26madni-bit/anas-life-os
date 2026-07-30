import '../../../../core/errors/result.dart';
import '../entities/task_draft.dart';
import '../entities/task_entity.dart';
import '../entities/task_enums.dart';
import '../repositories/task_repository.dart';

final class TaskUseCases {
  const TaskUseCases(this._repository);

  final TaskRepository _repository;

  Future<Result<List<TaskEntity>>> list({int limit = 50, int offset = 0}) {
    return _repository.list(limit: limit, offset: offset);
  }

  Future<Result<TaskEntity>> create(TaskDraft draft) {
    return _repository.create(draft);
  }

  Future<Result<TaskEntity>> update(int id, TaskDraft draft) {
    return _repository.update(id, draft);
  }

  Future<Result<TaskEntity>> complete(int id) {
    return _repository.changeStatus(id, TaskStatus.completed);
  }

  Future<Result<TaskEntity>> archive(int id) {
    return _repository.archive(id);
  }

  Future<Result<TaskEntity>> delete(int id) {
    return _repository.softDelete(id);
  }
}
