import 'package:drift/drift.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/statistics_models.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/services/statistics_calculator.dart';

final class DriftStatisticsRepository implements StatisticsRepository {
  DriftStatisticsRepository(this._database, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<Result<StatisticsReport>> loadReport({
    required DateTime selection,
    required StatisticsGranularity granularity,
    int? projectId,
  }) async {
    final range = StatisticsRange.forSelection(selection, granularity);
    final rebuilt = await rebuildRange(range, projectId: projectId);
    if (rebuilt case FailureResult<void>(:final failure)) {
      return FailureResult(failure);
    }
    try {
      final scope = _scope(projectId);
      final rows =
          await (_database.select(_database.dailyStatisticsProjections)
                ..where(
                  (row) =>
                      row.scopeKey.equals(scope) &
                      row.periodStartUtc.isBiggerOrEqualValue(
                        _micros(range.start),
                      ) &
                      row.periodStartUtc.isSmallerThanValue(_micros(range.end)),
                )
                ..orderBy([(row) => OrderingTerm.asc(row.periodStartUtc)]))
              .get();
      final daily = rows
          .map(
            (row) => DailyStatistics(
              periodStart: _date(row.periodStartUtc),
              periodEnd: _date(row.periodEndUtc),
              eligibleCount: row.eligibleCount,
              completedByEndCount: row.completedByEndCount,
              onTimeCount: row.onTimeCount,
              delayTotalMicroseconds: row.delayTotalMicroseconds,
              delaySampleCount: row.delaySampleCount,
            ),
          )
          .toList(growable: false);
      return Success(
        StatisticsCalculator.aggregate(
          range: range,
          granularity: granularity,
          daily: daily,
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'statistics_report_failed',
          safeMessage: 'Statistics could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> rebuildRange(
    StatisticsRange range, {
    int? projectId,
  }) async {
    try {
      await _database.transaction(() async {
        var day = range.start;
        while (day.isBefore(range.end)) {
          await _rebuildDay(day, projectId);
          day = DateTime(day.year, day.month, day.day + 1);
        }
      });
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'statistics_rebuild_failed',
          safeMessage: 'Statistics could not be rebuilt safely.',
        ),
      );
    }
  }

  Future<void> _rebuildDay(DateTime localDay, int? projectId) async {
    final start = DateTime(localDay.year, localDay.month, localDay.day);
    final end = DateTime(localDay.year, localDay.month, localDay.day + 1);
    final startMicros = _micros(start);
    final endMicros = _micros(end);
    final projectClause = projectId == null ? '' : 'AND t.project_id = ?';
    final projectVariable = projectId == null
        ? const <Variable<Object>>[]
        : <Variable<Object>>[Variable.withInt(projectId)];
    final dueRows = await _database
        .customSelect(
          'SELECT t.id, t.due_at, t.status, t.completed_at, '
          '(SELECT h.new_state FROM task_state_history h '
          'WHERE h.task_id = t.id AND h.changed_at < ? '
          'ORDER BY h.changed_at DESC, h.id DESC LIMIT 1) AS state_at_end, '
          '(SELECT h.changed_at FROM task_state_history h '
          "WHERE h.task_id = t.id AND h.new_state = 'completed' "
          'AND h.changed_at < ? ORDER BY h.changed_at DESC, h.id DESC LIMIT 1) '
          'AS completed_at_end '
          'FROM tasks t WHERE t.due_at >= ? AND t.due_at < ? $projectClause',
          variables: [
            Variable.withInt(endMicros),
            Variable.withInt(endMicros),
            Variable.withInt(startMicros),
            Variable.withInt(endMicros),
            ...projectVariable,
          ],
          readsFrom: {_database.tasks, _database.taskStateHistory},
        )
        .get();
    const excluded = {'draft', 'archived', 'deleted'};
    var eligible = 0;
    var completed = 0;
    var onTime = 0;
    for (final row in dueRows) {
      final state =
          row.readNullable<String>('state_at_end') ??
          row.read<String>('status');
      if (excluded.contains(state)) continue;
      eligible++;
      if (state == 'completed') {
        completed++;
        final completedAt =
            row.readNullable<int>('completed_at_end') ??
            row.readNullable<int>('completed_at');
        final dueAt = row.read<int>('due_at');
        if (completedAt != null && completedAt <= dueAt) onTime++;
      }
    }

    final delayRows = await _database
        .customSelect(
          'SELECT t.id, t.due_at, '
          'COALESCE(MAX(h.changed_at), t.completed_at) AS completed_at '
          'FROM tasks t LEFT JOIN task_state_history h ON h.task_id = t.id '
          "AND h.new_state = 'completed' AND h.changed_at >= ? "
          'AND h.changed_at < ? WHERE t.due_at IS NOT NULL '
          'AND ((t.completed_at >= ? AND t.completed_at < ?) OR h.id IS NOT NULL) '
          '$projectClause '
          'GROUP BY t.id, t.due_at',
          variables: [
            Variable.withInt(startMicros),
            Variable.withInt(endMicros),
            Variable.withInt(startMicros),
            Variable.withInt(endMicros),
            ...projectVariable,
          ],
          readsFrom: {_database.tasks, _database.taskStateHistory},
        )
        .get();
    var delayTotal = 0;
    for (final row in delayRows) {
      final delay = row.read<int>('completed_at') - row.read<int>('due_at');
      if (delay > 0) delayTotal += delay;
    }
    await _database.customStatement(
      'INSERT INTO daily_statistics_projections('
      'scope_key,project_id,period_start_utc,period_end_utc,'
      'timezone_offset_minutes,eligible_count,completed_by_end_count,'
      'on_time_count,delay_total_microseconds,delay_sample_count,rebuilt_at) '
      'VALUES (?,?,?,?,?,?,?,?,?,?,?) '
      'ON CONFLICT(scope_key,period_start_utc) DO UPDATE SET '
      'project_id=excluded.project_id,period_end_utc=excluded.period_end_utc,'
      'timezone_offset_minutes=excluded.timezone_offset_minutes,'
      'eligible_count=excluded.eligible_count,'
      'completed_by_end_count=excluded.completed_by_end_count,'
      'on_time_count=excluded.on_time_count,'
      'delay_total_microseconds=excluded.delay_total_microseconds,'
      'delay_sample_count=excluded.delay_sample_count,'
      'rebuilt_at=excluded.rebuilt_at',
      [
        _scope(projectId),
        projectId,
        startMicros,
        endMicros,
        start.timeZoneOffset.inMinutes,
        eligible,
        completed,
        onTime,
        delayTotal,
        delayRows.length,
        _clock().toUtc().microsecondsSinceEpoch,
      ],
    );
  }

  String _scope(int? projectId) =>
      projectId == null ? 'all' : 'project:$projectId';
  int _micros(DateTime value) => value.toUtc().microsecondsSinceEpoch;
  DateTime _date(int value) =>
      DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
}
