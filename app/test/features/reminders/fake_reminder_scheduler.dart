import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_occurrence.dart';
import 'package:anas_life_os/features/reminders/domain/services/reminder_scheduler.dart';

final class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.exactAllowed = true});

  final bool exactAllowed;
  final scheduled = <ReminderScheduleRequest>[];
  final cancelled = <int>[];
  final events = <ReminderPlatformEvent>[];

  @override
  Future<Result<bool>> canScheduleExactAlarms() async => Success(exactAllowed);

  @override
  Future<Result<void>> cancel(int reminderId) async {
    cancelled.add(reminderId);
    return const Success(null);
  }

  @override
  Future<Result<List<ReminderPlatformEvent>>> drainEvents() async {
    final value = List<ReminderPlatformEvent>.of(events);
    events.clear();
    return Success(value);
  }

  @override
  Future<Result<void>> schedule(ReminderScheduleRequest request) async {
    scheduled.add(request);
    return const Success(null);
  }
}

