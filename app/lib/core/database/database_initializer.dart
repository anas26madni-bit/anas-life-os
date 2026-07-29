import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:sqlite3/sqlite3.dart';

import '../logging/app_logger.dart';
import 'database_foundation_status.dart';

@lazySingleton
class DatabaseInitializer {
  DatabaseInitializer(this._logger);

  final AppLogger _logger;

  Future<DatabaseFoundationReport> verifyFoundation() async {
    Database? database;
    try {
      database = sqlite3.openInMemory();
      final ephemeralKey = _createEphemeralKey();
      database.execute("PRAGMA key = \"x'$ephemeralKey'\";");
      database.execute('PRAGMA foreign_keys = ON;');

      final cipherRows = database.select('PRAGMA cipher_version;');
      if (cipherRows.isEmpty) {
        throw StateError('SQLCipher capability is unavailable.');
      }

      final foreignKeys = database.select('PRAGMA foreign_keys;');
      if (foreignKeys.single.values.single != 1) {
        throw StateError('SQLite foreign-key enforcement is unavailable.');
      }

      final integrity = database.select('PRAGMA quick_check;');
      if (integrity.single.values.single != 'ok') {
        throw StateError('SQLite integrity verification failed.');
      }

      final engineVersion =
          database.select('SELECT sqlite_version();').single.values.single;
      final cipherVersion = cipherRows.single.values.single;
      _logger.info(
        'Database foundation verified',
        context: {
          'engineVersion': engineVersion,
          'cipherVersion': cipherVersion,
        },
      );
      return DatabaseFoundationReport(
        status: DatabaseFoundationStatus.ready,
        engineVersion: '$engineVersion',
        cipherVersion: '$cipherVersion',
      );
    } on SqliteException catch (error, stackTrace) {
      _logger.error(
        'Database foundation verification failed',
        error: error,
        stackTrace: stackTrace,
      );
      return const DatabaseFoundationReport(
        status: DatabaseFoundationStatus.unavailable,
        failureCode: 'database_engine_unavailable',
      );
    } on StateError catch (error, stackTrace) {
      _logger.error(
        'Database foundation requirement was not met',
        error: error,
        stackTrace: stackTrace,
      );
      return const DatabaseFoundationReport(
        status: DatabaseFoundationStatus.unavailable,
        failureCode: 'database_capability_missing',
      );
    } finally {
      database?.dispose();
    }
  }

  String _createEphemeralKey() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
