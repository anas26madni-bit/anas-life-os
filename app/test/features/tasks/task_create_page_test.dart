import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';
import 'package:anas_life_os/features/reminders/data/repositories/drift_reminder_repository.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_entity.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_project_repository.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/project_entity.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_enums.dart';
import 'package:anas_life_os/features/tasks/presentation/pages/task_create_page.dart';
import 'package:anas_life_os/features/tasks/presentation/widgets/task_form_fields.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';
import '../reminders/fake_reminder_scheduler.dart';

void main() {
  testWidgets('creates a title-only task with defaults and no reminder', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final scheduler = FakeReminderScheduler();
    await _pumpCreate(tester, database, scheduler);

    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Title only',
    );
    await tester.tap(find.byKey(const Key('task-create-save')));
    await tester.pumpAndSettle();

    final tasks = await _tasks(database);
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Title only');
    expect(tasks.single.description, isNull);
    expect(tasks.single.status, TaskStatus.pending);
    expect(tasks.single.priority, TaskPriority.none);
    expect(tasks.single.progress, 0);
    expect(tasks.single.projectId, isNull);
    expect(await _reminders(database), isEmpty);
    expect(scheduler.scheduled, isEmpty);
  });

  testWidgets('persists complete metadata and schedules a task reminder', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final project = await _createProject(database);
    final parent = await _createTask(database, 'Parent task');
    final scheduler = FakeReminderScheduler();
    await _pumpCreate(tester, database, scheduler);

    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Complete task',
    );
    await tester.enterText(
      find.byKey(const Key('task-description-field')),
      'All metadata',
    );
    await tester.enterText(
      find.byKey(const Key('task-project-field')),
      '${project.id}',
    );
    tester
        .widget<DropdownButtonFormField<int?>>(
          find.byKey(const Key('task-parent-field')),
        )
        .onChanged!(parent.id);
    await tester.pump();
    tester
        .widget<DropdownButtonFormField<TaskPriority>>(
          find.byKey(const Key('task-priority-field')),
        )
        .onChanged!(TaskPriority.high);
    await tester.pump();
    tester
        .widget<DropdownButtonFormField<TaskStatus>>(
          find.byKey(const Key('task-status-field')),
        )
        .onChanged!(TaskStatus.inProgress);
    await tester.pump();
    tester
        .widget<SwitchListTile>(find.byKey(const Key('task-mandatory-field')))
        .onChanged!(true);
    await tester.pump();
    tester
        .widget<Slider>(find.byKey(const Key('task-progress-field')))
        .onChanged!(55);
    await tester.pump();

    final now = DateTime.now();
    final lastDay = DateUtils.getDaysInMonth(now.year, now.month);
    final startDay = now.day == lastDay ? now.day - 1 : now.day;
    final dueDay = now.day == lastDay ? now.day : now.day + 1;
    await _pickDate(
      tester,
      find.byKey(const Key('task-start-date-field')),
      startDay,
    );
    await _pickDate(
      tester,
      find.byKey(const Key('task-due-date-tile')),
      dueDay,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('task-reminder-enabled')),
      200,
      scrollable: _createScrollable,
    );
    tester
        .widget<SwitchListTile>(find.byKey(const Key('task-reminder-enabled')))
        .onChanged!(true);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('task-reminder-time')),
      100,
      scrollable: _createScrollable,
    );
    expect(find.byKey(const Key('task-reminder-date')), findsOneWidget);
    expect(find.byKey(const Key('task-reminder-time')), findsOneWidget);

    await tester.tap(find.byKey(const Key('task-create-save')));
    await tester.pumpAndSettle();

    final tasks = await _tasks(database);
    final created = tasks.singleWhere((task) => task.title == 'Complete task');
    expect(created.description, 'All metadata');
    expect(created.uuid, isNotEmpty);
    expect(created.projectId, project.id);
    expect(created.parentTaskId, parent.id);
    expect(created.priority, TaskPriority.high);
    expect(created.status, TaskStatus.inProgress);
    expect(created.isMandatory, isTrue);
    expect(created.progress, 55);
    expect(created.startAt?.toLocal().day, startDay);
    expect(created.dueAt?.toLocal().day, dueDay);

    final reminders = await _reminders(database);
    expect(reminders, hasLength(1));
    expect(reminders.single.taskId, created.id);
    expect(reminders.single.title, created.title);
    expect(reminders.single.message, created.description);
    expect(reminders.single.enabled, isTrue);
    expect(scheduler.scheduled, hasLength(1));
    expect(
      scheduler.scheduled.single.occurrence.reminderId,
      reminders.single.id,
    );

    final reloaded =
        (await DriftTaskRepository(database).findById(created.id)
                as Success<TaskEntity?>)
            .value!;
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TaskFormFields(
              data: TaskFormData.fromTask(reloaded),
              onChanged: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Complete task'), findsWidgets);
    expect(find.text('All metadata'), findsOneWidget);
    expect(find.text('${project.id}'), findsWidgets);
    expect(find.text('High'), findsWidgets);
    expect(find.text('In progress'), findsWidgets);
    expect(find.text('Progress: 55%'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Task ID'), findsNothing);
  });

  testWidgets(
    'enforces the 300 character title limit and rejects invalid dates',
    (tester) async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await _pumpCreate(tester, database, FakeReminderScheduler());

      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        String.fromCharCodes(List.filled(301, 120)),
      );
      final titleInput = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('task-title-field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(titleInput.controller.text.runes.length, lessThanOrEqualTo(300));
      expect(await _tasks(database), isEmpty);

      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Invalid dates',
      );
      final now = DateTime.now();
      final lastDay = DateUtils.getDaysInMonth(now.year, now.month);
      final dueDay = now.day == 1 ? 1 : now.day - 1;
      final startDay = now.day == lastDay ? lastDay : now.day + 1;
      await _pickDate(
        tester,
        find.byKey(const Key('task-start-date-field')),
        startDay,
      );
      await _pickDate(
        tester,
        find.byKey(const Key('task-due-date-tile')),
        dueDay,
      );
      await tester.tap(find.byKey(const Key('task-create-save')));
      await tester.pump();
      expect(
        find.text('Due date cannot be before start date.'),
        findsOneWidget,
      );
      expect(await _tasks(database), isEmpty);
    },
  );

  testWidgets('cancel creates nothing and a reopened form has fresh state', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await _pumpCreate(tester, database, FakeReminderScheduler());
    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Do not save',
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(await _tasks(database), isEmpty);

    await tester.tap(find.byKey(const Key('open-create-task')));
    await tester.pumpAndSettle();
    final editable = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('task-title-field')),
        matching: find.byType(EditableText),
      ),
    );
    expect(editable.controller.text, isEmpty);
  });

  for (final locale in const [Locale('en'), Locale('ur')]) {
    for (final size in const [Size(320, 568), Size(640, 360)]) {
      testWidgets(
        'create form ${locale.languageCode} ${size.width}x${size.height} supports 200% text, keyboard and scrolling',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final database = createTestDatabase();
          addTearDown(database.close);
          await _pumpCreate(
            tester,
            database,
            FakeReminderScheduler(),
            locale: locale,
            textScaler: const TextScaler.linear(2),
          );

          expect(
            Directionality.of(tester.element(find.byType(TaskCreatePage))),
            locale.languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr,
          );
          await tester.enterText(
            find.byKey(const Key('task-title-field')),
            'Keyboard task',
          );
          await tester.scrollUntilVisible(
            find.byKey(const Key('task-reminder-section')),
            250,
            scrollable: _createScrollable,
          );
          expect(find.byKey(const Key('task-create-save')), findsOneWidget);
          expect(
            tester.getSize(find.byKey(const Key('task-create-save'))).height,
            greaterThanOrEqualTo(48),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

Future<void> _pumpCreate(
  WidgetTester tester,
  AppDatabase database,
  FakeReminderScheduler scheduler, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => database),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        initialRoute: '/create',
        routes: {
          '/': (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: const Key('open-create-task'),
                onPressed: () => Navigator.pushNamed(context, '/create'),
                child: const Text('Open'),
              ),
            ),
          ),
          '/create': (context) => const TaskCreatePage(),
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pickDate(WidgetTester tester, Finder tile, int day) async {
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
  tester
      .widget<ListTile>(
        find.descendant(of: tile, matching: find.byType(ListTile)),
      )
      .onTap!();
  await tester.pumpAndSettle();
  await tester.tap(find.text('$day').last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Finder get _createScrollable => find.byType(Scrollable).first;

Future<ProjectEntity> _createProject(AppDatabase database) async {
  final result = await DriftProjectRepository(
    database,
  ).create(title: 'Project');
  return (result as Success<ProjectEntity>).value;
}

Future<TaskEntity> _createTask(AppDatabase database, String title) async {
  final result = await DriftTaskRepository(
    database,
  ).create(TaskDraft(title: title));
  return (result as Success<TaskEntity>).value;
}

Future<List<TaskEntity>> _tasks(AppDatabase database) async =>
    (await DriftTaskRepository(database).list(limit: 200)
            as Success<List<TaskEntity>>)
        .value;

Future<List<ReminderEntity>> _reminders(AppDatabase database) async =>
    (await DriftReminderRepository(database).list(limit: 200)
            as Success<List<ReminderEntity>>)
        .value;
