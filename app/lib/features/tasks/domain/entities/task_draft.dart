import 'task_enums.dart';

final class TaskDraft {
  const TaskDraft({
    required this.title,
    this.description,
    this.projectId,
    this.categoryId,
    this.subcategoryId,
    this.parentTaskId,
    this.sortOrder = 0,
    this.isMandatory = false,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.none,
    this.progress = 0,
    this.startAt,
    this.dueAt,
    this.estimatedMinutes,
    this.energyLevel,
    this.difficulty,
    this.repeatRuleId,
    this.color,
    this.icon,
    this.notes,
  });

  final String title;
  final String? description;
  final int? projectId;
  final int? categoryId;
  final int? subcategoryId;
  final int? parentTaskId;
  final int sortOrder;
  final bool isMandatory;
  final TaskStatus status;
  final TaskPriority priority;
  final int progress;
  final DateTime? startAt;
  final DateTime? dueAt;
  final int? estimatedMinutes;
  final int? energyLevel;
  final int? difficulty;
  final int? repeatRuleId;
  final String? color;
  final String? icon;
  final String? notes;
}