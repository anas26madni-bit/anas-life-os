import 'knowledge_enums.dart';

final class KnowledgeNote {
  const KnowledgeNote({
    required this.id,
    required this.uuid,
    required this.spaceId,
    required this.title,
    required this.content,
    required this.type,
    required this.format,
    required this.status,
    required this.favorite,
    required this.pinned,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.folderId,
    this.summary,
  });

  final int id;
  final String uuid;
  final int spaceId;
  final int? folderId;
  final String title;
  final String content;
  final String? summary;
  final KnowledgeNoteType type;
  final KnowledgeContentFormat format;
  final KnowledgeNoteStatus status;
  final bool favorite;
  final bool pinned;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
}

final class KnowledgeNoteDraft {
  const KnowledgeNoteDraft({
    required this.spaceId,
    required this.title,
    required this.content,
    this.folderId,
    this.summary,
    this.type = KnowledgeNoteType.note,
    this.format = KnowledgeContentFormat.richText,
    this.status = KnowledgeNoteStatus.active,
    this.favorite = false,
    this.pinned = false,
  });

  final int spaceId;
  final int? folderId;
  final String title;
  final String content;
  final String? summary;
  final KnowledgeNoteType type;
  final KnowledgeContentFormat format;
  final KnowledgeNoteStatus status;
  final bool favorite;
  final bool pinned;
}

final class KnowledgeVersion {
  const KnowledgeVersion({
    required this.versionNumber,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  final int versionNumber;
  final String title;
  final String content;
  final DateTime createdAt;
}
