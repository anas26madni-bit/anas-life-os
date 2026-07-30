import 'dart:io';
import 'dart:typed_data';

import 'package:anas_life_os/core/database/database_connection_factory.dart';
import 'package:anas_life_os/core/database/database_key.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';
import 'package:anas_life_os/features/database_foundation/data/repositories/drift_plugin_registry_repository.dart';
import 'package:anas_life_os/features/database_foundation/domain/entities/plugin_descriptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('encrypted database persists and reopens on Android 11', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp('anas_life_os_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}integration.db',
    );
    final key = DatabaseKey(
      Uint8List.fromList(List<int>.generate(32, (index) => index + 1)),
    );

    var database = AppDatabase(
      DatabaseConnectionFactory.openFile(file: file, key: key),
    );
    final repository = DriftPluginRegistryRepository(database);
    final timestamp = DateTime.utc(2026, 7, 30);
    await repository.save(
      PluginDescriptor(
        uuid: '00000000-0000-7000-8000-000000000001',
        name: 'encrypted.descriptor',
        version: '1.0.0',
        enabled: false,
        installedAt: timestamp,
        updatedAt: timestamp,
        requiredPermissions: const [],
      ),
    );
    await database.close();

    final rawBytes = await file.readAsBytes();
    expect(
      String.fromCharCodes(rawBytes).contains('encrypted.descriptor'),
      isFalse,
    );

    database = AppDatabase(
      DatabaseConnectionFactory.openFile(file: file, key: key),
    );
    addTearDown(database.close);
    final reopened = DriftPluginRegistryRepository(database);
    expect(
      (await reopened.findByName('encrypted.descriptor'))?.version,
      '1.0.0',
    );
    await database.verifyIntegrity();
  });
}
