import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/reminders/data/repositories/drift_reminder_repository.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_draft.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_entity.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_enums.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test(
    'persists reminder lifecycle and append-only idempotent history',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final task =
          (await DriftTaskRepository(
                    database,
                  ).create(const TaskDraft(title: 'Task'))
                  as Success<TaskEntity>)
              .value;
      final repository = DriftReminderRepository(
        database,
        clock: () => DateTime.utc(2026, 8, 6),
      );
      final created =
          (await repository.create(
                    ReminderDraft(
                      taskId: task.id,
                      title: 'Start task',
                      scheduledAt: DateTime.utc(2026, 8, 7),
                      timezoneId: 'Asia/Karachi',
                    ),
                  )
                  as Success<ReminderEntity>)
              .value;
      expect(created.enabled, isTrue);

      final disabled = await repository.setEnabled(created.id, false);
      expect((disabled as Success<ReminderEntity>).value.enabled, isFalse);
      expect(
        (await repository.list() as Success<List<ReminderEntity>>).value,
        hasLength(1),
      );

      await repository.recordAction(
        reminderId: created.id,
        occurrenceUuid: created.uuid,
        action: ReminderAction.triggered,
        occurredAt: DateTime.utc(2026, 8, 7),
      );
      await repository.recordAction(
        reminderId: created.id,
        occurrenceUuid: created.uuid,
        action: ReminderAction.triggered,
        occurredAt: DateTime.utc(2026, 8, 7),
      );
      expect(
        (await repository.history() as Success<List<ReminderHistoryEntity>>)
            .value,
        hasLength(1),
      );

      expect(
        (await repository.softDelete(created.id) as Success<ReminderEntity>)
            .value
            .isDeleted,
        isTrue,
      );
      expect(
        (await repository.restore(created.id) as Success<ReminderEntity>)
            .value
            .isDeleted,
        isFalse,
      );
    },
  );

  test('rejects reminders for missing tasks', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final result = await DriftReminderRepository(database).create(
      ReminderDraft(
        taskId: 999,
        title: 'Invalid',
        scheduledAt: DateTime.utc(2026, 8, 7),
        timezoneId: 'UTC',
      ),
    );
    expect(result, isA<FailureResult<ReminderEntity>>());
  });
}
