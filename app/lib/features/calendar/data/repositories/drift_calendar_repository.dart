import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/calendar_models.dart';
import '../../domain/repositories/calendar_repository.dart';

final class DriftCalendarRepository implements CalendarRepository {
  DriftCalendarRepository(
    this._database, {
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  @override
  Future<Result<CalendarEvent>> create(CalendarEventDraft draft) async {
    final failure = _validate(draft);
    if (failure != null) return FailureResult(failure);
    try {
      final now = _micros(_clock());
      final id = await _database.into(_database.calendarEvents).insert(
            CalendarEventsCompanion.insert(
              uuid: _uuidFactory(),
              title: draft.title.trim(),
              startAt: _micros(draft.startAt),
              endAt: _micros(draft.endAt),
              createdAt: now,
              updatedAt: now,
              description: Value(_blankToNull(draft.description)),
              allDay: Value(draft.allDay),
              timezoneId: Value(draft.timezoneId),
              location: Value(_blankToNull(draft.location)),
              color: Value(_blankToNull(draft.color)),
            ),
          );
      return Success(await _require(id));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'calendar_event_create_failed',
          safeMessage: 'The calendar event could not be saved.',
        ),
      );
    }
  }

  @override
  Future<Result<CalendarEvent>> update(
    int id,
    CalendarEventDraft draft,
  ) async {
    final failure = _validate(draft);
    if (failure != null) return FailureResult(failure);
    try {
      final current = await _requireRow(id);
      await (_database.update(
        _database.calendarEvents,
      )..where((row) => row.id.equals(id))).write(
        CalendarEventsCompanion(
          title: Value(draft.title.trim()),
          description: Value(_blankToNull(draft.description)),
          startAt: Value(_micros(draft.startAt)),
          endAt: Value(_micros(draft.endAt)),
          allDay: Value(draft.allDay),
          timezoneId: Value(draft.timezoneId),
          location: Value(_blankToNull(draft.location)),
          color: Value(_blankToNull(draft.color)),
          updatedAt: Value(_micros(_clock())),
          version: Value(current.version + 1),
        ),
      );
      return Success(await _require(id));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'calendar_event_update_failed',
          safeMessage: 'The calendar event could not be updated.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> softDelete(int id) async {
    try {
      final current = await _requireRow(id);
      final now = _micros(_clock());
      await (_database.update(
        _database.calendarEvents,
      )..where((row) => row.id.equals(id))).write(
        CalendarEventsCompanion(
          isDeleted: const Value(true),
          deletedAt: Value(now),
          updatedAt: Value(now),
          version: Value(current.version + 1),
        ),
      );
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'calendar_event_delete_failed',
          safeMessage: 'The calendar event could not be removed.',
        ),
      );
    }
  }

  @override
  Future<Result<List<CalendarItem>>> listRange(
    DateTime start,
    DateTime end,
  ) async {
    if (!end.isAfter(start)) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_calendar_range',
          safeMessage: 'The calendar range is invalid.',
        ),
      );
    }
    try {
      final startValue = _micros(start);
      final endValue = _micros(end);
      final events = await (_database.select(_database.calendarEvents)
            ..where(
              (row) =>
                  row.isDeleted.equals(false) &
                  row.startAt.isSmallerThanValue(endValue) &
                  row.endAt.isBiggerOrEqualValue(startValue),
            ))
          .get();
      final tasks = await (_database.select(_database.tasks)
            ..where(
              (row) =>
                  row.isDeleted.equals(false) &
                  row.dueAt.isBiggerOrEqualValue(startValue) &
                  row.dueAt.isSmallerThanValue(endValue),
            ))
          .get();
      final items = <CalendarItem>[
        ...events.map(
          (event) => CalendarItem(
            id: event.id,
            kind: CalendarItemKind.event,
            title: event.title,
            startAt: _date(event.startAt),
            endAt: _date(event.endAt),
            allDay: event.allDay,
          ),
        ),
        ...tasks.map((task) {
          final due = _date(task.dueAt!);
          return CalendarItem(
            id: task.id,
            kind: CalendarItemKind.task,
            title: task.title,
            startAt: due,
            endAt: due,
            allDay: false,
          );
        }),
      ]..sort((left, right) => left.startAt.compareTo(right.startAt));
      return Success(items);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'calendar_range_failed',
          safeMessage: 'Calendar items could not be loaded.',
        ),
      );
    }
  }

  ValidationFailure? _validate(CalendarEventDraft draft) {
    if (draft.title.trim().isEmpty || draft.title.trim().length > 300) {
      return const ValidationFailure(
        code: 'invalid_calendar_title',
        safeMessage: 'Enter an event title of 300 characters or fewer.',
      );
    }
    if (!draft.endAt.isAfter(draft.startAt)) {
      return const ValidationFailure(
        code: 'invalid_calendar_dates',
        safeMessage: 'The event end must be after its start.',
      );
    }
    if (draft.timezoneId.trim().isEmpty || draft.timezoneId.length > 100) {
      return const ValidationFailure(
        code: 'invalid_calendar_timezone',
        safeMessage: 'The event timezone is invalid.',
      );
    }
    return null;
  }

  Future<CalendarEventRow> _requireRow(int id) async {
    final row = await (_database.select(_database.calendarEvents)
          ..where((row) => row.id.equals(id) & row.isDeleted.equals(false)))
        .getSingleOrNull();
    if (row == null) throw StateError('The calendar event does not exist.');
    return row;
  }

  Future<CalendarEvent> _require(int id) async => _map(await _requireRow(id));
  CalendarEvent _map(CalendarEventRow row) => CalendarEvent(
    id: row.id,
    uuid: row.uuid,
    title: row.title,
    description: row.description,
    startAt: _date(row.startAt),
    endAt: _date(row.endAt),
    allDay: row.allDay,
    timezoneId: row.timezoneId,
    location: row.location,
    color: row.color,
    createdAt: _date(row.createdAt),
    updatedAt: _date(row.updatedAt),
  );
  int _micros(DateTime value) => value.toUtc().microsecondsSinceEpoch;
  DateTime _date(int value) =>
      DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
  String? _blankToNull(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}
