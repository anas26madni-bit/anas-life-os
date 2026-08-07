import '../../../../core/errors/result.dart';
import '../entities/knowledge_enums.dart';
import '../entities/knowledge_note.dart';

abstract interface class KnowledgeRepository {
  Future<Result<int>> ensureDefaultSpace();
  Future<Result<KnowledgeNote>> create(KnowledgeNoteDraft draft);
  Future<Result<KnowledgeNote>> update(int id, KnowledgeNoteDraft draft);
  Future<Result<List<KnowledgeNote>>> list({
    KnowledgeNoteType? type,
    String? query,
    int limit = 50,
    int offset = 0,
  });
  Future<Result<KnowledgeNote?>> findById(int id);
  Future<Result<KnowledgeNote>> setFavorite(int id, bool favorite);
  Future<Result<KnowledgeNote>> softDelete(int id);
  Future<Result<KnowledgeNote>> restore(int id);
  Future<Result<List<KnowledgeVersion>>> versions(int noteId);
  Future<Result<void>> replaceTags(int noteId, List<String> tags);
  Future<Result<void>> link({
    required int sourceNoteId,
    required int targetNoteId,
    required KnowledgeLinkType type,
  });
}
