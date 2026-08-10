import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/statistics/data/repositories/drift_statistics_repository.dart';
import 'package:anas_life_os/features/statistics/domain/entities/statistics_models.dart';
import 'package:anas_life_os/features/tasks/data/repositories/drift_task_repository.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/database_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('statistics rebuild remains offline and deterministic', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await DriftTaskRepository(
      database,
      clock: () => DateTime(2026, 8, 10, 10),
    ).create(
      TaskDraft(
        title: 'Offline report task',
        dueAt: DateTime(2026, 8, 10, 12),
        status: TaskStatus.completed,
      ),
    );
    final repository = DriftStatisticsRepository(database);
    final first = await repository.loadReport(
      selection: DateTime(2026, 8, 10),
      granularity: StatisticsGranularity.day,
    );
    final second = await repository.loadReport(
      selection: DateTime(2026, 8, 10),
      granularity: StatisticsGranularity.day,
    );
    expect((first as Success<StatisticsReport>).value.productivityScore, 100);
    expect((second as Success<StatisticsReport>).value.productivityScore, 100);
    final projectionCount =
        (await database
                .customSelect(
                  'SELECT COUNT(*) AS total FROM daily_statistics_projections',
                )
                .getSingle())
            .read<int>('total');
    expect(projectionCount, 1);
    await database.verifyIntegrity();
  });
}
