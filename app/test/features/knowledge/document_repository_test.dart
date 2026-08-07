import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/knowledge/data/repositories/drift_document_repository.dart';
import 'package:anas_life_os/features/knowledge/domain/entities/knowledge_document.dart';
import 'package:anas_life_os/features/knowledge/domain/services/document_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

const checksum =
    '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

KnowledgeDocumentDraft draft({
  int availableBytes = 2048,
  String fileName = 'private.pdf',
}) => KnowledgeDocumentDraft(
  title: 'Private document',
  fileName: fileName,
  mimeType: 'application/pdf',
  storagePath: 'managed/private.pdf',
  fileSize: 1024,
  checksumSha256: checksum,
  availableBytes: availableBytes,
  encrypted: true,
);

void main() {
  test('validates supported types, checksum, and low storage', () {
    const validator = DocumentValidator();
    expect(validator.validate(draft()), isNull);
    expect(
      validator.validate(draft(availableBytes: 10))?.code,
      'document_storage_unavailable',
    );
    expect(
      validator.validate(draft(fileName: 'unsafe.exe'))?.code,
      'unsupported_document_type',
    );
  });

  test(
    'persists metadata without storing file bytes and soft deletes',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftDocumentRepository(database);
      final created = await repository.create(draft());
      expect(created, isA<Success<KnowledgeDocument>>());
      final items =
          (await repository.list() as Success<List<KnowledgeDocument>>).value;
      expect(items.single.checksumSha256, checksum);
      expect(items.single.encrypted, isTrue);
      expect(
        await repository.softDelete(items.single.id),
        isA<Success<KnowledgeDocument>>(),
      );
      expect(
        (await repository.list() as Success<List<KnowledgeDocument>>).value,
        isEmpty,
      );
      expect(
        await repository.restore(items.single.id),
        isA<Success<KnowledgeDocument>>(),
      );
    },
  );
}
