import 'package:drift/drift.dart';

import '../../../../core/database/database_connection_factory.dart';
import '../../../../core/database/database_constants.dart';
import '../../../../core/database/database_key.dart';
import '../tables/migration_history_table.dart';
import '../tables/plugin_registry_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [MigrationHistory, PluginRegistry])
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
