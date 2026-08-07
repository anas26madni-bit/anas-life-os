import 'dart:io';
import 'dart:typed_data';

import 'package:anas_life_os/core/database/database_connection_factory.dart';
import 'package:anas_life_os/core/database/database_key.dart';
import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';
import 'package:anas_life_os/features/knowledge/data/repositories/drift_knowledge_repository.dart';
import 'package:anas_life_os/features/knowledge/domain/entities/knowledge_note.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('knowledge persists encrypted and offline on Android 11', (
    tester,
  ) async {
    final directory = await Directory.systemTemp.createTemp('knowledge_vault_');
    addTearDown(() => directory.delete(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}knowledge_vault.db',
    );
    final key = DatabaseKey(
      Uint8List.fromList(List<int>.generate(32, (index) => index + 23)),
    );
    var database = AppDatabase(
      DatabaseConnectionFactory.openFile(file: file, key: key),
    );
    var repository = DriftKnowledgeRepository(database);
    final spaceId = (await repository.ensureDefaultSpace() as Success<int>).value;
    final created = await repository.create(
      KnowledgeNoteDraft(
        spaceId: spaceId,
        title: 'Encrypted knowledge',
        content: 'Private offline content',
      ),
    );
    expect(created, isA<Success<KnowledgeNote>>());
    await database.close();

    expect(
      String.fromCharCodes(await file.readAsBytes()).contains(
        'Private offline content',
      ),
      isFalse,
    );
    database = AppDatabase(
      DatabaseConnectionFactory.openFile(file: file, key: key),
    );
    addTearDown(database.close);
    repository = DriftKnowledgeRepository(database);
    final notes = (await repository.list() as Success<List<KnowledgeNote>>).value;
    expect(notes.single.title, 'Encrypted knowledge');
    await database.verifyIntegrity();
  });
}
