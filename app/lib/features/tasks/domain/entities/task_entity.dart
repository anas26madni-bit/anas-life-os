import 'task_enums.dart';

final class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.uuid,
    required this.title,
    required this.status,
    required this.priority,
    required this.progress,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.version,
    this.description,
    this.projectId,
    this.categoryId,
    this.subcategoryId,
    this.parentTaskId,
    this.sortOrder = 0,
    this.isMandatory = false,
    this.startAt,
    this.dueAt,
    this.completedAt,
    this.deletedAt,
    this.preDeleteStatus,
  });

  final int id;
  final String uuid;
  final String title;
  final String? description;
  final int? projectId;
  final int? categoryId;
  final int? subcategoryId;
  final int? parentTaskId;
  final int sortOrder;
  final bool isMandatory;
  final TaskStatus status;
  final TaskStatus? preDeleteStatus;
  final TaskPriority priority;
  final int progress;
  final DateTime? startAt;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final int version;
}