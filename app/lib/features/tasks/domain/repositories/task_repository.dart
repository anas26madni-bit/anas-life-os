import '../../../../core/errors/result.dart';
import '../entities/task_draft.dart';
import '../entities/task_entity.dart';
import '../entities/task_enums.dart';

abstract interface class TaskRepository {
  Future<Result<TaskEntity>> create(TaskDraft draft);
  Future<Result<TaskEntity>> update(int id, TaskDraft draft);
  Future<Result<TaskEntity?>> findById(int id, {bool includeDeleted = false});
  Future<Result<List<TaskEntity>>> list({
    int limit = 50,
    int offset = 0,
    bool includeDeleted = false,
  });
  Future<Result<TaskEntity>> changeStatus(
    int id,
    TaskStatus status, {
    String? reason,
  });
  Future<Result<TaskEntity>> archive(int id, {String? reason});
  Future<Result<TaskEntity>> softDelete(int id, {String? reason});
  Future<Result<TaskEntity>> restore(int id, {String? reason});
  Future<Result<TaskEntity>> duplicate(int id);
  Future<Result<void>> addDependency({
    required int taskId,
    required int dependsOnTaskId,
    required DependencyType type,
  });
}
