import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/knowledge_enums.dart';
import '../../domain/entities/knowledge_note.dart';
import '../../domain/repositories/knowledge_repository.dart';

final class DriftKnowledgeRepository implements KnowledgeRepository {
  DriftKnowledgeRepository(
    this._database, {
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  @override
  Future<Result<int>> ensureDefaultSpace() async {
    try {
      final existing =
          await (_database.select(_database.knowledgeSpaces)
                ..where((row) => row.isDeleted.equals(false))
                ..orderBy([(row) => OrderingTerm.asc(row.id)])
                ..limit(1))
              .getSingleOrNull();
      if (existing != null) return Success(existing.id);
      final now = _now;
      final id = await _database
          .into(_database.knowledgeSpaces)
          .insert(
            KnowledgeSpacesCompanion.insert(
              uuid: _uuidFactory(),
              name: 'Personal',
              createdAt: now,
              updatedAt: now,
            ),
          );
      return Success(id);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_space_failed',
          safeMessage: 'The private knowledge space could not be prepared.',
        ),
      );
    }
  }

  @override
  Future<Result<KnowledgeNote>> create(KnowledgeNoteDraft draft) async {
    final validation = _validate(draft);
    if (validation != null) return FailureResult(validation);
    try {
      return await _database.transaction(() async {
        await _requireSpace(draft.spaceId);
        await _validateFolder(draft.spaceId, draft.folderId);
        final now = _now;
        final id = await _database
            .into(_database.knowledgeNotes)
            .insert(
              KnowledgeNotesCompanion.insert(
                uuid: _uuidFactory(),
                spaceId: draft.spaceId,
                title: draft.title.trim(),
                content: draft.content,
                noteType: draft.type,
                contentFormat: draft.format,
                status: draft.status,
                createdAt: now,
                updatedAt: now,
                folderId: Value(draft.folderId),
                summary: Value(_blankToNull(draft.summary)),
                favorite: Value(draft.favorite),
                pinned: Value(draft.pinned),
                wordCount: Value(_wordCount(draft.content)),
                readingMinutes: Value(_readingMinutes(draft.content)),
              ),
            );
        await _appendVersion(id, 1, draft, now);
        return Success(await _require(id));
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'knowledge_create_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_create_failed',
          safeMessage: 'The note could not be saved safely.',
        ),
      );
    }
  }

  @override
  Future<Result<KnowledgeNote>> update(int id, KnowledgeNoteDraft draft) async {
    final validation = _validate(draft);
    if (validation != null) return FailureResult(validation);
    try {
      return await _database.transaction(() async {
        final current = await _requireRow(id);
        await _requireSpace(draft.spaceId);
        await _validateFolder(draft.spaceId, draft.folderId);
        final now = _now;
        final nextVersion = current.version + 1;
        await (_database.update(
          _database.knowledgeNotes,
        )..where((row) => row.id.equals(id))).write(
          KnowledgeNotesCompanion(
            spaceId: Value(draft.spaceId),
            folderId: Value(draft.folderId),
            title: Value(draft.title.trim()),
            content: Value(draft.content),
            summary: Value(_blankToNull(draft.summary)),
            noteType: Value(draft.type),
            contentFormat: Value(draft.format),
            status: Value(draft.status),
            favorite: Value(draft.favorite),
            pinned: Value(draft.pinned),
            wordCount: Value(_wordCount(draft.content)),
            readingMinutes: Value(_readingMinutes(draft.content)),
            updatedAt: Value(now),
            version: Value(nextVersion),
          ),
        );
        await _appendVersion(id, nextVersion, draft, now);
        return Success(await _require(id));
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'knowledge_update_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_update_failed',
          safeMessage: 'The note could not be updated safely.',
        ),
      );
    }
  }

  @override
  Future<Result<List<KnowledgeNote>>> list({
    KnowledgeNoteType? type,
    String? query,
    int limit = 50,
    int offset = 0,
  }) async {
    if (limit < 1 || limit > 200 || offset < 0) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_knowledge_page',
          safeMessage: 'The requested knowledge page is invalid.',
        ),
      );
    }
    try {
      final select = _database.select(_database.knowledgeNotes)
        ..where((row) => row.isDeleted.equals(false));
      if (type != null) select.where((row) => row.noteType.equalsValue(type));
      final term = query?.trim();
      if (term != null && term.isNotEmpty) {
        select.where(
          (row) => row.title.contains(term) | row.content.contains(term),
        );
      }
      select
        ..orderBy([
          (row) => OrderingTerm.desc(row.pinned),
          (row) => OrderingTerm.desc(row.updatedAt),
          (row) => OrderingTerm.asc(row.id),
        ])
        ..limit(limit, offset: offset);
      return Success((await select.get()).map(_map).toList(growable: false));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_list_failed',
          safeMessage: 'Knowledge notes could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<KnowledgeNote?>> findById(int id) async {
    try {
      final row =
          await (_database.select(_database.knowledgeNotes)..where(
                (row) => row.id.equals(id) & row.isDeleted.equals(false),
              ))
              .getSingleOrNull();
      return Success(row == null ? null : _map(row));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_read_failed',
          safeMessage: 'The note could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<KnowledgeNote>> setFavorite(int id, bool favorite) =>
      _setLifecycle(id, favorite: favorite);

  @override
  Future<Result<KnowledgeNote>> softDelete(int id) =>
      _setLifecycle(id, deleted: true);

  @override
  Future<Result<KnowledgeNote>> restore(int id) =>
      _setLifecycle(id, deleted: false);

  Future<Result<KnowledgeNote>> _setLifecycle(
    int id, {
    bool? favorite,
    bool? deleted,
  }) async {
    try {
      final current = await _requireRow(id, includeDeleted: true);
      final now = _now;
      await (_database.update(
        _database.knowledgeNotes,
      )..where((row) => row.id.equals(id))).write(
        KnowledgeNotesCompanion(
          favorite: favorite == null ? const Value.absent() : Value(favorite),
          isDeleted: deleted == null ? const Value.absent() : Value(deleted),
          deletedAt: deleted == null
              ? const Value.absent()
              : Value(deleted ? now : null),
          updatedAt: Value(now),
          version: Value(current.version + 1),
        ),
      );
      return Success(await _require(id, includeDeleted: deleted == true));
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'knowledge_state_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_state_failed',
          safeMessage: 'The note state could not be changed safely.',
        ),
      );
    }
  }

  @override
  Future<Result<List<KnowledgeVersion>>> versions(int noteId) async {
    try {
      await _requireRow(noteId, includeDeleted: true);
      final rows =
          await (_database.select(_database.knowledgeVersions)
                ..where((row) => row.noteId.equals(noteId))
                ..orderBy([(row) => OrderingTerm.desc(row.versionNumber)]))
              .get();
      return Success(
        rows
            .map(
              (row) => KnowledgeVersion(
                versionNumber: row.versionNumber,
                title: row.title,
                content: row.content,
                createdAt: _date(row.createdAt),
              ),
            )
            .toList(growable: false),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_versions_failed',
          safeMessage: 'Version history could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> replaceTags(int noteId, List<String> tags) async {
    final normalized = tags
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toSet();
    if (normalized.any((tag) => tag.length > 100)) {
      return const FailureResult(
        ValidationFailure(
          code: 'knowledge_tag_too_long',
          safeMessage: 'Tags must be 100 characters or fewer.',
        ),
      );
    }
    try {
      await _database.transaction(() async {
        await _requireRow(noteId);
        await (_database.delete(
          _database.knowledgeNoteTags,
        )..where((row) => row.noteId.equals(noteId))).go();
        for (final name in normalized) {
          var tag = await (_database.select(
            _database.knowledgeTags,
          )..where((row) => row.name.equals(name))).getSingleOrNull();
          if (tag == null) {
            final now = _now;
            final id = await _database
                .into(_database.knowledgeTags)
                .insert(
                  KnowledgeTagsCompanion.insert(
                    uuid: _uuidFactory(),
                    name: name,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
            tag = await (_database.select(
              _database.knowledgeTags,
            )..where((row) => row.id.equals(id))).getSingle();
          }
          await _database
              .into(_database.knowledgeNoteTags)
              .insert(
                KnowledgeNoteTagsCompanion.insert(
                  noteId: noteId,
                  tagId: tag.id,
                ),
              );
        }
        await _recountTags();
      });
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_tags_failed',
          safeMessage: 'Tags could not be saved safely.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> link({
    required int sourceNoteId,
    required int targetNoteId,
    required KnowledgeLinkType type,
  }) async {
    if (sourceNoteId == targetNoteId) {
      return const FailureResult(
        ValidationFailure(
          code: 'knowledge_self_link',
          safeMessage: 'A note cannot link to itself.',
        ),
      );
    }
    try {
      await _database.transaction(() async {
        await _requireRow(sourceNoteId);
        await _requireRow(targetNoteId);
        await _database
            .into(_database.knowledgeLinks)
            .insert(
              KnowledgeLinksCompanion.insert(
                uuid: _uuidFactory(),
                sourceNoteId: sourceNoteId,
                targetNoteId: targetNoteId,
                linkType: type,
                createdAt: _now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      });
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'knowledge_link_failed',
          safeMessage: 'The note link could not be saved safely.',
        ),
      );
    }
  }

  ValidationFailure? _validate(KnowledgeNoteDraft draft) {
    if (draft.title.trim().isEmpty || draft.title.trim().length > 300) {
      return const ValidationFailure(
        code: 'invalid_knowledge_title',
        safeMessage: 'Enter a title of 300 characters or fewer.',
      );
    }
    return null;
  }

  Future<void> _requireSpace(int id) async {
    final row =
        await (_database.select(_database.knowledgeSpaces)
              ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
            .getSingleOrNull();
    if (row == null) throw StateError('The knowledge space does not exist.');
  }

  Future<void> _validateFolder(int spaceId, int? folderId) async {
    if (folderId == null) return;
    final row =
        await (_database.select(_database.knowledgeFolders)..where(
              (row) =>
                  row.id.equals(folderId) &
                  row.spaceId.equals(spaceId) &
                  row.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    if (row == null) throw StateError('The knowledge folder is invalid.');
  }

  Future<void> _appendVersion(
    int noteId,
    int version,
    KnowledgeNoteDraft draft,
    int now,
  ) => _database
      .into(_database.knowledgeVersions)
      .insert(
        KnowledgeVersionsCompanion.insert(
          uuid: _uuidFactory(),
          noteId: noteId,
          versionNumber: version,
          title: draft.title.trim(),
          content: draft.content,
          summary: Value(_blankToNull(draft.summary)),
          createdAt: now,
        ),
      );

  Future<void> _recountTags() async {
    final tags = await _database.select(_database.knowledgeTags).get();
    for (final tag in tags) {
      final countExpression = _database.knowledgeNoteTags.id.count();
      final count =
          await (_database.selectOnly(_database.knowledgeNoteTags)
                ..addColumns([countExpression])
                ..where(_database.knowledgeNoteTags.tagId.equals(tag.id)))
              .map((row) => row.read(countExpression) ?? 0)
              .getSingle();
      await (_database.update(
        _database.knowledgeTags,
      )..where((row) => row.id.equals(tag.id))).write(
        KnowledgeTagsCompanion(
          usageCount: Value(count),
          updatedAt: Value(_now),
        ),
      );
    }
  }

  Future<KnowledgeNoteRow> _requireRow(
    int id, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.knowledgeNotes)
      ..where((row) => row.id.equals(id));
    if (!includeDeleted) query.where((row) => row.isDeleted.equals(false));
    final row = await query.getSingleOrNull();
    if (row == null) throw StateError('The knowledge note does not exist.');
    return row;
  }

  Future<KnowledgeNote> _require(int id, {bool includeDeleted = false}) async =>
      _map(await _requireRow(id, includeDeleted: includeDeleted));

  KnowledgeNote _map(KnowledgeNoteRow row) => KnowledgeNote(
    id: row.id,
    uuid: row.uuid,
    spaceId: row.spaceId,
    folderId: row.folderId,
    title: row.title,
    content: row.content,
    summary: row.summary,
    type: row.noteType,
    format: row.contentFormat,
    status: row.status,
    favorite: row.favorite,
    pinned: row.pinned,
    version: row.version,
    createdAt: _date(row.createdAt),
    updatedAt: _date(row.updatedAt),
    isDeleted: row.isDeleted,
  );

  int get _now => _clock().toUtc().microsecondsSinceEpoch;
  DateTime _date(int value) =>
      DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
  String? _blankToNull(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
  int _wordCount(String value) => value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .length;
  int _readingMinutes(String value) {
    final count = _wordCount(value);
    return count == 0 ? 0 : (count / 200).ceil();
  }
}
