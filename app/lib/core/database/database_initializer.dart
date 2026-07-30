import 'dart:math';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../features/database_foundation/data/database/app_database.dart';
import '../logging/app_logger.dart';
import 'database_key.dart';
import 'database_foundation_status.dart';

@lazySingleton
class DatabaseInitializer {
  DatabaseInitializer(this._logger);

  final AppLogger _logger;

  Future<DatabaseFoundationReport> verifyFoundation() async {
    AppDatabase? database;
    try {
      database = AppDatabase.inMemory(_createEphemeralKey());

      final cipherRows = await database
          .customSelect('PRAGMA cipher_version;')
          .get();
      if (cipherRows.isEmpty) {
        throw StateError('SQLCipher capability is unavailable.');
      }

      final foreignKeys = await database
          .customSelect('PRAGMA foreign_keys;')
          .getSingle();
      if (foreignKeys.read<int>('foreign_keys') != 1) {
        throw StateError('SQLite foreign-key enforcement is unavailable.');
      }

      await database.verifyIntegrity();

      final engineVersion =
          (await database
                  .customSelect('SELECT sqlite_version() AS version;')
                  .getSingle())
              .read<String>('version');
      final cipherVersion = cipherRows.single.read<String>('cipher_version');
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
      await database?.close();
    }
  }

  DatabaseKey _createEphemeralKey() {
    final random = Random.secure();
    return DatabaseKey(
      Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256))),
    );
  }
}
