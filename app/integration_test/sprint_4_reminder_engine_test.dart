import 'dart:io';
import 'dart:typed_data';

import 'package:anas_life_os/core/database/database_connection_factory.dart';
import 'package:anas_life_os/core/database/database_key.dart';
import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';
import 'package:anas_life_os/features/reminders/data/repositories/drift_reminder_repository.dart';
import 'package:anas_life_os/features/reminders/data/services/android_reminder_scheduler.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_draft.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_entity.dart';
import 'package:anas_life_os/features/reminders/domain/usecases/reminder_use_cases.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('persists and schedules a private offline reminder on Android 11', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp('reminder_engine_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}reminder_engine.db');
    final key = DatabaseKey(
      Uint8List.fromList(List<int>.generate(32, (index) => index + 17)),
    );
    var database = AppDatabase(DatabaseConnectionFactory.openFile(file: file, key: key));
    final task =
        (await DriftTaskRepository(database).create(const TaskDraft(title: 'Private task'))
                as Success<TaskEntity>)
            .value;
    final useCases = ReminderUseCases(
      DriftReminderRepository(database),
      const AndroidReminderScheduler(),
    );
    final scheduledAt = DateTime.now().toUtc().add(const Duration(hours: 1));
    final created = await useCases.create(
      ReminderDraft(
        taskId: task.id,
        title: 'Private reminder',
        scheduledAt: scheduledAt,
        timezoneId: 'UTC',
      ),
    );
    expect(created, isA<Success<ReminderEntity>>());
    await database.close();

    expect(String.fromCharCodes(await file.readAsBytes()).contains('Private reminder'), isFalse);
    database = AppDatabase(DatabaseConnectionFactory.openFile(file: file, key: key));
    addTearDown(database.close);
    final reminders = await DriftReminderRepository(database).list();
    expect((reminders as Success<List<ReminderEntity>>).value.single.title, 'Private reminder');
    await database.verifyIntegrity();
  });
}
