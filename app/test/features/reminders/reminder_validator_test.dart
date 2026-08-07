import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_draft.dart';
import 'package:anas_life_os/features/reminders/domain/services/reminder_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validator = ReminderValidator();

  test('normalizes valid reminder input', () {
    final result = validator.validate(
      ReminderDraft(
        taskId: 1,
        title: '  Review plan  ',
        scheduledAt: DateTime.utc(2026, 8, 6, 12),
        timezoneId: 'Asia/Karachi',
      ),
    );
    expect(result, isA<Success<ReminderDraft>>());
    expect((result as Success<ReminderDraft>).value.title, 'Review plan');
  });

  test('rejects invalid task, title, timezone, and snooze limits', () {
    expect(
      validator.validate(
        ReminderDraft(
          taskId: 0,
          title: 'Reminder',
          scheduledAt: DateTime.now(),
          timezoneId: 'UTC',
        ),
      ),
      isA<FailureResult<ReminderDraft>>(),
    );
    expect(
      validator.validate(
        ReminderDraft(
          taskId: 1,
          title: '',
          scheduledAt: DateTime.now(),
          timezoneId: 'UTC',
        ),
      ),
      isA<FailureResult<ReminderDraft>>(),
    );
    expect(
      validator.validate(
        ReminderDraft(
          taskId: 1,
          title: 'Reminder',
          scheduledAt: DateTime.now(),
          timezoneId: '',
        ),
      ),
      isA<FailureResult<ReminderDraft>>(),
    );
    expect(
      validator.validate(
        ReminderDraft(
          taskId: 1,
          title: 'Reminder',
          scheduledAt: DateTime.now(),
          timezoneId: 'UTC',
          snoozeMinutes: 0,
        ),
      ),
      isA<FailureResult<ReminderDraft>>(),
    );
  });
}
