import '../../../../core/errors/result.dart';
import '../entities/knowledge_document.dart';

abstract interface class DocumentRepository {
  Future<Result<KnowledgeDocument>> create(KnowledgeDocumentDraft draft);
  Future<Result<List<KnowledgeDocument>>> list({
    String? query,
    int limit = 50,
    int offset = 0,
    bool includeHidden = false,
  });
  Future<Result<KnowledgeDocument>> softDelete(int id);
  Future<Result<KnowledgeDocument>> restore(int id);
}
