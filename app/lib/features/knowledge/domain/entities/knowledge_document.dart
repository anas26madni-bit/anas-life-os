final class KnowledgeDocument {
  const KnowledgeDocument({
    required this.id,
    required this.uuid,
    required this.title,
    required this.fileName,
    required this.mimeType,
    required this.storagePath,
    required this.fileSize,
    required this.checksumSha256,
    required this.hidden,
    required this.encrypted,
    required this.createdAt,
    this.folderId,
  });

  final int id;
  final String uuid;
  final int? folderId;
  final String title;
  final String fileName;
  final String mimeType;
  final String storagePath;
  final int fileSize;
  final String checksumSha256;
  final bool hidden;
  final bool encrypted;
  final DateTime createdAt;
}

final class KnowledgeDocumentDraft {
  const KnowledgeDocumentDraft({
    required this.title,
    required this.fileName,
    required this.mimeType,
    required this.storagePath,
    required this.fileSize,
    required this.checksumSha256,
    required this.availableBytes,
    this.folderId,
    this.hidden = false,
    this.encrypted = false,
  });

  final int? folderId;
  final String title;
  final String fileName;
  final String mimeType;
  final String storagePath;
  final int fileSize;
  final String checksumSha256;
  final int availableBytes;
  final bool hidden;
  final bool encrypted;
}
