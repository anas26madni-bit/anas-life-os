import 'reminder_enums.dart';

final class ReminderDraft {
  const ReminderDraft({
    required this.taskId,
    required this.title,
    required this.scheduledAt,
    required this.timezoneId,
    this.message,
    this.repeatRuleId,
    this.priority = ReminderPriority.normal,
    this.vibration = true,
    this.flash = false,
    this.voiceEnabled = false,
    this.fullScreen = false,
    this.sound,
    this.snoozeMinutes = 10,
    this.maxSnoozes = 3,
    this.autoSnooze = false,
    this.escalationStep = 0,
  });

  final int taskId;
  final String title;
  final String? message;
  final DateTime scheduledAt;
  final String timezoneId;
  final int? repeatRuleId;
  final ReminderPriority priority;
  final bool vibration;
  final bool flash;
  final bool voiceEnabled;
  final bool fullScreen;
  final String? sound;
  final int snoozeMinutes;
  final int maxSnoozes;
  final bool autoSnooze;
  final int escalationStep;
}
