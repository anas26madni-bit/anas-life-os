import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/dashboard/data/repositories/drift_dashboard_repository.dart';
import 'package:anas_life_os/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('persists dashboard visibility, order, size, and reset', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftDashboardRepository(database);

    final defaults =
        (await repository.loadPreferences()
                as Success<List<DashboardWidgetPreference>>)
            .value;
    final changed = [
      defaults[1].copyWith(visible: false, size: DashboardWidgetSize.compact),
      defaults[0],
      ...defaults.skip(2),
    ];
    expect(await repository.savePreferences(changed), isA<Success<void>>());
    final loaded =
        (await repository.loadPreferences()
                as Success<List<DashboardWidgetPreference>>)
            .value;
    expect(loaded.first.kind, defaults[1].kind);
    expect(loaded.first.visible, isFalse);
    expect(loaded.first.size, DashboardWidgetSize.compact);
    expect(
      (await repository.resetPreferences()
              as Success<List<DashboardWidgetPreference>>)
          .value
          .first
          .kind,
      DashboardWidgetKind.today,
    );
  });

  test('calculates task summaries using local calendar boundaries', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final tasks = DriftTaskRepository(
      database,
      clock: () => DateTime.utc(2026, 8, 7, 12),
    );
    await tasks.create(
      TaskDraft(
        title: 'Today',
        dueAt: DateTime.utc(2026, 8, 7, 15),
        status: TaskStatus.pending,
      ),
    );
    await tasks.create(
      TaskDraft(
        title: 'Overdue',
        dueAt: DateTime.utc(2026, 8, 6, 15),
        status: TaskStatus.pending,
      ),
    );
    final snapshot =
        (await DriftDashboardRepository(
                  database,
                ).loadSnapshot(DateTime.utc(2026, 8, 7, 12))
                as Success<DashboardSnapshot>)
            .value;
    expect(snapshot.today, 1);
    expect(snapshot.pending, 2);
    expect(snapshot.overdue, 1);
  });
}
