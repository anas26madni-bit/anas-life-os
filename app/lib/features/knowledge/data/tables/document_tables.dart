import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';

@DataClassName('DocumentFolderRow')
@TableIndex(name: 'idx_document_folders_parent', columns: {#parentFolderId})
class DocumentFolders extends BusinessEntityTable {
  IntColumn get parentFolderId => integer().nullable().references(DocumentFolders, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('DocumentRow')
@TableIndex(name: 'idx_documents_folder_updated', columns: {#folderId, #updatedAt})
@TableIndex(name: 'idx_documents_title', columns: {#title})
class Documents extends BusinessEntityTable {
  IntColumn get folderId => integer().nullable().references(DocumentFolders, #id)();
  TextColumn get title => text().withLength(min: 1, max: 300)();
  TextColumn get description => text().nullable()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
}

@DataClassName('DocumentVersionRow')
@TableIndex(name: 'idx_document_versions_document_version', columns: {#documentId, #versionNumber}, unique: true)
class DocumentVersions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();
  IntColumn get documentId => integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  IntColumn get versionNumber => integer()();
  TextColumn get storagePath => text().withLength(min: 1, max: 2000)();
  TextColumn get checksumSha256 => text().withLength(min: 64, max: 64)();
  IntColumn get fileSize => integer()();
  IntColumn get createdAt => integer()();
}

@DataClassName('DocumentMetadataRow')
@TableIndex(name: 'idx_document_metadata_document_key', columns: {#documentId, #metadataKey}, unique: true)
class DocumentMetadata extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId => integer().references(Documents, #id, onDelete: KeyAction.cascade)();
  TextColumn get metadataKey => text().withLength(min: 1, max: 100)();
  TextColumn get metadataValue => text()();
}
