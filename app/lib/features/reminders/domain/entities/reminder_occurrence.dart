import 'reminder_enums.dart';

final class ReminderOccurrence {
  const ReminderOccurrence({
    required this.reminderId,
    required this.occurrenceUuid,
    required this.scheduledAt,
    required this.precision,
    required this.vibration,
    required this.flash,
    required this.voiceEnabled,
    required this.fullScreen,
    required this.priority,
  });

  final int reminderId;
  final String occurrenceUuid;
  final DateTime scheduledAt;
  final ReminderSchedulePrecision precision;
  final bool vibration;
  final bool flash;
  final bool voiceEnabled;
  final bool fullScreen;
  final ReminderPriority priority;
}

final class ReminderRepeatPattern {
  const ReminderRepeatPattern({
    required this.frequency,
    required this.interval,
    required this.timezoneId,
    required this.end,
    this.weekdayMask = 0,
    this.dayOfMonth,
    this.monthOfYear,
    this.endAt,
    this.occurrenceLimit,
  });

  const ReminderRepeatPattern.none(String timezoneId)
    : this(
        frequency: ReminderRepeatFrequency.none,
        interval: 1,
        timezoneId: timezoneId,
        end: ReminderRepeatEnd.never,
      );

  final ReminderRepeatFrequency frequency;
  final int interval;
  final int weekdayMask;
  final int? dayOfMonth;
  final int? monthOfYear;
  final String timezoneId;
  final ReminderRepeatEnd end;
  final DateTime? endAt;
  final int? occurrenceLimit;
}

final class ReminderScheduleRequest {
  const ReminderScheduleRequest({
    required this.occurrence,
    required this.repeatPattern,
    required this.snoozeMinutes,
    required this.maxSnoozes,
    required this.autoSnooze,
    required this.escalationStep,
  });

  final ReminderOccurrence occurrence;
  final ReminderRepeatPattern repeatPattern;
  final int snoozeMinutes;
  final int maxSnoozes;
  final bool autoSnooze;
  final int escalationStep;
}
