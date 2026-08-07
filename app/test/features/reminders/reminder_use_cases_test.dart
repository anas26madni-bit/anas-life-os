import 'package:anas_life_os/core/errors/failure.dart';
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
      scheduler.events.add(
        ReminderPlatformEvent(
          reminderId: created.id,
          occurrenceUuid: 'unsupported-action',
          action: 'unsupported',
          occurredAt: DateTime.utc(2026, 8, 7),
        ),
      );
      scheduler.events.add(
        ReminderPlatformEvent(
          reminderId: created.id,
          occurrenceUuid: '00000000-0000-4000-8000-000000000002',
          action: ReminderAction.expired.name,
          occurredAt: DateTime.utc(2026, 8, 8),
        ),
      );
      scheduler.events.add(
        ReminderPlatformEvent(
          reminderId: created.id,
          occurrenceUuid: '00000000-0000-4000-8000-000000000003',
          action: ReminderAction.triggered.name,
          occurredAt: DateTime.utc(2026, 8, 9),
        ),
      );
      expect(await useCases.synchronizePlatformEvents(), isA<Success<void>>());
      expect(
        (await useCases.missedReport() as Success<List<ReminderHistoryEntity>>)
            .value,
        hasLength(2),
      );
    },
  );

  test('updates, toggles, lists, and deletes through the scheduler', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final task =
        (await DriftTaskRepository(database).create(const TaskDraft(title: 'Task'))
                as Success<TaskEntity>)
            .value;
    final repository = DriftReminderRepository(database);
    final scheduler = FakeReminderScheduler();
    final useCases = ReminderUseCases(repository, scheduler);
    final draft = ReminderDraft(
      taskId: task.id,
      title: 'Reminder',
      scheduledAt: DateTime.utc(2026, 8, 7),
      timezoneId: 'UTC',
    );

    final created =
        (await useCases.create(draft) as Success<ReminderEntity>).value;
    expect(
      (await useCases.list() as Success<List<ReminderEntity>>).value,
      hasLength(1),
    );
    expect(
      await useCases.update(created.id, draft),
      isA<Success<ReminderEntity>>(),
    );
    expect(
      await useCases.setEnabled(created.id, false),
      isA<Success<ReminderEntity>>(),
    );
    expect(
      await useCases.setEnabled(created.id, true),
      isA<Success<ReminderEntity>>(),
    );
    expect(await useCases.delete(created.id), isA<Success<ReminderEntity>>());
    expect(
      scheduler.cancelled,
      containsAll(<int>[created.id, created.id, created.id]),
    );
  });

  test('propagates repository and scheduler failures safely', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final task =
        (await DriftTaskRepository(database).create(const TaskDraft(title: 'Task'))
                as Success<TaskEntity>)
            .value;
    final repository = DriftReminderRepository(database);
    const failure = DatabaseFailure(
      code: 'platform_unavailable',
      safeMessage: 'The reminder platform is unavailable.',
    );
    final scheduler = FakeReminderScheduler(scheduleFailure: failure);
    final useCases = ReminderUseCases(repository, scheduler);
    final draft = ReminderDraft(
      taskId: task.id,
      title: 'Reminder',
      scheduledAt: DateTime.utc(2026, 8, 7),
      timezoneId: 'UTC',
    );

    expect(
      await useCases.create(
        ReminderDraft(
          taskId: 0,
          title: 'Invalid',
          scheduledAt: DateTime.utc(2026, 8, 7),
          timezoneId: 'UTC',
        ),
      ),
      isA<FailureResult<ReminderEntity>>(),
    );
    expect(await useCases.create(draft), isA<FailureResult<ReminderEntity>>());

    scheduler.scheduleFailure = null;
    scheduler.exactFailure = failure;
    final created =
        (await useCases.create(draft) as Success<ReminderEntity>).value;
    expect(
      scheduler.scheduled.last.occurrence.precision,
      ReminderSchedulePrecision.inexact,
    );

    scheduler.scheduleFailure = failure;
    expect(
      await useCases.update(created.id, draft),
      isA<FailureResult<ReminderEntity>>(),
    );
    scheduler.scheduleFailure = null;
    scheduler.cancelFailure = failure;
    expect(
      await useCases.setEnabled(created.id, false),
      isA<FailureResult<ReminderEntity>>(),
    );
    expect(
      await useCases.setEnabled(999, true),
      isA<FailureResult<ReminderEntity>>(),
    );

    scheduler.drainFailure = failure;
    expect(
      await useCases.synchronizePlatformEvents(),
      isA<FailureResult<void>>(),
    );
    scheduler.drainFailure = null;
    scheduler.events.add(
      ReminderPlatformEvent(
        reminderId: 999,
        occurrenceUuid: '00000000-0000-4000-8000-000000000004',
        action: ReminderAction.triggered.name,
        occurredAt: DateTime.utc(2026, 8, 10),
      ),
    );
    expect(
      await useCases.synchronizePlatformEvents(),
      isA<FailureResult<void>>(),
    );
  });
}
