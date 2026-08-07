import 'package:drift/drift.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../../tasks/domain/entities/task_enums.dart';
import '../../domain/entities/dashboard_models.dart';
import '../../domain/repositories/dashboard_repository.dart';

final class DriftDashboardRepository implements DashboardRepository {
  DriftDashboardRepository(this._database);

  final AppDatabase _database;

  static final defaults = DashboardWidgetKind.values.indexed
      .map(
        (entry) => DashboardWidgetPreference(
          kind: entry.$2,
          visible: true,
          sortOrder: entry.$1,
          size: entry.$2 == DashboardWidgetKind.progress
              ? DashboardWidgetSize.expanded
              : DashboardWidgetSize.regular,
        ),
      )
      .toList(growable: false);

  @override
  Future<Result<DashboardSnapshot>> loadSnapshot(DateTime now) async {
    try {
      final local = now.toLocal();
      final start = DateTime(local.year, local.month, local.day);
      final tomorrow = start.add(const Duration(days: 1));
      final afterTomorrow = tomorrow.add(const Duration(days: 1));
      final weekEnd = start.add(const Duration(days: 7));
      final active = [
        TaskStatus.draft,
        TaskStatus.scheduled,
        TaskStatus.pending,
        TaskStatus.inProgress,
        TaskStatus.waiting,
        TaskStatus.blocked,
      ];
      Future<int> count(Expression<bool> predicate) async {
        final total = _database.tasks.id.count();
        return (_database.selectOnly(_database.tasks)
              ..addColumns([total])
              ..where(_database.tasks.isDeleted.equals(false) & predicate))
            .map((row) => row.read(total) ?? 0)
            .getSingle();
      }

      Expression<bool> between(
        GeneratedColumn<int> column,
        DateTime lower,
        DateTime upper,
      ) => column.isBiggerOrEqualValue(_micros(lower)) &
          column.isSmallerThanValue(_micros(upper));

      final completed = await count(
        _database.tasks.status.equalsValue(TaskStatus.completed) &
            between(_database.tasks.completedAt, start, tomorrow),
      );
      return Success(
        DashboardSnapshot(
          today: await count(between(_database.tasks.dueAt, start, tomorrow)),
          tomorrow: await count(
            between(_database.tasks.dueAt, tomorrow, afterTomorrow),
          ),
          pending: await count(_database.tasks.status.isInValues(active)),
          overdue: await count(
            _database.tasks.dueAt.isSmallerThanValue(_micros(start)) &
                _database.tasks.status.isInValues(active),
          ),
          completedToday: completed,
          upcoming: await count(between(_database.tasks.dueAt, start, weekEnd)),
          favorites: await count(
            _database.tasks.favorite.equals(true) |
                _database.tasks.pinned.equals(true),
          ),
          recentKnowledge: await _knowledgeCount(),
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'dashboard_snapshot_failed',
          safeMessage: 'Dashboard information could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<List<DashboardWidgetPreference>>> loadPreferences() async {
    try {
      var rows = await _preferenceRows();
      if (rows.isEmpty) {
        await _write(defaults);
        rows = await _preferenceRows();
      }
      return Success(
        rows
            .map(
              (row) => DashboardWidgetPreference(
                kind: row.kind,
                visible: row.visible,
                sortOrder: row.sortOrder,
                size: row.size,
              ),
            )
            .toList(growable: false),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'dashboard_preferences_failed',
          safeMessage: 'Dashboard preferences could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> savePreferences(
    List<DashboardWidgetPreference> preferences,
  ) async {
    if (preferences.map((item) => item.kind).toSet().length !=
        preferences.length) {
      return const FailureResult(
        ValidationFailure(
          code: 'duplicate_dashboard_widget',
          safeMessage: 'Each dashboard widget can appear only once.',
        ),
      );
    }
    try {
      await _write(preferences);
      return const Success(null);
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'dashboard_preferences_save_failed',
          safeMessage: 'Dashboard preferences could not be saved.',
        ),
      );
    }
  }

  @override
  Future<Result<List<DashboardWidgetPreference>>> resetPreferences() async {
    final saved = await savePreferences(defaults);
    return switch (saved) {
      Success<void>() => Success(defaults),
      FailureResult<void>(:final failure) => FailureResult(failure),
    };
  }

  Future<List<DashboardWidgetPreferenceRow>> _preferenceRows() =>
      (_database.select(_database.dashboardWidgetPreferences)
            ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]))
          .get();

  Future<void> _write(List<DashboardWidgetPreference> preferences) =>
      _database.transaction(() async {
        await _database.delete(_database.dashboardWidgetPreferences).go();
        for (final entry in preferences.indexed) {
          await _database.into(_database.dashboardWidgetPreferences).insert(
                DashboardWidgetPreferencesCompanion.insert(
                  kind: entry.$2.kind,
                  visible: Value(entry.$2.visible),
                  sortOrder: entry.$1,
                  size: entry.$2.size,
                  updatedAt: _micros(DateTime.now()),
                ),
              );
        }
      });

  Future<int> _knowledgeCount() async {
    final total = _database.knowledgeNotes.id.count();
    return (_database.selectOnly(_database.knowledgeNotes)
          ..addColumns([total])
          ..where(_database.knowledgeNotes.isDeleted.equals(false)))
        .map((row) => row.read(total) ?? 0)
        .getSingle();
  }

  int _micros(DateTime value) => value.toUtc().microsecondsSinceEpoch;
}
