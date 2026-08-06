import '../../../../core/errors/result.dart';
import '../entities/reminder_draft.dart';
import '../entities/reminder_entity.dart';
import '../entities/reminder_enums.dart';
import '../entities/reminder_occurrence.dart';
import '../repositories/reminder_repository.dart';
import '../services/reminder_scheduler.dart';

final class ReminderUseCases {
  const ReminderUseCases(this._repository, this._scheduler);

  final ReminderRepository _repository;
  final ReminderScheduler _scheduler;

  Future<Result<List<ReminderEntity>>> list({int limit = 50, int offset = 0}) {
    return _repository.list(limit: limit, offset: offset);
  }

  Future<Result<ReminderEntity>> create(ReminderDraft draft) async {
    final created = await _repository.create(draft);
    if (created case FailureResult<ReminderEntity>()) {
      return created;
    }
    final reminder = (created as Success<ReminderEntity>).value;
    final scheduled = await _schedule(reminder);
    if (scheduled case FailureResult<void>(:final failure)) {
      await _repository.setEnabled(reminder.id, false);
      return FailureResult(failure);
    }
    return Success(reminder);
  }

  Future<Result<ReminderEntity>> update(int id, ReminderDraft draft) async {
    final updated = await _repository.update(id, draft);
    if (updated case FailureResult<ReminderEntity>()) {
      return updated;
    }
    final reminder = (updated as Success<ReminderEntity>).value;
    await _scheduler.cancel(reminder.id);
    final scheduled = await _schedule(reminder);
    if (scheduled case FailureResult<void>(:final failure)) {
      await _repository.setEnabled(reminder.id, false);
      return FailureResult(failure);
    }
    return Success(reminder);
  }

  Future<Result<ReminderEntity>> setEnabled(int id, bool enabled) async {
    final changed = await _repository.setEnabled(id, enabled);
    if (changed case FailureResult<ReminderEntity>()) {
      return changed;
    }
    final reminder = (changed as Success<ReminderEntity>).value;
    if (!enabled) {
      final cancelled = await _scheduler.cancel(reminder.id);
      if (cancelled case FailureResult<void>(:final failure)) {
        return FailureResult(failure);
      }
      return Success(reminder);
    }
    final scheduled = await _schedule(reminder);
    return switch (scheduled) {
      Success<void>() => Success(reminder),
      FailureResult<void>(:final failure) => FailureResult(failure),
    };
  }

  Future<Result<ReminderEntity>> delete(int id) async {
    await _scheduler.cancel(id);
    return _repository.softDelete(id);
  }

  Future<Result<void>> synchronizePlatformEvents() async {
    final drained = await _scheduler.drainEvents();
    if (drained case FailureResult<List<ReminderPlatformEvent>>(
      :final failure,
    )) {
      return FailureResult(failure);
    }
    for (final event
        in (drained as Success<List<ReminderPlatformEvent>>).value) {
      final action = ReminderAction.values
          .where((candidate) => candidate.name == event.action)
          .firstOrNull;
      if (action == null) {
        continue;
      }
      final recorded = await _repository.recordAction(
        reminderId: event.reminderId,
        occurrenceUuid: event.occurrenceUuid,
        action: action,
        occurredAt: event.occurredAt,
      );
      if (recorded case FailureResult<void>(:final failure)) {
        return FailureResult(failure);
      }
    }
    return const Success(null);
  }

  Future<Result<List<ReminderHistoryEntity>>> missedReport() async {
    final result = await _repository.history(limit: 500);
    return switch (result) {
      Success<List<ReminderHistoryEntity>>(:final value) => Success(
        value
            .where(
              (item) =>
                  item.action == ReminderAction.ignored ||
                  item.action == ReminderAction.expired,
            )
            .toList(growable: false),
      ),
      FailureResult<List<ReminderHistoryEntity>>(:final failure) =>
        FailureResult(failure),
    };
  }

  Future<Result<void>> _schedule(ReminderEntity reminder) async {
    if (!reminder.enabled) {
      return const Success(null);
    }
    final repeat = await _repository.repeatPattern(reminder);
    if (repeat case FailureResult<ReminderRepeatPattern>(:final failure)) {
      return FailureResult(failure);
    }
    final exact = await _scheduler.canScheduleExactAlarms();
    final precision = switch (exact) {
      Success<bool>(value: true) => ReminderSchedulePrecision.exact,
      Success<bool>() ||
      FailureResult<bool>() => ReminderSchedulePrecision.inexact,
    };
    return _scheduler.schedule(
      ReminderScheduleRequest(
        occurrence: ReminderOccurrence(
          reminderId: reminder.id,
          occurrenceUuid: reminder.uuid,
          scheduledAt: reminder.scheduledAt,
          precision: precision,
          vibration: reminder.vibration,
          flash: reminder.flash,
          voiceEnabled: reminder.voiceEnabled,
          fullScreen: reminder.fullScreen,
          priority: reminder.priority,
        ),
        repeatPattern: (repeat as Success<ReminderRepeatPattern>).value,
        snoozeMinutes: reminder.snoozeMinutes,
        maxSnoozes: reminder.maxSnoozes,
        autoSnooze: reminder.autoSnooze,
        escalationStep: reminder.escalationStep,
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
