import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_composition_repository.dart';
import 'drift_task_repository.dart';
import 'task_repository_support.dart';

final class DriftTaskCompositionRepository
    implements TaskCompositionRepository {
  DriftTaskCompositionRepository(
    this._database, {
    DriftTaskRepository? tasks,
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _tasks = tasks ?? DriftTaskRepository(_database),
       _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final DriftTaskRepository _tasks;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  TaskRepositorySupport get _support =>
      TaskRepositorySupport(_database, uuidFactory: _uuidFactory);

  @override
  Future<Result<TaskEntity>> clone(int sourceId) async {
    try {
      return await _database.transaction(() async {
        return Success(await _cloneNode(sourceId, null, true));
      });
    } on _CompositionRejected catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'task_clone_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_clone_failed',
          safeMessage: 'The task could not be cloned safely.',
        ),
      );
    }
  }

  Future<TaskEntity> _cloneNode(
    int sourceId,
    int? parentId,
    bool isRoot,
  ) async {
    final source = _unwrap(
      await _tasks.findById(sourceId),
      'The source task does not exist.',
    );
    if (source == null) {
      throw const _CompositionRejected('The source task does not exist.');
    }
    final created = _unwrap(
      await _tasks.create(
        TaskDraft(
          title: source.title,
          description: source.description,
          projectId: source.projectId,
          categoryId: source.categoryId,
          subcategoryId: source.subcategoryId,
          parentTaskId: isRoot ? null : parentId,
          sortOrder: source.sortOrder,
          isMandatory: isRoot ? false : source.isMandatory,
          status: TaskStatus.pending,
          priority: source.priority,
          progress: 0,
          startAt: source.startAt,
          dueAt: source.dueAt,
        ),
      ),
      'The cloned task could not be created.',
    );
    final children =
        await (_database.select(_database.tasks)
              ..where(
                (row) =>
                    row.parentTaskId.equals(sourceId) &
                    row.isDeleted.equals(false),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
            .get();
    for (final child in children) {
      await _cloneNode(child.id, created.id, false);
    }
    return created;
  }

  @override
  Future<Result<TaskEntity>> move(int taskId, {required int? projectId}) async {
    try {
      return await _database.transaction(() async {
        if (projectId != null) {
          final project =
              await (_database.select(_database.projects)..where(
                    (row) =>
                        row.id.equals(projectId) & row.isDeleted.equals(false),
                  ))
                  .getSingleOrNull();
          if (project == null) {
            throw const _CompositionRejected(
              'The destination project does not exist.',
            );
          }
        }
        final root =
            await (_database.select(_database.tasks)..where(
                  (row) => row.id.equals(taskId) & row.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        if (root == null) {
          throw const _CompositionRejected('The task does not exist.');
        }
        final ids = await _subtreeIds(taskId);
        final now = _clock().toUtc();
        final rows = await (_database.select(
          _database.tasks,
        )..where((row) => row.id.isIn(ids))).get();
        for (final row in rows) {
          await (_database.update(
            _database.tasks,
          )..where((candidate) => candidate.id.equals(row.id))).write(
            TasksCompanion(
              projectId: Value(projectId),
              updatedAt: Value(now.microsecondsSinceEpoch),
              version: Value(row.version + 1),
            ),
          );
          await _support.recordMutation(
            taskId: row.id,
            action: 'move',
            changedField: 'project_id',
            oldValue: row.projectId?.toString(),
            newValue: projectId?.toString(),
            at: now,
          );
        }
        return Success(
          _unwrap(
            await _tasks.findById(taskId),
            'The moved task could not be loaded.',
          )!,
        );
      });
    } on _CompositionRejected catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'task_move_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_move_failed',
          safeMessage: 'The task could not be moved safely.',
        ),
      );
    }
  }

  @override
  Future<Result<TaskEntity>> merge({
    required List<int> sourceIds,
    required TaskDraft mergedTask,
  }) async {
    final ids = sourceIds.toSet().toList(growable: false);
    if (ids.length < 2) {
      return const FailureResult(
        ValidationFailure(
          code: 'task_merge_requires_multiple_sources',
          safeMessage: 'Select at least two different tasks to merge.',
        ),
      );
    }
    try {
      return await _database.transaction(() async {
        for (final id in ids) {
          final source = _unwrap(
            await _tasks.findById(id),
            'A source task does not exist.',
          );
          if (source == null) {
            throw const _CompositionRejected('A source task does not exist.');
          }
        }
        final merged = _unwrap(
          await _tasks.create(mergedTask),
          'The merged task is invalid.',
        );
        for (final id in ids) {
          _unwrap(
            await _tasks.archive(id, reason: 'merged_into_${merged.id}'),
            'A source task could not be archived.',
          );
        }
        return Success(merged);
      });
    } on _CompositionRejected catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'task_merge_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_merge_failed',
          safeMessage: 'The tasks could not be merged safely.',
        ),
      );
    }
  }

  @override
  Future<Result<List<TaskEntity>>> split({
    required int sourceId,
    required List<TaskDraft> parts,
  }) async {
    if (parts.length < 2) {
      return const FailureResult(
        ValidationFailure(
          code: 'task_split_requires_multiple_parts',
          safeMessage: 'Create at least two task parts.',
        ),
      );
    }
    try {
      return await _database.transaction(() async {
        final source = _unwrap(
          await _tasks.findById(sourceId),
          'The source task does not exist.',
        );
        if (source == null) {
          throw const _CompositionRejected('The source task does not exist.');
        }
        final created = <TaskEntity>[];
        for (final draft in parts) {
          created.add(
            _unwrap(
              await _tasks.create(
                TaskDraft(
                  title: draft.title,
                  description: draft.description,
                  projectId: draft.projectId ?? source.projectId,
                  categoryId: draft.categoryId ?? source.categoryId,
                  subcategoryId: draft.subcategoryId ?? source.subcategoryId,
                  parentTaskId: draft.parentTaskId ?? source.parentTaskId,
                  sortOrder: draft.sortOrder,
                  isMandatory: draft.isMandatory,
                  status: draft.status,
                  priority: draft.priority,
                  progress: draft.progress,
                  startAt: draft.startAt,
                  dueAt: draft.dueAt,
                  estimatedMinutes: draft.estimatedMinutes,
                  energyLevel: draft.energyLevel,
                  difficulty: draft.difficulty,
                  repeatRuleId: draft.repeatRuleId,
                  color: draft.color,
                  icon: draft.icon,
                  notes: draft.notes,
                ),
              ),
              'A split task part is invalid.',
            ),
          );
        }
        _unwrap(
          await _tasks.archive(
            sourceId,
            reason: 'split_into_${created.map((task) => task.id).join('_')}',
          ),
          'The source task could not be archived.',
        );
        return Success(List.unmodifiable(created));
      });
    } on _CompositionRejected catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'task_split_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_split_failed',
          safeMessage: 'The task could not be split safely.',
        ),
      );
    }
  }

  Future<List<int>> _subtreeIds(int rootId) async {
    final ids = <int>[];
    final pending = <int>[rootId];
    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      ids.add(current);
      final children =
          await (_database.selectOnly(_database.tasks)
                ..addColumns([_database.tasks.id])
                ..where(
                  _database.tasks.parentTaskId.equals(current) &
                      _database.tasks.isDeleted.equals(false),
                ))
              .get();
      pending.addAll(
        children.map((row) => row.read(_database.tasks.id)!).toList(),
      );
    }
    return ids;
  }

  T _unwrap<T>(Result<T> result, String fallbackMessage) => switch (result) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw _CompositionRejected(
      failure.safeMessage.isEmpty ? fallbackMessage : failure.safeMessage,
    ),
  };
}

final class _CompositionRejected implements Exception {
  const _CompositionRejected(this.message);

  final String message;
}
