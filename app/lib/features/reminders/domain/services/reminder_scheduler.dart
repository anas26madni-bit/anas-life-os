import '../../../../core/errors/result.dart';
import '../entities/reminder_occurrence.dart';

abstract interface class ReminderScheduler {
  Future<Result<void>> schedule(ReminderScheduleRequest request);
  Future<Result<void>> cancel(int reminderId);
  Future<Result<List<ReminderPlatformEvent>>> drainEvents();
  Future<Result<bool>> canScheduleExactAlarms();
}

final class ReminderPlatformEvent {
  const ReminderPlatformEvent({
    required this.reminderId,
    required this.occurrenceUuid,
    required this.action,
    required this.occurredAt,
  });

  final int reminderId;
  final String occurrenceUuid;
  final String action;
  final DateTime occurredAt;
}
