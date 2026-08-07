import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import '../../../tasks/data/tables/project_tables.dart';
import '../../../tasks/data/tables/task_table.dart';
import '../../domain/entities/knowledge_enums.dart';

@DataClassName('KnowledgeSpaceRow')
@TableIndex(name: 'idx_knowledge_spaces_name', columns: {#name})
class KnowledgeSpaces extends BusinessEntityTable {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('KnowledgeFolderRow')
@TableIndex(
  name: 'idx_knowledge_folders_space_parent',
  columns: {#spaceId, #parentFolderId},
)
class KnowledgeFolders extends BusinessEntityTable {
  IntColumn get spaceId => integer().references(KnowledgeSpaces, #id)();
  IntColumn get parentFolderId =>
      integer().nullable().references(KnowledgeFolders, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('KnowledgeNoteRow')
@TableIndex(
  name: 'idx_knowledge_notes_space_updated',
  columns: {#spaceId, #updatedAt},
)
@TableIndex(
  name: 'idx_knowledge_notes_folder_updated',
  columns: {#folderId, #updatedAt},
)
@TableIndex(
  name: 'idx_knowledge_notes_type_status',
  columns: {#noteType, #status},
)
@TableIndex(name: 'idx_knowledge_notes_title', columns: {#title})
class KnowledgeNotes extends BusinessEntityTable {
  IntColumn get spaceId => integer().references(KnowledgeSpaces, #id)();
  IntColumn get folderId =>
      integer().nullable().references(KnowledgeFolders, #id)();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  IntColumn get taskId => integer().nullable().references(Tasks, #id)();
  TextColumn get title => text().withLength(min: 1, max: 300)();
  TextColumn get content => text()();
  TextColumn get summary => text().nullable()();
  TextColumn get noteType => textEnum<KnowledgeNoteType>()();
  TextColumn get contentFormat => textEnum<KnowledgeContentFormat>()();
  TextColumn get status => textEnum<KnowledgeNoteStatus>()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  IntColumn get readingMinutes => integer().withDefault(const Constant(0))();
  IntColumn get attachmentCount => integer().withDefault(const Constant(0))();
}

@DataClassName('KnowledgeTagRow')
@TableIndex(name: 'idx_knowledge_tags_name', columns: {#name}, unique: true)
class KnowledgeTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

@DataClassName('KnowledgeNoteTagRow')
@TableIndex(
  name: 'idx_knowledge_note_tags_pair',
  columns: {#noteId, #tagId},
  unique: true,
)
class KnowledgeNoteTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId =>
      integer().references(KnowledgeNotes, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(KnowledgeTags, #id, onDelete: KeyAction.cascade)();
}

@DataClassName('KnowledgeLinkRow')
@TableIndex(
  name: 'idx_knowledge_links_pair',
  columns: {#sourceNoteId, #targetNoteId, #linkType},
  unique: true,
)
class KnowledgeLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  @ReferenceName('outgoingKnowledgeLinks')
  IntColumn get sourceNoteId =>
      integer().references(KnowledgeNotes, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('incomingKnowledgeLinks')
  IntColumn get targetNoteId =>
      integer().references(KnowledgeNotes, #id, onDelete: KeyAction.cascade)();
  TextColumn get linkType => textEnum<KnowledgeLinkType>()();
  IntColumn get createdAt => integer()();
}

@DataClassName('KnowledgeVersionRow')
@TableIndex(
  name: 'idx_knowledge_versions_note_version',
  columns: {#noteId, #versionNumber},
  unique: true,
)
class KnowledgeVersions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  IntColumn get noteId =>
      integer().references(KnowledgeNotes, #id, onDelete: KeyAction.cascade)();
  IntColumn get versionNumber => integer()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get summary => text().nullable()();
  IntColumn get createdAt => integer()();
}
