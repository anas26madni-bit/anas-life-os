import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('creates, updates, paginates, deletes, and restores a task', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftTaskRepository(
      database,
      clock: () => DateTime.utc(2026, 7, 30),
    );

    final createdResult = await repository.create(
      const TaskDraft(title: 'Plan sprint', priority: TaskPriority.high),
    );
    expect(createdResult, isA<Success<TaskEntity>>());
    final created = (createdResult as Success<TaskEntity>).value;
    expect(created.title, 'Plan sprint');
    expect(
      created.uuid,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(
      (await repository.list() as Success<List<TaskEntity>>).value,
      hasLength(1),
    );
    expect(await database.select(database.taskHistory).get(), hasLength(1));

    final updated = await repository.update(
      created.id,
      const TaskDraft(title: 'Plan Sprint 3', progress: 25),
    );
    final updatedTask = (updated as Success<TaskEntity>).value;
    expect(updatedTask.version, 2);
    expect(updatedTask.id, created.id);
    expect(updatedTask.uuid, created.uuid);
    expect(await database.select(database.taskHistory).get(), hasLength(2));

    final deleted = await repository.softDelete(created.id);
    final deletedTask = (deleted as Success<TaskEntity>).value;
    expect(deletedTask.isDeleted, isTrue);
    expect(deletedTask.uuid, created.uuid);
    expect(
      (await repository.list() as Success<List<TaskEntity>>).value,
      isEmpty,
    );

    final restored = await repository.restore(created.id);
    final restoredTask = (restored as Success<TaskEntity>).value;
    expect(restoredTask.isDeleted, isFalse);
    expect(restoredTask.uuid, created.uuid);
  });

  test('generates a unique persistent task UUID completely offline', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftTaskRepository(database);

    final created = <TaskEntity>[];
    for (var index = 0; index < 25; index++) {
      created.add(
        (await repository.create(TaskDraft(title: 'Task $index'))
                as Success<TaskEntity>)
            .value,
      );
    }

    expect(created.map((task) => task.id).toSet(), hasLength(created.length));
    expect(created.map((task) => task.uuid).toSet(), hasLength(created.length));
    for (final task in created) {
      final reloaded =
          (await repository.findById(task.id) as Success<TaskEntity?>).value;
      expect(reloaded?.uuid, task.uuid);
    }
  });

  test('enforces mandatory subtasks and dependency cycles', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftTaskRepository(database);
    final parent =
        (await repository.create(const TaskDraft(title: 'Parent'))
                as Success<TaskEntity>)
            .value;
    await repository.create(
      TaskDraft(
        title: 'Mandatory child',
        parentTaskId: parent.id,
        isMandatory: true,
      ),
    );
    expect(
      await repository.changeStatus(parent.id, TaskStatus.completed),
      isA<FailureResult<TaskEntity>>(),
    );

    final first =
        (await repository.create(const TaskDraft(title: 'First'))
                as Success<TaskEntity>)
            .value;
    final second =
        (await repository.create(const TaskDraft(title: 'Second'))
                as Success<TaskEntity>)
            .value;
    expect(
      await repository.addDependency(
        taskId: second.id,
        dependsOnTaskId: first.id,
        type: DependencyType.finishToStart,
      ),
      isA<Success<void>>(),
    );
    expect(
      await repository.changeStatus(second.id, TaskStatus.inProgress),
      isA<FailureResult<TaskEntity>>(),
    );
    await repository.changeStatus(first.id, TaskStatus.completed);
    expect(
      await repository.changeStatus(second.id, TaskStatus.inProgress),
      isA<Success<TaskEntity>>(),
    );
    expect(
      await repository.addDependency(
        taskId: first.id,
        dependsOnTaskId: second.id,
        type: DependencyType.finishToStart,
      ),
      isA<FailureResult<void>>(),
    );
  });
}
