import '../../../../core/errors/result.dart';
import '../entities/task_support_drafts.dart';

abstract interface class TaskSupportRepository {
  Future<Result<int>> createCategory(String name, {String? description});

  Future<Result<int>> createSubcategory({
    required int categoryId,
    required String name,
  });

  Future<Result<void>> attachTag({
    required int taskId,
    required String name,
  });

  Future<Result<int>> createChecklist({
    required int taskId,
    required String title,
  });

  Future<Result<int>> addChecklistItem({
    required int checklistId,
    required String title,
  });

  Future<Result<int>> addAttachment(AttachmentDraft draft);

  Future<Result<int>> createRepeatRule(RepeatRuleDraft draft);
}