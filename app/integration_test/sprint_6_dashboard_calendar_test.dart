import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/calendar/data/repositories/drift_calendar_repository.dart';
import 'package:anas_life_os/features/calendar/domain/entities/calendar_models.dart';
import 'package:anas_life_os/features/dashboard/data/repositories/drift_dashboard_repository.dart';
import 'package:anas_life_os/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/database_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dashboard customization and calendar work offline', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final dashboard = DriftDashboardRepository(database);
    final preferences =
        (await dashboard.loadPreferences()
                as Success<List<DashboardWidgetPreference>>)
            .value;
    await dashboard.savePreferences([
      preferences.first.copyWith(visible: false),
      ...preferences.skip(1),
    ]);
    expect(
      (await dashboard.loadPreferences()
              as Success<List<DashboardWidgetPreference>>)
          .value
          .first
          .visible,
      isFalse,
    );

    final calendar = DriftCalendarRepository(database);
    final start = DateTime.utc(2026, 8, 7, 9);
    await calendar.create(
      CalendarEventDraft(
        title: 'Offline event',
        startAt: start,
        endAt: start.add(const Duration(hours: 1)),
      ),
    );
    expect(
      (await calendar.listRange(
                DateTime.utc(2026, 8, 7),
                DateTime.utc(2026, 8, 8),
              )
              as Success<List<CalendarItem>>)
          .value
          .single
          .title,
      'Offline event',
    );
    await database.verifyIntegrity();
  });
}
