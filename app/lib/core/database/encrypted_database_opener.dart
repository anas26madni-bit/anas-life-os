import '../../features/database_foundation/data/database/app_database.dart';
import 'database_connection_factory.dart';
import 'database_file_resolver.dart';
import 'database_key_provider.dart';

final class EncryptedDatabaseOpener {
  const EncryptedDatabaseOpener(
    this._fileResolver,
    this._keyProvider,
  );

  final DatabaseFileResolver _fileResolver;
  final DatabaseKeyProvider _keyProvider;

  Future<AppDatabase> open() async {
    final file = await _fileResolver.resolve();
    final key = await _keyProvider.loadOrCreate();
    return AppDatabase(
      DatabaseConnectionFactory.openFile(file: file, key: key),
    );
  }
}
