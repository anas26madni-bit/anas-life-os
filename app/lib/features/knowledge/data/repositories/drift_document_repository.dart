import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/knowledge_document.dart';
import '../../domain/repositories/document_repository.dart';
import '../../domain/services/document_validator.dart';

final class DriftDocumentRepository implements DocumentRepository {
  DriftDocumentRepository(
    this._database, {
    this.validator = const DocumentValidator(),
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final DocumentValidator validator;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  @override
  Future<Result<KnowledgeDocument>> create(KnowledgeDocumentDraft draft) async {
    final failure = validator.validate(draft);
    if (failure != null) return FailureResult(failure);
    try {
      return await _database.transaction(() async {
        if (draft.folderId != null) {
          final folder =
              await (_database.select(_database.documentFolders)..where(
                    (row) =>
                        row.id.equals(draft.folderId!) &
                        row.isDeleted.equals(false),
                  ))
                  .getSingleOrNull();
          if (folder == null) {
            throw StateError('The document folder is invalid.');
          }
        }
        final now = _now;
        final documentId = await _database
            .into(_database.documents)
            .insert(
              DocumentsCompanion.insert(
                uuid: _uuidFactory(),
                title: draft.title.trim(),
                createdAt: now,
                updatedAt: now,
                folderId: Value(draft.folderId),
                hidden: Value(draft.hidden),
              ),
            );
        await _database
            .into(_database.attachments)
            .insert(
              AttachmentsCompanion.insert(
                uuid: _uuidFactory(),
                fileName: draft.fileName,
                storagePath: draft.storagePath,
                fileSize: draft.fileSize,
                checksumSha256: draft.checksumSha256.toLowerCase(),
                createdAt: now,
                updatedAt: now,
                documentId: Value(documentId),
                mimeType: Value(draft.mimeType),
                extension: Value(_extension(draft.fileName)),
                isHidden: Value(draft.hidden),
                isEncrypted: Value(draft.encrypted),
              ),
            );
        await _database
            .into(_database.documentVersions)
            .insert(
              DocumentVersionsCompanion.insert(
                uuid: _uuidFactory(),
                documentId: documentId,
                versionNumber: 1,
                storagePath: draft.storagePath,
                checksumSha256: draft.checksumSha256.toLowerCase(),
                fileSize: draft.fileSize,
                createdAt: now,
              ),
            );
        return Success(await _require(documentId));
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'document_create_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'document_create_failed',
          safeMessage: 'The document metadata could not be saved safely.',
        ),
      );
    }
  }

  @override
  Future<Result<List<KnowledgeDocument>>> list({
    String? query,
    int limit = 50,
    int offset = 0,
    bool includeHidden = false,
  }) async {
    if (limit < 1 || limit > 200 || offset < 0) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_document_page',
          safeMessage: 'The requested document page is invalid.',
        ),
      );
    }
    try {
      final joined = _database.select(_database.documents).join([
        innerJoin(
          _database.attachments,
          _database.attachments.documentId.equalsExp(_database.documents.id),
        ),
      ])..where(_database.documents.isDeleted.equals(false));
      if (!includeHidden) {
        joined.where(_database.documents.hidden.equals(false));
      }
      final term = query?.trim();
      if (term != null && term.isNotEmpty) {
        joined.where(
          _database.documents.title.contains(term) |
              _database.attachments.fileName.contains(term),
        );
      }
      joined
        ..orderBy([OrderingTerm.desc(_database.documents.updatedAt)])
        ..limit(limit, offset: offset);
      final rows = await joined.get();
      return Success(rows.map(_mapJoined).toList(growable: false));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'document_list_failed',
          safeMessage: 'Documents could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<KnowledgeDocument>> softDelete(int id) => _setDeleted(id, true);

  @override
  Future<Result<KnowledgeDocument>> restore(int id) => _setDeleted(id, false);

  Future<Result<KnowledgeDocument>> _setDeleted(int id, bool deleted) async {
    try {
      return await _database.transaction(() async {
        final current = await _requireDocument(id, includeDeleted: true);
        final now = _now;
        await (_database.update(
          _database.documents,
        )..where((row) => row.id.equals(id))).write(
          DocumentsCompanion(
            isDeleted: Value(deleted),
            deletedAt: Value(deleted ? now : null),
            updatedAt: Value(now),
            version: Value(current.version + 1),
          ),
        );
        await (_database.update(
          _database.attachments,
        )..where((row) => row.documentId.equals(id))).write(
          AttachmentsCompanion(
            isDeleted: Value(deleted),
            deletedAt: Value(deleted ? now : null),
            updatedAt: Value(now),
          ),
        );
        return Success(await _require(id, includeDeleted: deleted));
      });
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'document_state_failed',
          safeMessage: 'The document state could not be changed safely.',
        ),
      );
    }
  }

  Future<DocumentRow> _requireDocument(
    int id, {
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.documents)
      ..where((row) => row.id.equals(id));
    if (!includeDeleted) query.where((row) => row.isDeleted.equals(false));
    final row = await query.getSingleOrNull();
    if (row == null) throw StateError('The document does not exist.');
    return row;
  }

  Future<KnowledgeDocument> _require(
    int id, {
    bool includeDeleted = false,
  }) async {
    final joined = _database.select(_database.documents).join([
      innerJoin(
        _database.attachments,
        _database.attachments.documentId.equalsExp(_database.documents.id),
      ),
    ])..where(_database.documents.id.equals(id));
    if (!includeDeleted) {
      joined.where(_database.documents.isDeleted.equals(false));
    }
    return _mapJoined(await joined.getSingle());
  }

  KnowledgeDocument _mapJoined(TypedResult row) {
    final document = row.readTable(_database.documents);
    final attachment = row.readTable(_database.attachments);
    return KnowledgeDocument(
      id: document.id,
      uuid: document.uuid,
      folderId: document.folderId,
      title: document.title,
      fileName: attachment.fileName,
      mimeType: attachment.mimeType ?? 'application/octet-stream',
      storagePath: attachment.storagePath,
      fileSize: attachment.fileSize,
      checksumSha256: attachment.checksumSha256,
      hidden: attachment.isHidden,
      encrypted: attachment.isEncrypted,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(
        document.createdAt,
        isUtc: true,
      ),
    );
  }

  String _extension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    return dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
  }

  int get _now => _clock().toUtc().microsecondsSinceEpoch;
}
