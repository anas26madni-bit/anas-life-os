import 'package:anas_life_os/core/errors/failure.dart';
import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_occurrence.dart';
import 'package:anas_life_os/features/reminders/domain/services/reminder_scheduler.dart';

final class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({
    this.exactAllowed = true,
    this.scheduleFailure,
    this.cancelFailure,
    this.drainFailure,
    this.exactFailure,
  });

  final bool exactAllowed;
  Failure? scheduleFailure;
  Failure? cancelFailure;
  Failure? drainFailure;
  Failure? exactFailure;
  final scheduled = <ReminderScheduleRequest>[];
  final cancelled = <int>[];
  final events = <ReminderPlatformEvent>[];

  @override
  Future<Result<bool>> canScheduleExactAlarms() async => exactFailure == null
      ? Success(exactAllowed)
      : FailureResult(exactFailure!);

  @override
  Future<Result<void>> cancel(int reminderId) async {
    cancelled.add(reminderId);
    return cancelFailure == null
        ? const Success(null)
        : FailureResult(cancelFailure!);
  }

  @override
  Future<Result<List<ReminderPlatformEvent>>> drainEvents() async {
    if (drainFailure != null) {
      return FailureResult(drainFailure!);
    }
    final value = List<ReminderPlatformEvent>.of(events);
    events.clear();
    return Success(value);
  }

  @override
  Future<Result<void>> schedule(ReminderScheduleRequest request) async {
    scheduled.add(request);
    return scheduleFailure == null
        ? const Success(null)
        : FailureResult(scheduleFailure!);
  }
}
