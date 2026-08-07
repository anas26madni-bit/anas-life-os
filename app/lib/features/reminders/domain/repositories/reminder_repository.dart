import '../../../../core/errors/result.dart';
import '../entities/reminder_draft.dart';
import '../entities/reminder_entity.dart';
import '../entities/reminder_enums.dart';
import '../entities/reminder_occurrence.dart';

abstract interface class ReminderRepository {
  Future<Result<ReminderEntity>> create(ReminderDraft draft);
  Future<Result<ReminderEntity>> update(int id, ReminderDraft draft);
  Future<Result<ReminderEntity?>> findById(int id);
  Future<Result<List<ReminderEntity>>> list({int limit = 50, int offset = 0});
  Future<Result<ReminderEntity>> setEnabled(int id, bool enabled);
  Future<Result<ReminderEntity>> softDelete(int id);
  Future<Result<ReminderEntity>> restore(int id);
  Future<Result<void>> recordAction({
    required int reminderId,
    required String occurrenceUuid,
    required ReminderAction action,
    required DateTime occurredAt,
    int snoozeCount = 0,
  });
  Future<Result<List<ReminderHistoryEntity>>> history({
    int limit = 100,
    int offset = 0,
  });
  Future<Result<ReminderRepeatPattern>> repeatPattern(ReminderEntity reminder);
}
