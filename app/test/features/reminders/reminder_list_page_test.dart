import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/reminders/presentation/pages/reminder_list_page.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';
import 'fake_reminder_scheduler.dart';

void main() {
  testWidgets('creates and disables a reminder through the accessible UI', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final task =
        (await DriftTaskRepository(database).create(const TaskDraft(title: 'Task'))
                as Success<TaskEntity>)
            .value;
    final scheduler = FakeReminderScheduler();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReminderListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No reminders yet'), findsOneWidget);
    await tester.tap(find.text('Create reminder').first);
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), task.id.toString());
    await tester.enterText(fields.at(1), 'Review task');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Review task'), findsOneWidget);
    expect(scheduler.scheduled, hasLength(1));
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(scheduler.cancelled, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports Urdu RTL and large text without overflow', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
          reminderSchedulerProvider.overrideWithValue(FakeReminderScheduler()),
        ],
        child: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: MaterialApp(
            locale: Locale('ur'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ReminderListPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(find.byType(Scaffold))), TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });
}
