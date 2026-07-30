import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_composition_repository.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('clones a standalone task and its subtask graph', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final tasks = DriftTaskRepository(database);
    final composition = DriftTaskCompositionRepository(database, tasks: tasks);
    final source = (await tasks.create(const TaskDraft(title: 'Source'))
            as Success<TaskEntity>)
        .value;
    await tasks.create(
      TaskDraft(title: 'Child', parentTaskId: source.id, isMandatory: true),
    );

    final clone = (await composition.clone(source.id) as Success<TaskEntity>)
        .value;

    expect(clone.id, isNot(source.id));
    expect(clone.parentTaskId, isNull);
    final all = (await tasks.list() as Success<List<TaskEntity>>).value;
    expect(all.where((task) => task.parentTaskId == clone.id), hasLength(1));
  });

  test('moves a task subtree to a project', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final tasks = DriftTaskRepository(database);
    final composition = DriftTaskCompositionRepository(database, tasks: tasks);
    final now = DateTime.utc(2026).microsecondsSinceEpoch;
    final projectId = await database.into(database.projects).insert(
      ProjectsCompanion.insert(
        uuid: '00000000-0000-4000-8000-000000000010',
        title: 'Project',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final root = (await tasks.create(const TaskDraft(title: 'Root'))
            as Success<TaskEntity>)
        .value;
    final child = (await tasks.create(
      TaskDraft(title: 'Child', parentTaskId: root.id),
    ) as Success<TaskEntity>)
        .value;

    expect(
      await composition.move(root.id, projectId: projectId),
      isA<Success<TaskEntity>>(),
    );
    expect(
      (await tasks.findById(child.id) as Success<TaskEntity?>).value!.projectId,
      projectId,
    );
  });

  test('merge and split archive sources atomically', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final tasks = DriftTaskRepository(database);
    final composition = DriftTaskCompositionRepository(database, tasks: tasks);
    final first = (await tasks.create(const TaskDraft(title: 'First'))
            as Success<TaskEntity>)
        .value;
    final second = (await tasks.create(const TaskDraft(title: 'Second'))
            as Success<TaskEntity>)
        .value;

    final merged = await composition.merge(
      sourceIds: [first.id, second.id],
      mergedTask: const TaskDraft(title: 'Merged'),
    );
    expect(merged, isA<Success<TaskEntity>>());
    expect(
      (await tasks.findById(first.id) as Success<TaskEntity?>).value!.status,
      TaskStatus.archived,
    );

    final mergedTask = (merged as Success<TaskEntity>).value;
    final split = await composition.split(
      sourceId: mergedTask.id,
      parts: const [TaskDraft(title: 'Part A'), TaskDraft(title: 'Part B')],
    );
    expect((split as Success<List<TaskEntity>>).value, hasLength(2));
    expect(
      (await tasks.findById(mergedTask.id) as Success<TaskEntity?>).value!.status,
      TaskStatus.archived,
    );
  });
}
