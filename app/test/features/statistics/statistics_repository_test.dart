import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/statistics/data/repositories/drift_statistics_repository.dart';
import 'package:anas_life_os/features/statistics/domain/entities/statistics_models.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_entity.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test(
    'rebuilds daily projections from task records and state history',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);

      await DriftTaskRepository(
        database,
        clock: () => DateTime(2026, 8, 4, 12),
      ).create(
        TaskDraft(
          title: 'On time',
          dueAt: DateTime(2026, 8, 4, 18),
          status: TaskStatus.completed,
        ),
      );
      await DriftTaskRepository(
        database,
        clock: () => DateTime(2026, 8, 5, 12),
      ).create(
        TaskDraft(
          title: 'Late',
          dueAt: DateTime(2026, 8, 5, 9),
          status: TaskStatus.completed,
        ),
      );
      final pending =
          (await DriftTaskRepository(
                    database,
                    clock: () => DateTime(2026, 8, 6, 8),
                  ).create(
                    TaskDraft(
                      title: 'Pending',
                      dueAt: DateTime(2026, 8, 6, 18),
                    ),
                  )
                  as Success<TaskEntity>)
              .value;

      final repository = DriftStatisticsRepository(database);
      final first =
          (await repository.loadReport(
                    selection: DateTime(2026, 8, 5),
                    granularity: StatisticsGranularity.week,
                  )
                  as Success<StatisticsReport>)
              .value;
      expect(first.eligibleCount, 3);
      expect(first.completedByEndCount, 2);
      expect(first.onTimeCount, 1);
      expect(first.productivityScore, 57);
      expect(first.averageDelay, const Duration(minutes: 90));

      await DriftTaskRepository(
        database,
        clock: () => DateTime(2026, 8, 7),
      ).update(
        pending.id,
        TaskDraft(
          title: pending.title,
          dueAt: DateTime(2026, 8, 20, 18),
          status: pending.status,
          priority: pending.priority,
        ),
      );
      final corrected =
          (await repository.loadReport(
                    selection: DateTime(2026, 8, 5),
                    granularity: StatisticsGranularity.week,
                  )
                  as Success<StatisticsReport>)
              .value;
      expect(corrected.eligibleCount, 2);

      final projectionCount =
          (await database
                  .customSelect(
                    'SELECT COUNT(*) AS total FROM daily_statistics_projections',
                  )
                  .getSingle())
              .read<int>('total');
      expect(projectionCount, 7);
      await database.verifyIntegrity();
    },
  );
}
