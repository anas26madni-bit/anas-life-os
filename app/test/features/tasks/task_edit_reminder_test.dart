import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';
import 'package:anas_life_os/features/reminders/data/repositories/drift_reminder_repository.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_entity.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:anas_life_os/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';
import '../reminders/fake_reminder_scheduler.dart';

void main() {
  testWidgets('Edit Task creates and reloads an audible task reminder', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final task =
        (await DriftTaskRepository(
                  database,
                ).create(const TaskDraft(title: 'Reminder task'))
                as Success<TaskEntity>)
            .value;
    final scheduler = FakeReminderScheduler();

    await _pumpDetail(tester, database, scheduler, task.id);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('task-reminder-enabled')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    tester
        .widget<SwitchListTile>(find.byKey(const Key('task-reminder-enabled')))
        .onChanged!(true);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('task-reminder-audible')),
          )
          .value,
      isTrue,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('task-edit-save')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('task-edit-save')));
    await tester.pumpAndSettle();

    final stored =
        (await DriftReminderRepository(database).list()
                as Success<List<ReminderEntity>>)
            .value;
    expect(stored, hasLength(1));
    expect(stored.single.taskId, task.id);
    expect(stored.single.sound, 'default');
    expect(scheduler.scheduled, hasLength(1));
    expect(scheduler.scheduled.single.occurrence.sound, 'default');

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('task-reminder-enabled')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('task-reminder-enabled')),
          )
          .value,
      isTrue,
    );
  });
}

Future<void> _pumpDetail(
  WidgetTester tester,
  AppDatabase database,
  FakeReminderScheduler scheduler,
  int taskId,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => database),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: TaskDetailPage(taskId: taskId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
