import 'dart:io';
import 'dart:typed_data';

import 'package:anas_life_os/core/database/database_connection_factory.dart';
import 'package:anas_life_os/core/database/database_key.dart';
import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('task CRUD persists in encrypted SQLite on Android 11', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp('task_engine_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}task_engine.db',
    );
    final key = DatabaseKey(
      Uint8List.fromList(List<int>.generate(32, (index) => index + 11)),
    );

    var database = AppDatabase(
      DatabaseConnectionFactory.openFile(file: file, key: key),
    );
    var repository = DriftTaskRepository(database);
    final created = (await repository.create(
      const TaskDraft(title: 'Persisted task'),
    ) as Success<TaskEntity>)
        .value;
    await repository.softDelete(created.id);
    await repository.restore(created.id);
    await database.close();

    expect(
      String.fromCharCodes(await file.readAsBytes()).contains('Persisted task'),
      isFalse,
    );

    database = AppDatabase(
      DatabaseConnectionFactory.openFile(file: file, key: key),
    );
    addTearDown(database.close);
    repository = DriftTaskRepository(database);
    final reopened = (await repository.findById(created.id)
            as Success<TaskEntity?>)
        .value;
    expect(reopened?.title, 'Persisted task');
    expect(reopened?.isDeleted, isFalse);
    await database.verifyIntegrity();
  });
}
