import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/reminders/data/services/android_reminder_scheduler.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_enums.dart';
import 'package:anas_life_os/features/reminders/domain/entities/reminder_occurrence.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/reminders');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'canScheduleExact') return true;
          if (call.method == 'drainEvents') return <Object?>[];
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sends privacy-safe schedule metadata to Android', () async {
    const scheduler = AndroidReminderScheduler(channel: channel);
    final result = await scheduler.schedule(
      ReminderScheduleRequest(
        occurrence: ReminderOccurrence(
          reminderId: 7,
          occurrenceUuid: '00000000-0000-4000-8000-000000000007',
          scheduledAt: DateTime.utc(2026, 8, 7),
          precision: ReminderSchedulePrecision.exact,
          vibration: true,
          flash: false,
          voiceEnabled: false,
          fullScreen: false,
          priority: ReminderPriority.high,
        ),
        repeatPattern: const ReminderRepeatPattern.none('UTC'),
        snoozeMinutes: 10,
        maxSnoozes: 3,
        autoSnooze: false,
        escalationStep: 0,
      ),
    );
    expect(result, isA<Success<void>>());
    expect(calls.single.method, 'schedule');
    final arguments = calls.single.arguments! as Map<Object?, Object?>;
    expect(arguments['reminderId'], 7);
    expect(arguments, isNot(contains('title')));
    expect(arguments, isNot(contains('message')));
  });
}
