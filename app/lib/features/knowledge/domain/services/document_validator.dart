import '../../../../core/errors/failure.dart';
import '../entities/knowledge_document.dart';

final class DocumentValidator {
  const DocumentValidator();

  static const supportedExtensions = <String>{
    'jpg', 'jpeg', 'png', 'webp', 'gif', 'pdf', 'doc', 'docx', 'xls',
    'xlsx', 'mp4', 'webm', 'mp3', 'wav', 'm4a', 'zip',
  };

  ValidationFailure? validate(KnowledgeDocumentDraft draft) {
    if (draft.title.trim().isEmpty || draft.title.trim().length > 300) {
      return const ValidationFailure(
        code: 'invalid_document_title',
        safeMessage: 'Enter a document title of 300 characters or fewer.',
      );
    }
    if (draft.fileSize < 1 || draft.availableBytes < draft.fileSize) {
      return const ValidationFailure(
        code: 'document_storage_unavailable',
        safeMessage: 'There is not enough device storage for this document.',
      );
    }
    if (!RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(draft.checksumSha256)) {
      return const ValidationFailure(
        code: 'invalid_document_checksum',
        safeMessage: 'The document integrity checksum is invalid.',
      );
    }
    final dot = draft.fileName.lastIndexOf('.');
    final extension = dot < 0
        ? ''
        : draft.fileName.substring(dot + 1).toLowerCase();
    if (!supportedExtensions.contains(extension)) {
      return const ValidationFailure(
        code: 'unsupported_document_type',
        safeMessage: 'This document type is not supported offline.',
      );
    }
    return null;
  }
}
