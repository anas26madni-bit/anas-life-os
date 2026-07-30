import 'package:drift/drift.dart';

import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/task_enums.dart';

final class TaskRepositorySupport {
  const TaskRepositorySupport(
    this._database, {
    required String Function() uuidFactory,
  }) : _uuidFactory = uuidFactory;

  final AppDatabase _database;
  final String Function() _uuidFactory;

  Future<void> validateParent(int? parentId, {int? taskId}) async {
    if (parentId == null) return;
    if (parentId == taskId) {
      throw StateError('A task cannot be its own parent.');
    }
    var depth = 1;
    var current = await requireRaw(parentId, includeDeleted: false);
    final visited = <int>{parentId};
    while (current.parentTaskId != null) {
      if (current.parentTaskId == taskId ||
          !visited.add(current.parentTaskId!)) {
        throw StateError('The task hierarchy would contain a cycle.');
      }
      depth += 1;
      if (depth > 8) {
        throw StateError('Task nesting cannot exceed eight levels.');
      }
      current = await requireRaw(
        current.parentTaskId!,
        includeDeleted: false,
      );
    }
  }

  Future<void> validateMandatoryChildren(int id) async {
    final query = _database.select(_database.tasks)
      ..where(
        (row) =>
            row.parentTaskId.equals(id) &
            row.isMandatory.equals(true) &
            row.isDeleted.equals(false),
      );
    final children = await query.get();
    if (children.any((child) => child.status != TaskStatus.completed)) {
      throw StateError(
        'Complete all mandatory subtasks before completing this task.',
      );
    }
  }

  Future<void> validateDependencies(int taskId, TaskStatus next) async {
    final starts =
        next == TaskStatus.inProgress || next == TaskStatus.completed;
    final finishes = next == TaskStatus.completed;
    if (!starts && !finishes) return;

    final dependencies = await (_database.select(_database.taskDependencies)
          ..where((row) => row.taskId.equals(taskId)))
        .get();
    for (final dependency in dependencies) {
      final predecessor = await requireRaw(
        dependency.dependsOnTaskId,
        includeDeleted: true,
      );
      if (predecessor.isDeleted) continue;
      final predecessorStarted =
          predecessor.status == TaskStatus.inProgress ||
          predecessor.status == TaskStatus.completed;
      final predecessorFinished = predecessor.status == TaskStatus.completed;
      final allowed = switch (dependency.dependencyType) {
        DependencyType.finishToStart => !starts || predecessorFinished,
        DependencyType.startToStart => !starts || predecessorStarted,
        DependencyType.finishToFinish => !finishes || predecessorFinished,
        DependencyType.startToFinish => !finishes || predecessorStarted,
      };
      if (!allowed) {
        throw StateError('A required task dependency is not satisfied.');
      }
    }
  }

  Future<bool> createsDependencyCycle(
    int taskId,
    int dependsOnTaskId,
  ) async {
    final activeTasks = await (_database.select(_database.tasks)
          ..where((row) => row.isDeleted.equals(false)))
        .get();
    final activeIds = activeTasks.map((task) => task.id).toSet();
    final edges = await _database.select(_database.taskDependencies).get();
    final graph = <int, List<int>>{};
    for (final edge in edges) {
      if (activeIds.contains(edge.taskId) &&
          activeIds.contains(edge.dependsOnTaskId)) {
        graph.putIfAbsent(edge.taskId, () => <int>[]).add(
          edge.dependsOnTaskId,
        );
      }
    }
    final pending = <int>[dependsOnTaskId];
    final visited = <int>{};
    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      if (current == taskId) return true;
      if (visited.add(current)) {
        pending.addAll(graph[current] ?? const <int>[]);
      }
    }
    return false;
  }

  Future<void> softDeleteTree(
    TaskRow task,
    DateTime now,
    String? reason,
  ) async {
    final children = await (_database.select(_database.tasks)
          ..where(
            (row) =>
                row.parentTaskId.equals(task.id) & row.isDeleted.equals(false),
          ))
        .get();
    for (final child in children) {
      await softDeleteTree(child, now, 'ancestor_deleted');
    }
    await (_database.update(_database.tasks)
          ..where((row) => row.id.equals(task.id)))
        .write(
          TasksCompanion(
            status: const Value(TaskStatus.deleted),
            preDeleteStatus: Value(task.status),
            isDeleted: const Value(true),
            deletedAt: Value(now.microsecondsSinceEpoch),
            updatedAt: Value(now.microsecondsSinceEpoch),
            version: Value(task.version + 1),
          ),
        );
    await recordState(
      task.id,
      task.status,
      TaskStatus.deleted,
      now,
      reason ?? 'deleted',
    );
  }

  Future<void> refreshParentCount(int? parentId, DateTime now) async {
    if (parentId == null) return;
    final count = _database.tasks.id.count();
    final query = _database.selectOnly(_database.tasks)
      ..addColumns([count])
      ..where(
        _database.tasks.parentTaskId.equals(parentId) &
            _database.tasks.isDeleted.equals(false),
      );
    final value = (await query.getSingle()).read(count) ?? 0;
    await (_database.update(_database.tasks)
          ..where((row) => row.id.equals(parentId)))
        .write(
          TasksCompanion(
            subtaskCount: Value(value),
            updatedAt: Value(now.microsecondsSinceEpoch),
          ),
        );
  }

  Future<TaskRow> requireRaw(
    int id, {
    required bool includeDeleted,
  }) async {
    final query = _database.select(_database.tasks)
      ..where((row) => row.id.equals(id));
    if (!includeDeleted) {
      query.where((row) => row.isDeleted.equals(false));
    }
    final row = await query.getSingleOrNull();
    if (row == null) throw StateError('The task does not exist.');
    return row;
  }

  Future<void> recordMutation({
    required int taskId,
    required String action,
    required DateTime at,
    String? changedField,
    String? oldValue,
    String? newValue,
  }) async {
    await _database.into(_database.taskHistory).insert(
      TaskHistoryCompanion.insert(
        uuid: _uuidFactory(),
        taskId: taskId,
        action: action,
        changedField: Value(changedField),
        oldValue: Value(oldValue),
        newValue: Value(newValue),
        changedAt: at.microsecondsSinceEpoch,
        createdAt: at.microsecondsSinceEpoch,
      ),
    );
  }
  Future<void> recordState(
    int taskId,
    TaskStatus? previous,
    TaskStatus next,
    DateTime at,
    String? reason,
  ) async {
    await _database.into(_database.taskHistory).insert(
      TaskHistoryCompanion.insert(
        uuid: _uuidFactory(),
        taskId: taskId,
        action: previous == null ? 'create' : 'state_change',
        changedField: const Value('status'),
        oldValue: Value(previous?.name),
        newValue: Value(next.name),
        changedAt: at.microsecondsSinceEpoch,
        createdAt: at.microsecondsSinceEpoch,
      ),
    );
    await _database.into(_database.taskStateHistory).insert(
      TaskStateHistoryCompanion.insert(
        uuid: _uuidFactory(),
        taskId: taskId,
        previousState: Value(previous),
        newState: next,
        reason: Value(reason?.trim()),
        changedAt: at.microsecondsSinceEpoch,
        createdAt: at.microsecondsSinceEpoch,
      ),
    );
  }
}
