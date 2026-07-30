import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_project_repository.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/project_entity.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('creates and paginates validated projects', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftProjectRepository(database);

    final created = await repository.create(
      title: 'Private project',
      budgetMinor: 12500,
      currencyCode: 'pkr',
    );

    expect(created, isA<Success<ProjectEntity>>());
    expect(
      (created as Success<ProjectEntity>).value.currencyCode,
      'PKR',
    );
    expect(
      (await repository.list() as Success<List<ProjectEntity>>).value,
      hasLength(1),
    );
    expect(
      await repository.create(title: ' ', budgetMinor: -1),
      isA<FailureResult<ProjectEntity>>(),
    );
  });

  test('rejects deletion while active tasks reference the project', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final projects = DriftProjectRepository(database);
    final tasks = DriftTaskRepository(database);
    final project = (await projects.create(title: 'Active')
            as Success<ProjectEntity>)
        .value;
    await tasks.create(TaskDraft(title: 'Task', projectId: project.id));

    expect(await projects.softDelete(project.id), isA<FailureResult<void>>());
  });
}
