import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

import 'database_key.dart';

abstract final class DatabaseConnectionFactory {
  static QueryExecutor openFile({
    required File file,
    required DatabaseKey key,
  }) => NativeDatabase.createInBackground(
    file,
    setup: (database) => _configure(database, key),
  );

  static QueryExecutor openInMemory(DatabaseKey key) =>
      NativeDatabase.memory(setup: (database) => _configure(database, key));

  static void _configure(Database database, DatabaseKey key) {
    database.execute("PRAGMA key = \"x'${key.hexadecimal}'\";");
    database.execute('PRAGMA cipher_memory_security = ON;');
    database.execute('PRAGMA foreign_keys = ON;');
    database.execute('PRAGMA busy_timeout = 5000;');
  }
}
