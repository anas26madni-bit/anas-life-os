import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/entities/task_support_drafts.dart';
import '../../domain/repositories/task_support_repository.dart';

final class DriftTaskSupportRepository implements TaskSupportRepository {
  DriftTaskSupportRepository(
    this._database, {
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  @override
  Future<Result<int>> createCategory(String name, {String? description}) async {
    final normalized = _requiredText(name, 200);
    if (normalized == null)
      return _invalid('invalid_category', 'Enter a category name.');
    try {
      final now = _now;
      final id = await _database
          .into(_database.categories)
          .insert(
            CategoriesCompanion.insert(
              uuid: _uuidFactory(),
              createdAt: now,
              updatedAt: now,
              name: normalized,
              description: Value(_optionalText(description)),
            ),
          );
      return Success(id);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'category_create_failed',
          safeMessage: 'The category could not be created safely.',
        ),
      );
    }
  }

  @override
  Future<Result<int>> createSubcategory({
    required int categoryId,
    required String name,
  }) async {
    final normalized = _requiredText(name, 200);
    if (categoryId <= 0 || normalized == null) {
      return _invalid('invalid_subcategory', 'Enter a valid subcategory.');
    }
    try {
      await _requireCategory(categoryId);
      final now = _now;
      final id = await _database
          .into(_database.subcategories)
          .insert(
            SubcategoriesCompanion.insert(
              uuid: _uuidFactory(),
              createdAt: now,
              updatedAt: now,
              categoryId: categoryId,
              name: normalized,
            ),
          );
      return Success(id);
    } on StateError catch (error) {
      return _rejected('subcategory_rejected', error);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'subcategory_create_failed',
          safeMessage: 'The subcategory could not be created safely.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> attachTag({
    required int taskId,
    required String name,
  }) async {
    final normalized = _requiredText(name, 100);
    if (taskId <= 0 || normalized == null) {
      return _invalid('invalid_tag', 'Enter a valid tag.');
    }
    try {
      return await _database.transaction(() async {
        await _requireTask(taskId);
        final existing = await (_database.select(
          _database.tags,
        )..where((row) => row.name.equals(normalized))).getSingleOrNull();
        final now = _now;
        final tagId =
            existing?.id ??
            await _database
                .into(_database.tags)
                .insert(
                  TagsCompanion.insert(
                    uuid: _uuidFactory(),
                    createdAt: now,
                    updatedAt: now,
                    name: normalized,
                  ),
                );
        await _database
            .into(_database.taskTags)
            .insert(
              TaskTagsCompanion.insert(
                taskId: taskId,
                tagId: tagId,
                createdAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        final usage = _database.taskTags.id.count();
        final usageQuery = _database.selectOnly(_database.taskTags)
          ..addColumns([usage])
          ..where(_database.taskTags.tagId.equals(tagId));
        final count = (await usageQuery.getSingle()).read(usage) ?? 0;
        await (_database.update(
          _database.tags,
        )..where((row) => row.id.equals(tagId))).write(
          TagsCompanion(usageCount: Value(count), updatedAt: Value(now)),
        );
        return const Success(null);
      });
    } on StateError catch (error) {
      return _rejected('tag_rejected', error);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'tag_save_failed',
          safeMessage: 'The tag could not be saved safely.',
        ),
      );
    }
  }

  @override
  Future<Result<int>> createChecklist({
    required int taskId,
    required String title,
  }) async {
    final normalized = _requiredText(title, 300);
    if (taskId <= 0 || normalized == null) {
      return _invalid('invalid_checklist', 'Enter a valid checklist title.');
    }
    try {
      return await _database.transaction(() async {
        final task = await _requireTask(taskId);
        final now = _now;
        final id = await _database
            .into(_database.checklists)
            .insert(
              ChecklistsCompanion.insert(
                uuid: _uuidFactory(),
                createdAt: now,
                updatedAt: now,
                taskId: taskId,
                title: normalized,
              ),
            );
        await (_database.update(
          _database.tasks,
        )..where((row) => row.id.equals(taskId))).write(
          TasksCompanion(
            checklistCount: Value(task.checklistCount + 1),
            updatedAt: Value(now),
          ),
        );
        return Success(id);
      });
    } on StateError catch (error) {
      return _rejected('checklist_rejected', error);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'checklist_create_failed',
          safeMessage: 'The checklist could not be created safely.',
        ),
      );
    }
  }

  @override
  Future<Result<int>> addChecklistItem({
    required int checklistId,
    required String title,
  }) async {
    final normalized = _requiredText(title, 300);
    if (checklistId <= 0 || normalized == null) {
      return _invalid(
        'invalid_checklist_item',
        'Enter a valid checklist item.',
      );
    }
    try {
      await _requireChecklist(checklistId);
      final now = _now;
      final id = await _database
          .into(_database.checklistItems)
          .insert(
            ChecklistItemsCompanion.insert(
              uuid: _uuidFactory(),
              createdAt: now,
              updatedAt: now,
              checklistId: checklistId,
              title: normalized,
            ),
          );
      return Success(id);
    } on StateError catch (error) {
      return _rejected('checklist_item_rejected', error);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'checklist_item_create_failed',
          safeMessage: 'The checklist item could not be created safely.',
        ),
      );
    }
  }

  @override
  Future<Result<int>> addAttachment(AttachmentDraft draft) async {
    final name = _requiredText(draft.fileName, 500);
    final path = _requiredText(draft.storagePath, 2000);
    final checksum = draft.checksumSha256.trim().toLowerCase();
    if (draft.taskId <= 0 ||
        name == null ||
        path == null ||
        draft.fileSize < 0 ||
        !_sha256.hasMatch(checksum)) {
      return _invalid(
        'invalid_attachment',
        'The attachment metadata is invalid.',
      );
    }
    try {
      return await _database.transaction(() async {
        final task = await _requireTask(draft.taskId);
        final existing =
            await (_database.select(_database.attachments)..where(
                  (row) =>
                      row.taskId.equals(draft.taskId) &
                      row.checksumSha256.equals(checksum) &
                      row.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        if (existing != null) return Success(existing.id);
        final canonical =
            await (_database.select(_database.attachments)..where(
                  (row) =>
                      row.checksumSha256.equals(checksum) &
                      row.isDeleted.equals(false),
                ))
                .getSingleOrNull();
        final now = _now;
        final id = await _database
            .into(_database.attachments)
            .insert(
              AttachmentsCompanion.insert(
                uuid: _uuidFactory(),
                createdAt: now,
                updatedAt: now,
                taskId: Value(draft.taskId),
                fileName: name,
                originalFileName: Value(_optionalText(draft.originalFileName)),
                extension: Value(_optionalText(draft.extension)),
                mimeType: Value(_optionalText(draft.mimeType)),
                storagePath: canonical?.storagePath ?? path,
                fileSize: draft.fileSize,
                checksumSha256: checksum,
              ),
            );
        await (_database.update(
          _database.tasks,
        )..where((row) => row.id.equals(draft.taskId))).write(
          TasksCompanion(
            attachmentCount: Value(task.attachmentCount + 1),
            updatedAt: Value(now),
          ),
        );
        return Success(id);
      });
    } on StateError catch (error) {
      return _rejected('attachment_rejected', error);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'attachment_save_failed',
          safeMessage: 'The attachment metadata could not be saved safely.',
        ),
      );
    }
  }

  @override
  Future<Result<int>> createRepeatRule(RepeatRuleDraft draft) async {
    final name = _requiredText(draft.name, 200);
    final timezone = _requiredText(draft.timezoneId, 100);
    final validEnd = switch (draft.endType) {
      RepeatEndType.never =>
        draft.endAt == null && draft.occurrenceLimit == null,
      RepeatEndType.onDate =>
        draft.endAt != null && draft.occurrenceLimit == null,
      RepeatEndType.afterOccurrences =>
        draft.endAt == null && (draft.occurrenceLimit ?? 0) > 0,
    };
    if (name == null ||
        timezone == null ||
        draft.interval < 1 ||
        draft.weekdayMask < 0 ||
        draft.weekdayMask > 127 ||
        (draft.dayOfMonth != null &&
            (draft.dayOfMonth! < 1 || draft.dayOfMonth! > 31)) ||
        (draft.monthOfYear != null &&
            (draft.monthOfYear! < 1 || draft.monthOfYear! > 12)) ||
        !validEnd) {
      return _invalid('invalid_repeat_rule', 'The repeat rule is invalid.');
    }
    try {
      final now = _now;
      final id = await _database
          .into(_database.repeatRules)
          .insert(
            RepeatRulesCompanion.insert(
              uuid: _uuidFactory(),
              createdAt: now,
              updatedAt: now,
              name: name,
              frequency: draft.frequency,
              recurrenceInterval: Value(draft.interval),
              weekdayMask: Value(draft.weekdayMask),
              dayOfMonth: Value(draft.dayOfMonth),
              monthOfYear: Value(draft.monthOfYear),
              timezoneId: timezone,
              endType: draft.endType,
              endAt: Value(draft.endAt?.toUtc().microsecondsSinceEpoch),
              occurrenceLimit: Value(draft.occurrenceLimit),
              seriesUuid: _uuidFactory(),
            ),
          );
      return Success(id);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'repeat_rule_create_failed',
          safeMessage: 'The repeat rule could not be created safely.',
        ),
      );
    }
  }

  int get _now => _clock().toUtc().microsecondsSinceEpoch;

  Future<CategoryRow> _requireCategory(int id) async {
    final row =
        await (_database.select(_database.categories)
              ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
            .getSingleOrNull();
    if (row == null) throw StateError('The category does not exist.');
    return row;
  }

  Future<TaskRow> _requireTask(int id) async {
    final row =
        await (_database.select(_database.tasks)
              ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
            .getSingleOrNull();
    if (row == null) throw StateError('The task does not exist.');
    return row;
  }

  Future<ChecklistRow> _requireChecklist(int id) async {
    final row =
        await (_database.select(_database.checklists)
              ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
            .getSingleOrNull();
    if (row == null) throw StateError('The checklist does not exist.');
    return row;
  }

  String? _requiredText(String value, int maxLength) {
    final normalized = value.trim();
    return normalized.isEmpty || normalized.runes.length > maxLength
        ? null
        : normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  FailureResult<T> _invalid<T>(String code, String message) =>
      FailureResult(ValidationFailure(code: code, safeMessage: message));

  FailureResult<T> _rejected<T>(String code, StateError error) => FailureResult(
    ValidationFailure(code: code, safeMessage: error.message.toString()),
  );

  static final RegExp _sha256 = RegExp(r'^[a-f0-9]{64}$');
}
