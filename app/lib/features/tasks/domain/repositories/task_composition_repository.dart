import '../../../../core/errors/result.dart';
import '../entities/task_draft.dart';
import '../entities/task_entity.dart';

abstract interface class TaskCompositionRepository {
  Future<Result<TaskEntity>> clone(int sourceId);

  Future<Result<TaskEntity>> move(int taskId, {required int? projectId});

  Future<Result<TaskEntity>> merge({
    required List<int> sourceIds,
    required TaskDraft mergedTask,
  });

  Future<Result<List<TaskEntity>>> split({
    required int sourceId,
    required List<TaskDraft> parts,
  });
}
