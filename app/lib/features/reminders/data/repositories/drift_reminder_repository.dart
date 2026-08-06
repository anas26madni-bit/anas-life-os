import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/reminder_draft.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/reminder_enums.dart';
import '../../domain/entities/reminder_occurrence.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/services/reminder_validator.dart';

final class DriftReminderRepository implements ReminderRepository {
  DriftReminderRepository(
    this._database, {
    this.validator = const ReminderValidator(),
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final ReminderValidator validator;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  @override
  Future<Result<ReminderEntity>> create(ReminderDraft draft) async {
    final validated = validator.validate(draft);
    if (validated case FailureResult<ReminderDraft>(:final failure)) {
      return FailureResult(failure);
    }
    final value = (validated as Success<ReminderDraft>).value;
    try {
      return await _database.transaction(() async {
        await _requireTask(value.taskId);
        final now = _clock().toUtc().microsecondsSinceEpoch;
        final id = await _database.into(_database.reminders).insert(
          RemindersCompanion.insert(
            uuid: _uuidFactory(),
            taskId: value.taskId,
            title: value.title,
            scheduledAt: value.scheduledAt.microsecondsSinceEpoch,
            timezoneId: value.timezoneId,
            priority: value.priority,
            createdAt: now,
            updatedAt: now,
            message: Value(value.message),
            repeatRuleId: Value(value.repeatRuleId),
            sound: Value(value.sound),
            vibration: Value(value.vibration),
            flash: Value(value.flash),
            voiceEnabled: Value(value.voiceEnabled),
            fullScreen: Value(value.fullScreen),
            snoozeMinutes: Value(value.snoozeMinutes),
            maxSnoozes: Value(value.maxSnoozes),
            autoSnooze: Value(value.autoSnooze),
            escalationStep: Value(value.escalationStep),
          ),
        );
        return Success(_map(await _requireRow(id, includeDeleted: false)));
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'reminder_create_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_create_failed',
          safeMessage: 'The reminder could not be saved safely.',
        ),
      );
    }
  }

  @override
  Future<Result<ReminderEntity>> update(int id, ReminderDraft draft) async {
    final validated = validator.validate(draft);
    if (validated case FailureResult<ReminderDraft>(:final failure)) {
      return FailureResult(failure);
    }
    final value = (validated as Success<ReminderDraft>).value;
    try {
      return await _database.transaction(() async {
        final current = await _requireRow(id, includeDeleted: false);
        await _requireTask(value.taskId);
        final now = _clock().toUtc().microsecondsSinceEpoch;
        await (_database.update(
          _database.reminders,
        )..where((row) => row.id.equals(id))).write(
          RemindersCompanion(
            taskId: Value(value.taskId),
            title: Value(value.title),
            message: Value(value.message),
            scheduledAt: Value(value.scheduledAt.microsecondsSinceEpoch),
            timezoneId: Value(value.timezoneId),
            repeatRuleId: Value(value.repeatRuleId),
            priority: Value(value.priority),
            sound: Value(value.sound),
            vibration: Value(value.vibration),
            flash: Value(value.flash),
            voiceEnabled: Value(value.voiceEnabled),
            fullScreen: Value(value.fullScreen),
            snoozeMinutes: Value(value.snoozeMinutes),
            maxSnoozes: Value(value.maxSnoozes),
            autoSnooze: Value(value.autoSnooze),
            escalationStep: Value(value.escalationStep),
            updatedAt: Value(now),
            version: Value(current.version + 1),
          ),
        );
        return Success(_map(await _requireRow(id, includeDeleted: false)));
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'reminder_update_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_update_failed',
          safeMessage: 'The reminder could not be updated safely.',
        ),
      );
    }
  }

  @override
  Future<Result<ReminderEntity?>> findById(int id) async {
    try {
      final row = await (_database.select(_database.reminders)..where(
            (row) => row.id.equals(id) & row.isDeleted.equals(false),
          ))
          .getSingleOrNull();
      return Success(row == null ? null : _map(row));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_read_failed',
          safeMessage: 'The reminder could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<List<ReminderEntity>>> list({
    int limit = 50,
    int offset = 0,
  }) async {
    if (limit < 1 || limit > 200 || offset < 0) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_reminder_page',
          safeMessage: 'The requested reminder page is invalid.',
        ),
      );
    }
    try {
      final query = _database.select(_database.reminders)
        ..where((row) => row.isDeleted.equals(false))
        ..orderBy([
          (row) => OrderingTerm.asc(row.scheduledAt),
          (row) => OrderingTerm.asc(row.id),
        ])
        ..limit(limit, offset: offset);
      return Success((await query.get()).map(_map).toList(growable: false));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_list_failed',
          safeMessage: 'Reminders could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<ReminderEntity>> setEnabled(int id, bool enabled) async {
    try {
      final current = await _requireRow(id, includeDeleted: false);
      final now = _clock().toUtc().microsecondsSinceEpoch;
      await (_database.update(
        _database.reminders,
      )..where((row) => row.id.equals(id))).write(
        RemindersCompanion(
          enabled: Value(enabled),
          updatedAt: Value(now),
          version: Value(current.version + 1),
        ),
      );
      return Success(_map(await _requireRow(id, includeDeleted: false)));
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'reminder_state_rejected',
          safeMessage: error.message.toString(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_state_failed',
          safeMessage: 'The reminder state could not be changed.',
        ),
      );
    }
  }

  @override
  Future<Result<ReminderEntity>> softDelete(int id) async {
    try {
      final current = await _requireRow(id, includeDeleted: false);
      final now = _clock().toUtc().microsecondsSinceEpoch;
      await (_database.update(
        _database.reminders,
      )..where((row) => row.id.equals(id))).write(
        RemindersCompanion(
          enabled: const Value(false),
          isDeleted: const Value(true),
          deletedAt: Value(now),
          updatedAt: Value(now),
          version: Value(current.version + 1),
        ),
      );
      return Success(_map(await _requireRow(id, includeDeleted: true)));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_delete_failed',
          safeMessage: 'The reminder could not be moved to the recycle bin.',
        ),
      );
    }
  }

  @override
  Future<Result<ReminderEntity>> restore(int id) async {
    try {
      final current = await _requireRow(id, includeDeleted: true);
      final now = _clock().toUtc().microsecondsSinceEpoch;
      await (_database.update(
        _database.reminders,
      )..where((row) => row.id.equals(id))).write(
        RemindersCompanion(
          isDeleted: const Value(false),
          deletedAt: const Value(null),
          updatedAt: Value(now),
          version: Value(current.version + 1),
        ),
      );
      return Success(_map(await _requireRow(id, includeDeleted: false)));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_restore_failed',
          safeMessage: 'The reminder could not be restored.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> recordAction({
    required int reminderId,
    required String occurrenceUuid,
    required ReminderAction action,
    required DateTime occurredAt,
    int snoozeCount = 0,
  }) async {
    if (occurrenceUuid.length != 36 || snoozeCount < 0) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_reminder_history',
          safeMessage: 'The reminder event is invalid.',
        ),
      );
    }
    try {
      await _requireRow(reminderId, includeDeleted: true);
      await _database.into(_database.reminderHistory).insert(
        ReminderHistoryCompanion.insert(
          uuid: _uuidFactory(),
          reminderId: reminderId,
          occurrenceUuid: occurrenceUuid,
          action: action,
          occurredAt: occurredAt.toUtc().microsecondsSinceEpoch,
          snoozeCount: Value(snoozeCount),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_history_failed',
          safeMessage: 'The reminder event could not be recorded.',
        ),
      );
    }
  }

  @override
  Future<Result<List<ReminderHistoryEntity>>> history({
    int limit = 100,
    int offset = 0,
  }) async {
    if (limit < 1 || limit > 500 || offset < 0) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_reminder_history_page',
          safeMessage: 'The requested reminder history page is invalid.',
        ),
      );
    }
    try {
      final query = _database.select(_database.reminderHistory)
        ..orderBy([
          (row) => OrderingTerm.desc(row.occurredAt),
          (row) => OrderingTerm.desc(row.id),
        ])
        ..limit(limit, offset: offset);
      return Success(
        (await query.get())
            .map(
              (row) => ReminderHistoryEntity(
                id: row.id,
                uuid: row.uuid,
                reminderId: row.reminderId,
                occurrenceUuid: row.occurrenceUuid,
                action: row.action,
                occurredAt: _date(row.occurredAt),
                snoozeCount: row.snoozeCount,
              ),
            )
            .toList(growable: false),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_history_list_failed',
          safeMessage: 'Reminder history could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<ReminderRepeatPattern>> repeatPattern(
    ReminderEntity reminder,
  ) async {
    if (reminder.repeatRuleId == null) {
      return Success(ReminderRepeatPattern.none(reminder.timezoneId));
    }
    try {
      final row = await (_database.select(_database.repeatRules)..where(
            (row) =>
                row.id.equals(reminder.repeatRuleId!) &
                row.isDeleted.equals(false),
          ))
          .getSingleOrNull();
      if (row == null) {
        return const FailureResult(
          ValidationFailure(
            code: 'reminder_repeat_rule_missing',
            safeMessage: 'The reminder repeat rule no longer exists.',
          ),
        );
      }
      return Success(
        ReminderRepeatPattern(
          frequency: ReminderRepeatFrequency.values.byName(row.frequency.name),
          interval: row.recurrenceInterval,
          weekdayMask: row.weekdayMask,
          dayOfMonth: row.dayOfMonth,
          monthOfYear: row.monthOfYear,
          timezoneId: row.timezoneId,
          end: ReminderRepeatEnd.values.byName(row.endType.name),
          endAt: row.endAt == null ? null : _date(row.endAt!),
          occurrenceLimit: row.occurrenceLimit,
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'reminder_repeat_rule_failed',
          safeMessage: 'The reminder repeat rule could not be loaded.',
        ),
      );
    }
  }

  Future<void> _requireTask(int taskId) async {
    final task = await (_database.select(
      _database.tasks,
    )..where((row) => row.id.equals(taskId) & row.isDeleted.equals(false)))
        .getSingleOrNull();
    if (task == null) {
      throw StateError('The reminder task does not exist.');
    }
  }

  Future<ReminderRow> _requireRow(
    int id, {
    required bool includeDeleted,
  }) async {
    final query = _database.select(_database.reminders)
      ..where((row) => row.id.equals(id));
    if (!includeDeleted) {
      query.where((row) => row.isDeleted.equals(false));
    }
    final row = await query.getSingleOrNull();
    if (row == null) {
      throw StateError('The reminder does not exist.');
    }
    return row;
  }

  ReminderEntity _map(ReminderRow row) => ReminderEntity(
    id: row.id,
    uuid: row.uuid,
    taskId: row.taskId,
    title: row.title,
    message: row.message,
    scheduledAt: _date(row.scheduledAt),
    timezoneId: row.timezoneId,
    repeatRuleId: row.repeatRuleId,
    priority: row.priority,
    enabled: row.enabled,
    vibration: row.vibration,
    flash: row.flash,
    voiceEnabled: row.voiceEnabled,
    fullScreen: row.fullScreen,
    sound: row.sound,
    snoozeMinutes: row.snoozeMinutes,
    maxSnoozes: row.maxSnoozes,
    autoSnooze: row.autoSnooze,
    escalationStep: row.escalationStep,
    createdAt: _date(row.createdAt),
    updatedAt: _date(row.updatedAt),
    deletedAt: row.deletedAt == null ? null : _date(row.deletedAt!),
    isDeleted: row.isDeleted,
    version: row.version,
  );

  DateTime _date(int value) =>
      DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
}
