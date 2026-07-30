import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/services/task_validator.dart';
import 'task_repository_support.dart';

final class DriftTaskRepository implements TaskRepository {
  DriftTaskRepository(
    this._database, {
    TaskValidator validator = const TaskValidator(),
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _validator = validator,
       _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final TaskValidator _validator;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  TaskRepositorySupport get _support =>
      TaskRepositorySupport(_database, uuidFactory: _uuidFactory);

  @override
  Future<Result<TaskEntity>> create(TaskDraft draft) async {
    final validated = _validator.validate(draft);
    if (validated case FailureResult<TaskDraft>(:final failure)) {
      return FailureResult(failure);
    }
    final normalized = (validated as Success<TaskDraft>).value;
    try {
      return await _database.transaction(() async {
        await _support.validateParent(normalized.parentTaskId);
        final now = _clock().toUtc();
        final id = await _database
            .into(_database.tasks)
            .insert(
              TasksCompanion.insert(
                uuid: _uuidFactory(),
                title: normalized.title,
                status: normalized.status,
                priority: normalized.priority,
                createdAt: now.microsecondsSinceEpoch,
                updatedAt: now.microsecondsSinceEpoch,
                description: Value(normalized.description),
                projectId: Value(normalized.projectId),
                categoryId: Value(normalized.categoryId),
                subcategoryId: Value(normalized.subcategoryId),
                parentTaskId: Value(normalized.parentTaskId),
                repeatRuleId: Value(normalized.repeatRuleId),
                sortOrder: Value(normalized.sortOrder),
                isMandatory: Value(normalized.isMandatory),
                progress: Value(normalized.progress),
                startAt: Value(_epoch(normalized.startAt)),
                dueAt: Value(_epoch(normalized.dueAt)),
                completedAt: Value(
                  normalized.status == TaskStatus.completed
                      ? now.microsecondsSinceEpoch
                      : null,
                ),
                estimatedMinutes: Value(normalized.estimatedMinutes),
                energyLevel: Value(normalized.energyLevel),
                difficulty: Value(normalized.difficulty),
                color: Value(normalized.color),
                icon: Value(normalized.icon),
                notes: Value(normalized.notes),
              ),
            );
        await _support.recordState(id, null, normalized.status, now, 'created');
        await _support.refreshParentCount(normalized.parentTaskId, now);
        return Success(await _requireRow(id));
      });
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_create_failed',
          safeMessage: 'The task could not be created safely.',
        ),
      );
    }
  }

  @override
  Future<Result<TaskEntity>> update(int id, TaskDraft draft) async {
    final validated = _validator.validate(draft);
    if (validated case FailureResult<TaskDraft>(:final failure)) {
      return FailureResult(failure);
    }
    final normalized = (validated as Success<TaskDraft>).value;
    try {
      return await _database.transaction(() async {
        final current = await _support.requireRaw(id, includeDeleted: false);
        await _support.validateParent(normalized.parentTaskId, taskId: id);
        final now = _clock().toUtc();
        await (_database.update(
          _database.tasks,
        )..where((row) => row.id.equals(id))).write(
          TasksCompanion(
            title: Value(normalized.title),
            description: Value(normalized.description),
            projectId: Value(normalized.projectId),
            categoryId: Value(normalized.categoryId),
            subcategoryId: Value(normalized.subcategoryId),
            parentTaskId: Value(normalized.parentTaskId),
            repeatRuleId: Value(normalized.repeatRuleId),
            sortOrder: Value(normalized.sortOrder),
            isMandatory: Value(normalized.isMandatory),
            status: Value(normalized.status),
            priority: Value(normalized.priority),
            progress: Value(normalized.progress),
            startAt: Value(_epoch(normalized.startAt)),
            dueAt: Value(_epoch(normalized.dueAt)),
            completedAt: Value(
              normalized.status == TaskStatus.completed
                  ? now.microsecondsSinceEpoch
                  : null,
            ),
            estimatedMinutes: Value(normalized.estimatedMinutes),
            energyLevel: Value(normalized.energyLevel),
            difficulty: Value(normalized.difficulty),
            color: Value(normalized.color),
            icon: Value(normalized.icon),
            notes: Value(normalized.notes),
            updatedAt: Value(now.microsecondsSinceEpoch),
            version: Value(current.version + 1),
          ),
        );
        if (current.status != normalized.status) {
          await _support.recordState(
            id,
            current.status,
            normalized.status,
            now,
            'updated',
          );
        } else {
          await _support.recordMutation(taskId: id, action: 'update', at: now);
        }
        await _support.refreshParentCount(current.parentTaskId, now);
        if (current.parentTaskId != normalized.parentTaskId) {
          await _support.refreshParentCount(normalized.parentTaskId, now);
        }
        return Success(await _requireRow(id));
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'task_update_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_update_failed',
          safeMessage: 'The task could not be updated safely.',
        ),
      );
    }
  }

  @override
  Future<Result<TaskEntity?>> findById(
    int id, {
    bool includeDeleted = false,
  }) async {
    try {
      final query = _database.select(_database.tasks)
        ..where((row) => row.id.equals(id));
      if (!includeDeleted) query.where((row) => row.isDeleted.equals(false));
      final row = await query.getSingleOrNull();
      return Success(row == null ? null : _map(row));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_read_failed',
          safeMessage: 'The task could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<List<TaskEntity>>> list({
    int limit = 50,
    int offset = 0,
    bool includeDeleted = false,
  }) async {
    if (limit < 1 || limit > 200 || offset < 0) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_task_page',
          safeMessage: 'The requested task page is invalid.',
        ),
      );
    }
    try {
      final query = _database.select(_database.tasks);
      if (!includeDeleted) query.where((row) => row.isDeleted.equals(false));
      query
        ..orderBy([
          (row) => OrderingTerm.desc(row.updatedAt),
          (row) => OrderingTerm.asc(row.id),
        ])
        ..limit(limit, offset: offset);
      return Success((await query.get()).map(_map).toList(growable: false));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_list_failed',
          safeMessage: 'Tasks could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<TaskEntity>> changeStatus(
    int id,
    TaskStatus status, {
    String? reason,
  }) async {
    if (status == TaskStatus.deleted) {
      return softDelete(id, reason: reason);
    }
    try {
      return await _database.transaction(() async {
        final current = await _support.requireRaw(
          id,
          includeDeleted: status == TaskStatus.deleted,
        );
        if (status == TaskStatus.completed)
          await _support.validateMandatoryChildren(id);
        await _support.validateDependencies(id, status);
        if (current.status == TaskStatus.blocked &&
            status == TaskStatus.completed) {
          throw StateError(
            'A blocked task must be unblocked before completion.',
          );
        }
        final now = _clock().toUtc();
        final deleting = status == TaskStatus.deleted;
        await (_database.update(
          _database.tasks,
        )..where((row) => row.id.equals(id))).write(
          TasksCompanion(
            status: Value(status),
            preDeleteStatus: Value(
              deleting ? current.status : current.preDeleteStatus,
            ),
            progress: Value(
              status == TaskStatus.completed ? 100 : current.progress,
            ),
            completedAt: Value(
              status == TaskStatus.completed
                  ? now.microsecondsSinceEpoch
                  : null,
            ),
            isDeleted: Value(deleting),
            deletedAt: Value(deleting ? now.microsecondsSinceEpoch : null),
            updatedAt: Value(now.microsecondsSinceEpoch),
            version: Value(current.version + 1),
          ),
        );
        await _support.recordState(id, current.status, status, now, reason);
        return Success(await _requireRow(id, includeDeleted: deleting));
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'task_transition_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_transition_failed',
          safeMessage: 'The task state could not be changed safely.',
        ),
      );
    }
  }

  @override
  Future<Result<TaskEntity>> archive(int id, {String? reason}) =>
      changeStatus(id, TaskStatus.archived, reason: reason);

  @override
  Future<Result<TaskEntity>> softDelete(int id, {String? reason}) async {
    try {
      return await _database.transaction(() async {
        final root = await _support.requireRaw(id, includeDeleted: false);
        final now = _clock().toUtc();
        await _support.softDeleteTree(root, now, reason);
        await _support.refreshParentCount(root.parentTaskId, now);
        return Success(await _requireRow(id, includeDeleted: true));
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'task_delete_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_delete_failed',
          safeMessage: 'The task could not be deleted safely.',
        ),
      );
    }
  }

  @override
  Future<Result<TaskEntity>> restore(int id, {String? reason}) async {
    try {
      final current = await _support.requireRaw(id, includeDeleted: true);
      if (!current.isDeleted) return Success(_map(current));
      if (current.parentTaskId != null)
        await _support.requireRaw(current.parentTaskId!, includeDeleted: false);
      final restored =
          current.preDeleteStatus == null ||
              current.preDeleteStatus == TaskStatus.deleted
          ? TaskStatus.pending
          : current.preDeleteStatus!;
      return _restoreTo(id, restored, reason);
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'task_restore_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'task_restore_failed',
          safeMessage: 'The task could not be restored safely.',
        ),
      );
    }
  }

  Future<Result<TaskEntity>> _restoreTo(
    int id,
    TaskStatus restored,
    String? reason,
  ) async {
    return _database.transaction(() async {
      final current = await _support.requireRaw(id, includeDeleted: true);
      final now = _clock().toUtc();
      await (_database.update(
        _database.tasks,
      )..where((row) => row.id.equals(id))).write(
        TasksCompanion(
          status: Value(restored),
          preDeleteStatus: const Value(null),
          isDeleted: const Value(false),
          deletedAt: const Value(null),
          updatedAt: Value(now.microsecondsSinceEpoch),
          version: Value(current.version + 1),
        ),
      );
      await _support.recordState(
        id,
        TaskStatus.deleted,
        restored,
        now,
        reason ?? 'restored',
      );
      await _support.refreshParentCount(current.parentTaskId, now);
      return Success(await _requireRow(id));
    });
  }

  @override
  Future<Result<TaskEntity>> duplicate(int id) async {
    final source = await findById(id);
    if (source case FailureResult<TaskEntity?>(:final failure))
      return FailureResult(failure);
    final task = (source as Success<TaskEntity?>).value;
    if (task == null) {
      return const FailureResult(
        ValidationFailure(
          code: 'task_not_found',
          safeMessage: 'The task does not exist.',
        ),
      );
    }
    return create(
      TaskDraft(
        title: task.title,
        description: task.description,
        projectId: task.projectId,
        categoryId: task.categoryId,
        subcategoryId: task.subcategoryId,
        status: TaskStatus.pending,
        priority: task.priority,
        startAt: task.startAt,
        dueAt: task.dueAt,
      ),
    );
  }

  @override
  Future<Result<void>> addDependency({
    required int taskId,
    required int dependsOnTaskId,
    required DependencyType type,
  }) async {
    if (taskId == dependsOnTaskId) {
      return const FailureResult(
        ValidationFailure(
          code: 'dependency_self_cycle',
          safeMessage: 'A task cannot depend on itself.',
        ),
      );
    }
    try {
      return await _database.transaction(() async {
        await _support.requireRaw(taskId, includeDeleted: false);
        await _support.requireRaw(dependsOnTaskId, includeDeleted: false);
        final duplicate =
            await (_database.select(_database.taskDependencies)..where(
                  (row) =>
                      row.taskId.equals(taskId) &
                      row.dependsOnTaskId.equals(dependsOnTaskId),
                ))
                .getSingleOrNull();
        if (duplicate != null) {
          throw StateError('The dependency already exists.');
        }
        if (await _support.createsDependencyCycle(taskId, dependsOnTaskId)) {
          throw StateError('The dependency would create a cycle.');
        }
        final now = _clock().toUtc().microsecondsSinceEpoch;
        await _database
            .into(_database.taskDependencies)
            .insert(
              TaskDependenciesCompanion.insert(
                uuid: _uuidFactory(),
                taskId: taskId,
                dependsOnTaskId: dependsOnTaskId,
                dependencyType: type,
                createdAt: now,
                updatedAt: now,
              ),
            );
        return const Success(null);
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'dependency_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'dependency_save_failed',
          safeMessage: 'The dependency could not be saved safely.',
        ),
      );
    }
  }

  Future<TaskEntity> _requireRow(int id, {bool includeDeleted = false}) async =>
      _map(await _support.requireRaw(id, includeDeleted: includeDeleted));
  TaskEntity _map(TaskRow row) => TaskEntity(
    id: row.id,
    uuid: row.uuid,
    title: row.title,
    description: row.description,
    projectId: row.projectId,
    categoryId: row.categoryId,
    subcategoryId: row.subcategoryId,
    parentTaskId: row.parentTaskId,
    sortOrder: row.sortOrder,
    isMandatory: row.isMandatory,
    status: row.status,
    preDeleteStatus: row.preDeleteStatus,
    priority: row.priority,
    progress: row.progress,
    startAt: _date(row.startAt),
    dueAt: _date(row.dueAt),
    completedAt: _date(row.completedAt),
    createdAt: _date(row.createdAt)!,
    updatedAt: _date(row.updatedAt)!,
    deletedAt: _date(row.deletedAt),
    isDeleted: row.isDeleted,
    version: row.version,
  );

  int? _epoch(DateTime? value) => value?.toUtc().microsecondsSinceEpoch;
  DateTime? _date(int? value) => value == null
      ? null
      : DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
}
