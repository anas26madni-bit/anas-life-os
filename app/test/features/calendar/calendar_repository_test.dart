import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/calendar/data/repositories/drift_calendar_repository.dart';
import 'package:anas_life_os/features/calendar/domain/entities/calendar_models.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('creates, updates, lists, and soft-deletes calendar events', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftCalendarRepository(
      database,
      clock: () => DateTime.utc(2026, 8, 7),
      uuidFactory: () => '00000000-0000-7000-8000-000000000006',
    );
    final start = DateTime.utc(2026, 8, 10, 9);
    final created =
        (await repository.create(
                  CalendarEventDraft(
                    title: 'Planning',
                    startAt: start,
                    endAt: start.add(const Duration(hours: 1)),
                  ),
                )
                as Success<CalendarEvent>)
            .value;
    final updated =
        (await repository.update(
                  created.id,
                  CalendarEventDraft(
                    title: 'Weekly planning',
                    startAt: start,
                    endAt: start.add(const Duration(hours: 2)),
                  ),
                )
                as Success<CalendarEvent>)
            .value;
    expect(updated.title, 'Weekly planning');
    expect(
      (await repository.listRange(
                DateTime.utc(2026, 8, 10),
                DateTime.utc(2026, 8, 11),
              )
              as Success<List<CalendarItem>>)
          .value,
      hasLength(1),
    );
    expect(await repository.softDelete(created.id), isA<Success<void>>());
    expect(
      (await repository.listRange(
                DateTime.utc(2026, 8, 10),
                DateTime.utc(2026, 8, 11),
              )
              as Success<List<CalendarItem>>)
          .value,
      isEmpty,
    );
  });

  test('projects due tasks and rejects invalid ranges', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await DriftTaskRepository(database).create(
      TaskDraft(title: 'Due task', dueAt: DateTime.utc(2026, 8, 10, 10)),
    );
    final repository = DriftCalendarRepository(database);
    final items =
        (await repository.listRange(
                  DateTime.utc(2026, 8, 10),
                  DateTime.utc(2026, 8, 11),
                )
                as Success<List<CalendarItem>>)
            .value;
    expect(items.single.kind, CalendarItemKind.task);
    expect(
      await repository.listRange(
        DateTime.utc(2026, 8, 11),
        DateTime.utc(2026, 8, 10),
      ),
      isA<FailureResult<List<CalendarItem>>>(),
    );
  });
}
