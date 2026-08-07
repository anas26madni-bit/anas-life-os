import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import '../../../knowledge/data/tables/document_tables.dart';
import '../../../knowledge/data/tables/knowledge_tables.dart';
import 'project_tables.dart';
import 'task_table.dart';

@DataClassName('AttachmentFolderRow')
@TableIndex(name: 'idx_attachment_folders_parent', columns: {#parentFolderId})
class AttachmentFolders extends BusinessEntityTable {
  IntColumn get parentFolderId =>
      integer().nullable().references(AttachmentFolders, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('AttachmentRow')
@TableIndex(
  name: 'idx_attachments_task_created',
  columns: {#taskId, #createdAt},
)
@TableIndex(
  name: 'idx_attachments_project_created',
  columns: {#projectId, #createdAt},
)
@TableIndex(name: 'idx_attachments_checksum', columns: {#checksumSha256})
class Attachments extends BusinessEntityTable {
  IntColumn get folderId =>
      integer().nullable().references(AttachmentFolders, #id)();
  IntColumn get taskId => integer().nullable().references(Tasks, #id)();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  IntColumn get knowledgeNoteId =>
      integer().nullable().references(KnowledgeNotes, #id)();
  IntColumn get documentId => integer().nullable().references(Documents, #id)();
  TextColumn get fileName => text().withLength(min: 1, max: 500)();
  TextColumn get originalFileName => text().nullable()();
  TextColumn get extension => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get storagePath => text().withLength(min: 1, max: 2000)();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get fileSize => integer()();
  TextColumn get checksumSha256 => text().withLength(min: 64, max: 64)();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  IntColumn get pageCount => integer().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isEncrypted => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
}

@DataClassName('AttachmentVersionRow')
@TableIndex(
  name: 'idx_attachment_versions_attachment_version',
  columns: {#attachmentId, #versionNumber},
  unique: true,
)
class AttachmentVersions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  IntColumn get attachmentId =>
      integer().references(Attachments, #id, onDelete: KeyAction.cascade)();
  IntColumn get versionNumber => integer()();
  TextColumn get storagePath => text().withLength(min: 1, max: 2000)();
  TextColumn get checksumSha256 => text().withLength(min: 64, max: 64)();
  IntColumn get createdAt => integer()();
}

@DataClassName('AttachmentPreviewRow')
@TableIndex(
  name: 'idx_attachment_previews_attachment',
  columns: {#attachmentId},
  unique: true,
)
class AttachmentPreviewCache extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  IntColumn get attachmentId =>
      integer().references(Attachments, #id, onDelete: KeyAction.cascade)();
  TextColumn get previewPath => text().withLength(min: 1, max: 2000)();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  BoolColumn get protected => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
}

@DataClassName('AttachmentLabelRow')
@TableIndex(name: 'idx_attachment_labels_name', columns: {#name}, unique: true)
class AttachmentLabels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get createdAt => integer()();
}

@DataClassName('AttachmentLabelMapRow')
@TableIndex(
  name: 'idx_attachment_label_map_pair',
  columns: {#attachmentId, #labelId},
  unique: true,
)
class AttachmentLabelMap extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attachmentId =>
      integer().references(Attachments, #id, onDelete: KeyAction.cascade)();
  IntColumn get labelId => integer().references(
    AttachmentLabels,
    #id,
    onDelete: KeyAction.cascade,
  )();
}
