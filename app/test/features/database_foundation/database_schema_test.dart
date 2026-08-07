import 'package:anas_life_os/core/database/database_constants.dart';
import 'package:anas_life_os/core/database/database_key.dart';
import 'package:anas_life_os/core/database/lifecycle_column_profile.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('creates the approved schema through Sprint 5 with indexes', () async {
    final database = createTestDatabase();
    addTearDown(database.close);

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name;",
        )
        .get();
    expect(
      tables.map((row) => row.read<String>('name')),
      containsAll(<String>[
        'attachments',
        'attachment_folders',
        'attachment_label_map',
        'attachment_labels',
        'attachment_preview_cache',
        'attachment_versions',
        'categories',
        'checklist_items',
        'checklists',
        'custom_field_values',
        'custom_fields',
        'document_folders',
        'document_metadata',
        'document_versions',
        'documents',
        'knowledge_folders',
        'knowledge_links',
        'knowledge_note_tags',
        'knowledge_notes',
        'knowledge_spaces',
        'knowledge_tags',
        'knowledge_versions',
        'migration_history',
        'plugin_registry',
        'projects',
        'repeat_rules',
        'reminder_history',
        'reminders',
        'subcategories',
        'tags',
        'task_dependencies',
        'task_history',
        'task_state_history',
        'task_tags',
        'tasks',
      ]),
    );

    final indexes = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name LIKE 'idx_%' ORDER BY name;",
        )
        .get();
    expect(
      indexes.map((row) => row.read<String>('name')),
      containsAll(<String>[
        'idx_migration_history_status_started_at',
        'idx_plugin_registry_name',
        'idx_tasks_status_due',
        'idx_tasks_project_status',
        'idx_tasks_parent_sort',
        'idx_task_dependencies_pair',
        'idx_reminders_schedule',
        'idx_reminders_task',
        'idx_reminder_history_occurrence_action',
        'idx_knowledge_notes_space_updated',
        'idx_knowledge_notes_type_status',
        'idx_knowledge_versions_note_version',
        'idx_documents_folder_updated',
        'idx_attachment_versions_attachment_version',
      ]),
    );

    final migrationColumns = await database
        .customSelect('PRAGMA table_info(migration_history);')
        .get();
    expect(migrationColumns.map((row) => row.read<String>('name')), [
      'id',
      'uuid',
      'from_version',
      'to_version',
      'migration_name',
      'started_at',
      'completed_at',
      'status',
    ]);

    final pluginColumns = await database
        .customSelect('PRAGMA table_info(plugin_registry);')
        .get();
    expect(pluginColumns.map((row) => row.read<String>('name')), [
      'id',
      'uuid',
      'plugin_name',
      'plugin_version',
      'enabled',
      'install_date',
      'last_update',
      'required_permissions',
    ]);

    final foreignKeys = await database
        .customSelect('PRAGMA foreign_keys;')
        .getSingle();
    expect(foreignKeys.read<int>('foreign_keys'), 1);

    final plan = await database
        .customSelect(
          'EXPLAIN QUERY PLAN '
          'SELECT * FROM plugin_registry WHERE plugin_name = ?;',
          variables: [Variable.withString('core.descriptor')],
        )
        .get();
    expect(
      plan.single.read<String>('detail'),
      contains('idx_plugin_registry_name'),
    );

    final version = await database
        .customSelect('PRAGMA user_version;')
        .getSingle();
    expect(version.read<int>('user_version'), DatabaseConstants.schemaVersion);
    await database.verifyIntegrity();
  });

  test('defines the approved column profiles without forcing one profile', () {
    expect(
      LifecycleColumnProfile.businessEntity,
      containsAll({
        'id',
        'uuid',
        'created_at',
        'updated_at',
        'deleted_at',
        'is_deleted',
        'sync_status',
        'version',
        'created_by',
        'updated_by',
        'notes',
      }),
    );
    expect(LifecycleColumnProfile.history, isNot(contains('is_deleted')));
    expect(LifecycleColumnProfile.schema, isNot(contains('deleted_at')));
  });

  test('rejects database keys that are not 256 bits', () {
    expect(() => DatabaseKey(Uint8List(31)), throwsArgumentError);
    expect(DatabaseKey(Uint8List(32)).hexadecimal, hasLength(64));
  });
}
