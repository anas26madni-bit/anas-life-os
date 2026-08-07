import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/knowledge/data/repositories/drift_knowledge_repository.dart';
import 'package:anas_life_os/features/knowledge/domain/entities/knowledge_enums.dart';
import 'package:anas_life_os/features/knowledge/domain/entities/knowledge_note.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('persists notes, journal, wiki, search, favorites, and versions', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftKnowledgeRepository(
      database,
      clock: () => DateTime.utc(2026, 8, 7),
    );
    final spaceId = (await repository.ensureDefaultSpace() as Success<int>).value;
    final created = (await repository.create(
      KnowledgeNoteDraft(
        spaceId: spaceId,
        title: 'Offline wiki',
        content: 'Private linked knowledge',
        type: KnowledgeNoteType.wiki,
        format: KnowledgeContentFormat.markdown,
      ),
    ) as Success<KnowledgeNote>).value;

    final updated = (await repository.update(
      created.id,
      KnowledgeNoteDraft(
        spaceId: spaceId,
        title: 'Offline wiki',
        content: 'Private linked knowledge updated',
        type: KnowledgeNoteType.wiki,
        format: KnowledgeContentFormat.markdown,
      ),
    ) as Success<KnowledgeNote>).value;
    expect(updated.version, 2);
    expect(
      (await repository.versions(created.id)
              as Success<List<KnowledgeVersion>>)
          .value,
      hasLength(2),
    );
    expect(
      (await repository.list(query: 'updated')
              as Success<List<KnowledgeNote>>)
          .value
          .single
          .id,
      created.id,
    );
    expect(
      (await repository.setFavorite(created.id, true)
              as Success<KnowledgeNote>)
          .value
          .favorite,
      isTrue,
    );
  });

  test('enforces links, tags, and recoverable deletion', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftKnowledgeRepository(database);
    final spaceId = (await repository.ensureDefaultSpace() as Success<int>).value;
    Future<KnowledgeNote> note(String title) async =>
        (await repository.create(
              KnowledgeNoteDraft(spaceId: spaceId, title: title, content: ''),
            )
            as Success<KnowledgeNote>)
            .value;
    final first = await note('First');
    final second = await note('Second');

    expect(await repository.replaceTags(first.id, ['Private', 'private']), isA<Success<void>>());
    expect(
      await repository.link(
        sourceNoteId: first.id,
        targetNoteId: second.id,
        type: KnowledgeLinkType.wiki,
      ),
      isA<Success<void>>(),
    );
    expect(
      await repository.link(
        sourceNoteId: first.id,
        targetNoteId: first.id,
        type: KnowledgeLinkType.reference,
      ),
      isA<FailureResult<void>>(),
    );
    expect(
      (await repository.softDelete(first.id) as Success<KnowledgeNote>)
          .value
          .isDeleted,
      isTrue,
    );
    expect(
      (await repository.restore(first.id) as Success<KnowledgeNote>)
          .value
          .isDeleted,
      isFalse,
    );
  });
}
