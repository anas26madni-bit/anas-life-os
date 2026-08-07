import 'reminder_enums.dart';

final class ReminderEntity {
  const ReminderEntity({
    required this.id,
    required this.uuid,
    required this.taskId,
    required this.title,
    required this.scheduledAt,
    required this.timezoneId,
    required this.priority,
    required this.enabled,
    required this.vibration,
    required this.flash,
    required this.voiceEnabled,
    required this.fullScreen,
    required this.snoozeMinutes,
    required this.maxSnoozes,
    required this.autoSnooze,
    required this.escalationStep,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.version,
    this.message,
    this.repeatRuleId,
    this.sound,
    this.deletedAt,
  });

  final int id;
  final String uuid;
  final int taskId;
  final String title;
  final String? message;
  final DateTime scheduledAt;
  final String timezoneId;
  final int? repeatRuleId;
  final ReminderPriority priority;
  final bool enabled;
  final bool vibration;
  final bool flash;
  final bool voiceEnabled;
  final bool fullScreen;
  final String? sound;
  final int snoozeMinutes;
  final int maxSnoozes;
  final bool autoSnooze;
  final int escalationStep;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool isDeleted;
  final int version;
}

final class ReminderHistoryEntity {
  const ReminderHistoryEntity({
    required this.id,
    required this.uuid,
    required this.reminderId,
    required this.occurrenceUuid,
    required this.action,
    required this.occurredAt,
    required this.snoozeCount,
  });

  final int id;
  final String uuid;
  final int reminderId;
  final String occurrenceUuid;
  final ReminderAction action;
  final DateTime occurredAt;
  final int snoozeCount;
}
