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
import '../../../search/data/tables/search_tables.dart';
import '../../../search/domain/entities/search_models.dart';
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
    SearchDocuments,
    SearchIndexQueue,
    SearchHistory,
    SavedSearches,
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
      await _installSearchInfrastructure();
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
      if (from <= 4 && to >= 5) {
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
        if (to == 5) {
          return;
        }
      }
      if (from <= 5 && to == 6) {
        await transaction(() async {
          await migrator.createTable(searchDocuments);
          await migrator.createTable(searchIndexQueue);
          await migrator.createTable(searchHistory);
          await migrator.createTable(savedSearches);
          await _installSearchInfrastructure();
          final now = DateTime.now().toUtc().microsecondsSinceEpoch;
          await into(migrationHistory).insert(
            MigrationHistoryCompanion.insert(
              uuid: UuidGenerator().generate(),
              fromVersion: 5,
              toVersion: 6,
              migrationName: 'sprint_7_search_engine',
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
      await customStatement('PRAGMA temp_store = MEMORY;');
      await customStatement('PRAGMA journal_mode = WAL;');
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

  Future<VerifiedSearchDatabaseSession> verifySearchSession() async {
    final cipher = await customSelect('PRAGMA cipher_version;').get();
    if (cipher.isEmpty) {
      throw StateError('Encrypted search requires SQLCipher.');
    }
    await customSelect(
      'SELECT count(*) AS count FROM sqlite_master;',
    ).getSingle();
    await verifyIntegrity();
    final temporaryStorage = await customSelect(
      'PRAGMA temp_store;',
    ).getSingle();
    if (temporaryStorage.read<int>('temp_store') != 2) {
      throw StateError(
        'Encrypted search requires memory-only temporary storage.',
      );
    }
    return VerifiedSearchDatabaseSession._(this);
  }

  Future<void> _installSearchInfrastructure() async {
    await customStatement(
      "CREATE VIRTUAL TABLE IF NOT EXISTS search_fts USING fts5("
      "title, body, metadata, tag_keys, "
      "content='search_documents', content_rowid='id', "
      "tokenize='unicode61 remove_diacritics 2');",
    );
    await customStatement(
      'CREATE TRIGGER IF NOT EXISTS search_documents_ai AFTER INSERT ON '
      'search_documents BEGIN INSERT INTO search_fts('
      'rowid,title,body,metadata,tag_keys) VALUES '
      '(new.id,new.title,new.body,new.metadata,new.tag_keys); END;',
    );
    await customStatement(
      "CREATE TRIGGER IF NOT EXISTS search_documents_ad AFTER DELETE ON "
      "search_documents BEGIN INSERT INTO search_fts("
      "search_fts,rowid,title,body,metadata,tag_keys) VALUES "
      "('delete',old.id,old.title,old.body,old.metadata,old.tag_keys); END;",
    );
    await customStatement(
      "CREATE TRIGGER IF NOT EXISTS search_documents_au AFTER UPDATE ON "
      "search_documents BEGIN INSERT INTO search_fts("
      "search_fts,rowid,title,body,metadata,tag_keys) VALUES "
      "('delete',old.id,old.title,old.body,old.metadata,old.tag_keys); "
      'INSERT INTO search_fts(rowid,title,body,metadata,tag_keys) VALUES '
      '(new.id,new.title,new.body,new.metadata,new.tag_keys); END;',
    );
    for (final source in const {
      'tasks': 'task',
      'projects': 'project',
      'knowledge_notes': 'note',
      'documents': 'document',
      'attachments': 'attachment',
    }.entries) {
      for (final action in const ['INSERT', 'UPDATE', 'DELETE']) {
        final reference = action == 'DELETE' ? 'old' : 'new';
        await customStatement(
          'CREATE TRIGGER IF NOT EXISTS search_queue_${source.key}_'
          '${action.toLowerCase()} AFTER $action ON ${source.key} BEGIN '
          'INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) '
          "VALUES ('${source.value}',$reference.id); END;",
        );
      }
      await customStatement(
        'INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) '
        "SELECT '${source.value}',id FROM ${source.key};",
      );
    }
    await _installRelationQueueTriggers();
  }

  Future<void> _installRelationQueueTriggers() async {
    const triggers = [
      "CREATE TRIGGER IF NOT EXISTS search_queue_task_tags_ai AFTER INSERT ON task_tags BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('task',new.task_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_task_tags_ad AFTER DELETE ON task_tags BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('task',old.task_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_note_tags_ai AFTER INSERT ON knowledge_note_tags BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('note',new.note_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_note_tags_ad AFTER DELETE ON knowledge_note_tags BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('note',old.note_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_attachment_labels_ai AFTER INSERT ON attachment_label_map BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('attachment',new.attachment_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_attachment_labels_ad AFTER DELETE ON attachment_label_map BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('attachment',old.attachment_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_document_metadata_ai AFTER INSERT ON document_metadata BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('document',new.document_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_document_metadata_au AFTER UPDATE ON document_metadata BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('document',new.document_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_document_metadata_ad AFTER DELETE ON document_metadata BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) VALUES ('document',old.document_id); END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_tags_au AFTER UPDATE ON tags BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) SELECT 'task',task_id FROM task_tags WHERE tag_id=new.id; END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_knowledge_tags_au AFTER UPDATE ON knowledge_tags BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) SELECT 'note',note_id FROM knowledge_note_tags WHERE tag_id=new.id; END;",
      "CREATE TRIGGER IF NOT EXISTS search_queue_attachment_labels_au AFTER UPDATE ON attachment_labels BEGIN INSERT OR IGNORE INTO search_index_queue(entity_type,entity_id) SELECT 'attachment',attachment_id FROM attachment_label_map WHERE label_id=new.id; END;",
    ];
    for (final statement in triggers) {
      await customStatement(statement);
    }
  }
}

final class VerifiedSearchDatabaseSession {
  const VerifiedSearchDatabaseSession._(this.database);
  final AppDatabase database;
}
