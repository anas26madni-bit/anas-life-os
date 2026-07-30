import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_support_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_enums.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_support_drafts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('persists taxonomy, tags, and checklist data transactionally', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final tasks = DriftTaskRepository(database);
    final support = DriftTaskSupportRepository(database);
    final task =
        (await tasks.create(const TaskDraft(title: 'Prepare release'))
                as Success<TaskEntity>)
            .value;

    final category = await support.createCategory('Work');
    expect(category, isA<Success<int>>());
    final categoryId = (category as Success<int>).value;
    expect(
      await support.createSubcategory(
        categoryId: categoryId,
        name: 'Engineering',
      ),
      isA<Success<int>>(),
    );
    expect(
      await support.attachTag(taskId: task.id, name: 'release'),
      isA<Success<void>>(),
    );
    final checklist = await support.createChecklist(
      taskId: task.id,
      title: 'Quality gates',
    );
    expect(checklist, isA<Success<int>>());
    expect(
      await support.addChecklistItem(
        checklistId: (checklist as Success<int>).value,
        title: 'Run analyzer',
      ),
      isA<Success<int>>(),
    );

    final stored = await (database.select(
      database.tasks,
    )..where((row) => row.id.equals(task.id))).getSingle();
    expect(stored.checklistCount, 1);
    expect(await database.select(database.taskTags).get(), hasLength(1));
  });

  test('deduplicates attachment content and validates repeat rules', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final tasks = DriftTaskRepository(database);
    final support = DriftTaskSupportRepository(database);
    final first =
        (await tasks.create(const TaskDraft(title: 'First'))
                as Success<TaskEntity>)
            .value;
    final second =
        (await tasks.create(const TaskDraft(title: 'Second'))
                as Success<TaskEntity>)
            .value;
    final checksum = List.filled(64, 'a').join();

    final firstAttachment = await support.addAttachment(
      AttachmentDraft(
        taskId: first.id,
        fileName: 'plan.pdf',
        storagePath: '/private/plan.pdf',
        fileSize: 42,
        checksumSha256: checksum,
      ),
    );
    expect(firstAttachment, isA<Success<int>>());
    final secondAttachment = await support.addAttachment(
      AttachmentDraft(
        taskId: second.id,
        fileName: 'plan-copy.pdf',
        storagePath: '/private/duplicate.pdf',
        fileSize: 42,
        checksumSha256: checksum,
      ),
    );
    expect(secondAttachment, isA<Success<int>>());
    final stored = await database.select(database.attachments).get();
    expect(stored, hasLength(2));
    expect(stored.map((row) => row.storagePath).toSet(), hasLength(1));

    expect(
      await support.createRepeatRule(
        const RepeatRuleDraft(
          name: 'Weekdays',
          frequency: RepeatFrequency.weekly,
          timezoneId: 'Asia/Karachi',
          weekdayMask: 31,
        ),
      ),
      isA<Success<int>>(),
    );
    expect(
      await support.createRepeatRule(
        const RepeatRuleDraft(
          name: 'Invalid',
          frequency: RepeatFrequency.daily,
          timezoneId: 'Asia/Karachi',
          interval: 0,
        ),
      ),
      isA<FailureResult<int>>(),
    );
  });
}
