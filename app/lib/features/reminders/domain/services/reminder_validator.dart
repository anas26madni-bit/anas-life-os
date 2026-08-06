import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/reminder_draft.dart';

final class ReminderValidator {
  const ReminderValidator();

  Result<ReminderDraft> validate(ReminderDraft draft) {
    final title = draft.title.trim();
    if (draft.taskId < 1) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_reminder_task',
          safeMessage: 'Choose a valid task for the reminder.',
        ),
      );
    }
    if (title.isEmpty || title.length > 200) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_reminder_title',
          safeMessage: 'Reminder titles must contain 1 to 200 characters.',
        ),
      );
    }
    if (draft.timezoneId.trim().isEmpty || draft.timezoneId.length > 100) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_reminder_timezone',
          safeMessage: 'Choose a valid reminder time zone.',
        ),
      );
    }
    if (draft.snoozeMinutes < 1 || draft.snoozeMinutes > 1440) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_reminder_snooze',
          safeMessage: 'Snooze must be between 1 minute and 24 hours.',
        ),
      );
    }
    if (draft.maxSnoozes < 0 || draft.maxSnoozes > 20) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_reminder_snooze_limit',
          safeMessage: 'Snooze limit must be between 0 and 20.',
        ),
      );
    }
    return Success(
      ReminderDraft(
        taskId: draft.taskId,
        title: title,
        message: draft.message?.trim(),
        scheduledAt: draft.scheduledAt.toUtc(),
        timezoneId: draft.timezoneId.trim(),
        repeatRuleId: draft.repeatRuleId,
        priority: draft.priority,
        vibration: draft.vibration,
        flash: draft.flash,
        voiceEnabled: draft.voiceEnabled,
        fullScreen: draft.fullScreen,
        sound: draft.sound?.trim(),
        snoozeMinutes: draft.snoozeMinutes,
        maxSnoozes: draft.maxSnoozes,
        autoSnooze: draft.autoSnooze,
        escalationStep: draft.escalationStep,
      ),
    );
  }
}
