import 'package:flutter/services.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/reminder_enums.dart';
import '../../domain/entities/reminder_occurrence.dart';
import '../../domain/services/reminder_scheduler.dart';

final class AndroidReminderScheduler implements ReminderScheduler {
  const AndroidReminderScheduler({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  final MethodChannel _channel;

  static const _channelName = 'com.anaslifeos.app/reminders';

  @override
  Future<Result<void>> schedule(ReminderScheduleRequest request) async {
    try {
      final occurrence = request.occurrence;
      final repeat = request.repeatPattern;
      await _channel.invokeMethod<void>('schedule', <String, Object?>{
        'reminderId': occurrence.reminderId,
        'occurrenceUuid': occurrence.occurrenceUuid,
        'scheduledAtMillis': occurrence.scheduledAt.millisecondsSinceEpoch,
        'exact': occurrence.precision == ReminderSchedulePrecision.exact,
        'vibration': occurrence.vibration,
        'flash': occurrence.flash,
        'voice': occurrence.voiceEnabled,
        'fullScreen': occurrence.fullScreen,
        'priority': occurrence.priority.name,
        'frequency': repeat.frequency.name,
        'interval': repeat.interval,
        'weekdayMask': repeat.weekdayMask,
        'dayOfMonth': repeat.dayOfMonth,
        'monthOfYear': repeat.monthOfYear,
        'timezoneId': repeat.timezoneId,
        'endType': repeat.end.name,
        'endAtMillis': repeat.endAt?.millisecondsSinceEpoch,
        'occurrenceLimit': repeat.occurrenceLimit,
        'snoozeMinutes': request.snoozeMinutes,
        'maxSnoozes': request.maxSnoozes,
        'autoSnooze': request.autoSnooze,
        'escalationStep': request.escalationStep,
      });
      return const Success(null);
    } on PlatformException {
      return const FailureResult(
        InitializationFailure(
          code: 'reminder_schedule_failed',
          safeMessage: 'The device could not schedule this reminder.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> cancel(int reminderId) async {
    try {
      await _channel.invokeMethod<void>('cancel', <String, Object?>{
        'reminderId': reminderId,
      });
      return const Success(null);
    } on PlatformException {
      return const FailureResult(
        InitializationFailure(
          code: 'reminder_cancel_failed',
          safeMessage: 'The device could not cancel this reminder.',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> canScheduleExactAlarms() async {
    try {
      final value = await _channel.invokeMethod<bool>('canScheduleExact');
      return Success(value ?? false);
    } on PlatformException {
      return const Success(false);
    }
  }

  @override
  Future<Result<List<ReminderPlatformEvent>>> drainEvents() async {
    try {
      final raw = await _channel.invokeListMethod<Object?>('drainEvents');
      final events = (raw ?? const <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map(
            (event) => ReminderPlatformEvent(
              reminderId: event['reminderId']! as int,
              occurrenceUuid: event['occurrenceUuid']! as String,
              action: event['action']! as String,
              occurredAt: DateTime.fromMillisecondsSinceEpoch(
                event['occurredAtMillis']! as int,
                isUtc: true,
              ),
            ),
          )
          .toList(growable: false);
      return Success(events);
    } on PlatformException {
      return const FailureResult(
        InitializationFailure(
          code: 'reminder_event_sync_failed',
          safeMessage: 'Reminder history could not be synchronized.',
        ),
      );
    }
  }
}
