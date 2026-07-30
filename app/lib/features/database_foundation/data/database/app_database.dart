import 'package:drift/drift.dart';

import '../../../../core/database/database_connection_factory.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/database/database_key.dart';
import '../../../../core/database/uuid_generator.dart';
import '../../../tasks/data/tables/attachment_table.dart';
import '../../../tasks/data/tables/checklist_tables.dart';
import '../../../tasks/data/tables/custom_field_tables.dart';
import '../../../tasks/data/tables/project_tables.dart';
import '../../../tasks/data/tables/repeat_rule_table.dart';
import '../../../tasks/data/tables/task_relation_tables.dart';
import '../../../tasks/data/tables/task_table.dart';
import '../../../tasks/data/tables/taxonomy_tables.dart';
import '../../domain/entities/migration_record.dart';
import '../tables/migration_history_table.dart';
import '../tables/plugin_registry_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    MigrationHistory,
    PluginRegistry,
    Categories,
    Subcategories,
    Tags,
    Projects,
    RepeatRules,
    Tasks,
    TaskTags,
    TaskDependencies,
    TaskStateHistory,
    Checklists,
    ChecklistItems,
    Attachments,
    CustomFields,
    CustomFieldValues,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.inMemory(DatabaseKey key) =>
      AppDatabase(DatabaseConnectionFactory.openInMemory(key));

  @override
  int get schemaVersion => DatabaseConstants.schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from == 1 && to == 2) {
        await transaction(() async {
          await migrator.createTable(categories);
          await migrator.createTable(subcategories);
          await migrator.createTable(tags);
          await migrator.createTable(projects);
          await migrator.createTable(repeatRules);
          await migrator.createTable(tasks);
          await migrator.createTable(taskTags);
          await migrator.createTable(taskDependencies);
          await migrator.createTable(taskStateHistory);
          await migrator.createTable(checklists);
          await migrator.createTable(checklistItems);
          await migrator.createTable(attachments);
          await migrator.createTable(customFields);
          await migrator.createTable(customFieldValues);
          final now = DateTime.now().toUtc().microsecondsSinceEpoch;
          await into(migrationHistory).insert(
            MigrationHistoryCompanion.insert(
              uuid: UuidGenerator().generate(),
              fromVersion: from,
              toVersion: to,
              migrationName: 'sprint_3_task_engine',
              startedAt: now,
              completedAt: Value(now),
              status: MigrationStatus.succeeded,
            ),
          );
          await verifyIntegrity();
        });
        return;
      }
      throw StateError(
        'No approved migration exists from schema $from to schema $to.',
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      final foreignKeys = await customSelect(
        'PRAGMA foreign_keys;',
      ).getSingle();
      if (foreignKeys.read<int>('foreign_keys') != 1) {
        throw StateError('SQLite foreign-key enforcement is unavailable.');
      }

      final integrity = await customSelect('PRAGMA quick_check;').getSingle();
      if (integrity.read<String>('quick_check') != 'ok') {
        throw StateError('SQLite integrity verification failed.');
      }
    },
  );

  Future<void> verifyIntegrity() async {
    final foreignKeyErrors = await customSelect(
      'PRAGMA foreign_key_check;',
    ).get();
    if (foreignKeyErrors.isNotEmpty) {
      throw StateError('SQLite foreign-key integrity verification failed.');
    }

    final integrity = await customSelect('PRAGMA quick_check;').getSingle();
    if (integrity.read<String>('quick_check') != 'ok') {
      throw StateError('SQLite integrity verification failed.');
    }
  }
}
