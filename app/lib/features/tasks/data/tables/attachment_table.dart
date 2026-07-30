import 'package:drift/drift.dart';

import '../../../../core/database/tables/business_entity_table.dart';
import 'project_tables.dart';
import 'task_table.dart';

@DataClassName('AttachmentRow')
@TableIndex(name: 'idx_attachments_task_created', columns: {#taskId, #createdAt})
@TableIndex(name: 'idx_attachments_project_created', columns: {#projectId, #createdAt})
@TableIndex(name: 'idx_attachments_checksum', columns: {#checksumSha256})
class Attachments extends BusinessEntityTable {
  IntColumn get taskId => integer().nullable().references(Tasks, #id)();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  TextColumn get fileName => text().withLength(min: 1, max: 500)();
  TextColumn get originalFileName => text().nullable()();
  TextColumn get extension => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get storagePath => text().withLength(min: 1, max: 2000)();
  IntColumn get fileSize => integer()();
  TextColumn get checksumSha256 => text().withLength(min: 64, max: 64)();
  BoolColumn get isEncrypted => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
}