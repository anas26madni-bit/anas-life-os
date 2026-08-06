import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/reminders/data/repositories/drift_reminder_repository.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_draft.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_entity.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_enums.dart';
import 'package:anas_life_os/features/reminders/domain/services/reminder_scheduler.dart';
import 'package:anas_life_os/features/reminders/domain/usecases/reminder_use_cases.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';
import 'fake_reminder_scheduler.dart';

void main() {
  test(
    'schedules with graceful inexact fallback and synchronizes events',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final task =
          (await DriftTaskRepository(
                    database,
                  ).create(const TaskDraft(title: 'Task'))
                  as Success<TaskEntity>)
              .value;
      final repository = DriftReminderRepository(database);
      final scheduler = FakeReminderScheduler(exactAllowed: false);
      final useCases = ReminderUseCases(repository, scheduler);

      final created =
          (await useCases.create(
                    ReminderDraft(
                      taskId: task.id,
                      title: 'Reminder',
                      scheduledAt: DateTime.utc(2026, 8, 7),
                      timezoneId: 'UTC',
                    ),
                  )
                  as Success<ReminderEntity>)
              .value;
      expect(
        scheduler.scheduled.single.occurrence.precision,
        ReminderSchedulePrecision.inexact,
      );

      scheduler.events.add(
        ReminderPlatformEvent(
          reminderId: created.id,
          occurrenceUuid: created.uuid,
          action: ReminderAction.ignored.name,
          occurredAt: DateTime.utc(2026, 8, 7),
        ),
      );
      expect(await useCases.synchronizePlatformEvents(), isA<Success<void>>());
      expect(
        (await useCases.missedReport() as Success<List<ReminderHistoryEntity>>)
            .value,
        hasLength(1),
      );
    },
  );
}
