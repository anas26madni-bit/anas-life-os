import 'package:drift/drift.dart';

import '../../../../core/database/database_connection_factory.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/database/database_key.dart';
import '../../../../core/database/uuid_generator.dart';
import '../../../calendar/data/tables/calendar_tables.dart';
import '../../../dashboard/data/tables/dashboard_tables.dart';
import '../../../dashboard/domain/entities/dashboard_models.dart';
import '../../../knowledge/data/tables/document_tables.dart';
import '../../../knowledge/data/tables/knowledge_tables.dart';
import '../../../knowledge/domain/entities/knowledge_enums.dart';
import '../../../reminders/data/tables/reminder_tables.dart';
import '../../../reminders/domain/entities/reminder_enums.dart';
import '../../../tasks/data/tables/attachment_table.dart';
import '../../../tasks/data/tables/checklist_tables.dart';
import '../../../tasks/data/tables/custom_field_tables.dart';
import '../../../tasks/data/tables/project_tables.dart';
import '../../../tasks/data/tables/repeat_rule_table.dart';
import '../../../tasks/data/tables/task_relation_tables.dart';
import '../../../tasks/data/tables/task_table.dart';
import '../../../tasks/data/tables/taxonomy_tables.dart';
import '../../../tasks/domain/entities/task_enums.dart';
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
    TaskHistory,
    Checklists,
    ChecklistItems,
    AttachmentFolders,
    Attachments,
    AttachmentVersions,
    AttachmentPreviewCache,
    AttachmentLabels,
    AttachmentLabelMap,
    CustomFields,
    CustomFieldValues,
    Reminders,
    ReminderHistory,
    KnowledgeSpaces,
    KnowledgeFolders,
    KnowledgeNotes,
    KnowledgeTags,
    KnowledgeNoteTags,
    KnowledgeLinks,
    KnowledgeVersions,
    DocumentFolders,
    Documents,
    DocumentVersions,
    DocumentMetadata,
    DashboardWidgetPreferences,
    CalendarEvents,
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
      if (from == 1 && to >= 2) {
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
          await migrator.createTable(taskHistory);
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
              toVersion: 2,
              migrationName: 'sprint_3_task_engine',
              startedAt: now,
              completedAt: Value(now),
              status: MigrationStatus.succeeded,
            ),
          );
          await verifyIntegrity();
        });
        if (to == 2) {
          return;
        }
      }
      if (from <= 2 && to >= 3) {
        await transaction(() async {
          await migrator.createTable(reminders);
          await migrator.createTable(reminderHistory);
          final now = DateTime.now().toUtc().microsecondsSinceEpoch;
          await into(migrationHistory).insert(
            MigrationHistoryCompanion.insert(
              uuid: UuidGenerator().generate(),
              fromVersion: 2,
              toVersion: 3,
              migrationName: 'sprint_4_reminder_engine',
              startedAt: now,
              completedAt: Value(now),
              status: MigrationStatus.succeeded,
            ),
          );
          await verifyIntegrity();
        });
        if (to == 3) {
          return;
        }
      }
      if (from <= 3 && to >= 4) {
        await transaction(() async {
          await migrator.createTable(knowledgeSpaces);
          await migrator.createTable(knowledgeFolders);
          await migrator.createTable(knowledgeNotes);
          await migrator.createTable(knowledgeTags);
          await migrator.createTable(knowledgeNoteTags);
          await migrator.createTable(knowledgeLinks);
          await migrator.createTable(knowledgeVersions);
          await migrator.createTable(documentFolders);
          await migrator.createTable(documents);
          await migrator.createTable(documentVersions);
          await migrator.createTable(documentMetadata);
          await migrator.createTable(attachmentFolders);
          await migrator.addColumn(attachments, attachments.folderId);
          await migrator.addColumn(attachments, attachments.knowledgeNoteId);
          await migrator.addColumn(attachments, attachments.documentId);
          await migrator.addColumn(attachments, attachments.thumbnailPath);
          await migrator.addColumn(attachments, attachments.width);
          await migrator.addColumn(attachments, attachments.height);
          await migrator.addColumn(attachments, attachments.durationSeconds);
          await migrator.addColumn(attachments, attachments.pageCount);
          await migrator.addColumn(attachments, attachments.isFavorite);
          await migrator.createTable(attachmentVersions);
          await migrator.createTable(attachmentPreviewCache);
          await migrator.createTable(attachmentLabels);
          await migrator.createTable(attachmentLabelMap);
          final now = DateTime.now().toUtc().microsecondsSinceEpoch;
          await into(migrationHistory).insert(
            MigrationHistoryCompanion.insert(
              uuid: UuidGenerator().generate(),
              fromVersion: 3,
              toVersion: 4,
              migrationName: 'sprint_5_knowledge_vault',
              startedAt: now,
              completedAt: Value(now),
              status: MigrationStatus.succeeded,
            ),
          );
          await verifyIntegrity();
        });
        if (to == 4) {
          return;
        }
      }
      if (from <= 4 && to == 5) {
        await transaction(() async {
          await migrator.createTable(dashboardWidgetPreferences);
          await migrator.createTable(calendarEvents);
          final now = DateTime.now().toUtc().microsecondsSinceEpoch;
          await into(migrationHistory).insert(
            MigrationHistoryCompanion.insert(
              uuid: UuidGenerator().generate(),
              fromVersion: 4,
              toVersion: 5,
              migrationName: 'sprint_6_dashboard_calendar',
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
