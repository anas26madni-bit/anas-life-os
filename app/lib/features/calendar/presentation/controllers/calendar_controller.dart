import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/calendar_models.dart';

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, CalendarState>(
      CalendarController.new,
    );

final class CalendarState {
  const CalendarState({
    required this.anchor,
    required this.view,
    required this.items,
  });
  final DateTime anchor;
  final CalendarViewMode view;
  final List<CalendarItem> items;
}

class CalendarController extends AsyncNotifier<CalendarState> {
  DateTime _anchor = DateTime.now();
  CalendarViewMode _view = CalendarViewMode.month;

  @override
  Future<CalendarState> build() async {
    final repository = await ref.watch(calendarRepositoryProvider.future);
    final range = _range(_anchor, _view);
    return CalendarState(
      anchor: _anchor,
      view: _view,
      items: _unwrap(await repository.listRange(range.$1, range.$2)),
    );
  }

  Future<void> selectView(CalendarViewMode view) async {
    _view = view;
    state = await AsyncValue.guard(build);
  }

  Future<void> move(int direction) async {
    _anchor = switch (_view) {
      CalendarViewMode.day ||
      CalendarViewMode.timeline => _anchor.add(Duration(days: direction)),
      CalendarViewMode.week ||
      CalendarViewMode.agenda => _anchor.add(Duration(days: direction * 7)),
      CalendarViewMode.month || CalendarViewMode.heatMap => DateTime(
        _anchor.year,
        _anchor.month + direction,
        _anchor.day,
      ),
      CalendarViewMode.year => DateTime(_anchor.year + direction, 1),
    };
    state = await AsyncValue.guard(build);
  }

  Future<void> create(String title, DateTime start, DateTime end) async {
    final repository = await ref.read(calendarRepositoryProvider.future);
    _unwrap(
      await repository.create(
        CalendarEventDraft(title: title, startAt: start, endAt: end),
      ),
    );
    state = await AsyncValue.guard(build);
  }

  (DateTime, DateTime) _range(DateTime anchor, CalendarViewMode view) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    return switch (view) {
      CalendarViewMode.day ||
      CalendarViewMode.timeline => (day, day.add(const Duration(days: 1))),
      CalendarViewMode.week ||
      CalendarViewMode.agenda => (day, day.add(const Duration(days: 7))),
      CalendarViewMode.month || CalendarViewMode.heatMap => (
        DateTime(day.year, day.month),
        DateTime(day.year, day.month + 1),
      ),
      CalendarViewMode.year => (DateTime(day.year), DateTime(day.year + 1)),
    };
  }

  T _unwrap<T>(Result<T> result) => switch (result) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw StateError(failure.safeMessage),
  };
}
