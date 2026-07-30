import 'database_key.dart';

abstract interface class DatabaseKeyProvider {
  Future<DatabaseKey> loadOrCreate();
}
