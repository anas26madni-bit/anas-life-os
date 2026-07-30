import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/task_draft.dart';
import '../entities/task_enums.dart';

final class TaskValidator {
  const TaskValidator();

  Result<TaskDraft> validate(TaskDraft draft) {
    final title = draft.title.trim();
    if (title.isEmpty || title.runes.length > 300) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_task_title',
          safeMessage: 'Task title must contain between 1 and 300 characters.',
        ),
      );
    }
    if (draft.progress < 0 || draft.progress > 100) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_task_progress',
          safeMessage: 'Task progress must be between 0 and 100.',
        ),
      );
    }
    if (draft.startAt != null &&
        draft.dueAt != null &&
        draft.dueAt!.isBefore(draft.startAt!)) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_task_dates',
          safeMessage: 'Task due time cannot be before its start time.',
        ),
      );
    }
    if ((draft.estimatedMinutes ?? 0) < 0 ||
        (draft.energyLevel ?? 0) < 0 ||
        (draft.energyLevel ?? 0) > 5 ||
        (draft.difficulty ?? 0) < 0 ||
        (draft.difficulty ?? 0) > 5) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_task_effort',
          safeMessage: 'Task effort values are outside the supported range.',
        ),
      );
    }
    if (draft.parentTaskId == null && draft.isMandatory) {
      return const FailureResult(
        ValidationFailure(
          code: 'mandatory_root_task',
          safeMessage: 'Only a subtask can be marked mandatory.',
        ),
      );
    }
    final normalizedProgress = draft.status == TaskStatus.completed
        ? 100
        : draft.progress;
    return Success(
      TaskDraft(
        title: title,
        description: draft.description?.trim(),
        projectId: draft.projectId,
        categoryId: draft.categoryId,
        subcategoryId: draft.subcategoryId,
        parentTaskId: draft.parentTaskId,
        sortOrder: draft.sortOrder,
        isMandatory: draft.isMandatory,
        status: draft.status,
        priority: draft.priority,
        progress: normalizedProgress,
        startAt: draft.startAt?.toUtc(),
        dueAt: draft.dueAt?.toUtc(),
        estimatedMinutes: draft.estimatedMinutes,
        energyLevel: draft.energyLevel,
        difficulty: draft.difficulty,
        repeatRuleId: draft.repeatRuleId,
        color: draft.color,
        icon: draft.icon,
        notes: draft.notes,
      ),
    );
  }
}