import 'package:anas_life_os/app/app.dart';
import 'package:anas_life_os/core/database/database_foundation_status.dart';
import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/core/router/app_router.dart';
import 'package:anas_life_os/features/calendar/domain/entities/calendar_models.dart';
import 'package:anas_life_os/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:anas_life_os/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:anas_life_os/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/database_test_harness.dart';

void main() {
  testWidgets('startup enters the shared five-tab shell', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseInitializerProvider.overrideWithValue(
            FakeDatabaseInitializer(
              const DatabaseFoundationReport(
                status: DatabaseFoundationStatus.ready,
              ),
            ),
          ),
          appDatabaseProvider.overrideWith((ref) async => database),
          securityPlatformProvider.overrideWithValue(
            const FakeSecurityPlatform(),
          ),
          dashboardRepositoryProvider.overrideWith(
            (ref) async => _DashboardRepository(),
          ),
          calendarRepositoryProvider.overrideWith(
            (ref) async => const _CalendarRepository(),
          ),
        ],
        child: const AnasLifeOsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in [
      'Dashboard',
      'Tasks',
      'Calendar',
      'Knowledge Vault',
      'More',
    ]) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.byTooltip('Search'), findsOneWidget);
    expect(appRouter.state.uri.path, '/dashboard');
    expect(tester.takeException(), isNull);
  });

  testWidgets('tab switching keeps one shared shell', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    appRouter.go('/dashboard');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
          securityPlatformProvider.overrideWithValue(
            const FakeSecurityPlatform(),
          ),
          dashboardRepositoryProvider.overrideWith(
            (ref) async => _DashboardRepository(),
          ),
          calendarRepositoryProvider.overrideWith(
            (ref) async => const _CalendarRepository(),
          ),
        ],
        child: const AnasLifeOsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendar').last);
    await tester.pump();
    expect(appRouter.state.uri.path, '/calendar');
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Dashboard').last);
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, '/dashboard');
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

final class _CalendarRepository implements CalendarRepository {
  const _CalendarRepository();

  @override
  Future<Result<CalendarEvent>> create(CalendarEventDraft draft) async =>
      throw UnimplementedError();

  @override
  Future<Result<List<CalendarItem>>> listRange(
    DateTime start,
    DateTime end,
  ) async => const Success([]);

  @override
  Future<Result<void>> softDelete(int id) async => const Success(null);

  @override
  Future<Result<CalendarEvent>> update(
    int id,
    CalendarEventDraft draft,
  ) async => throw UnimplementedError();
}

final class _DashboardRepository implements DashboardRepository {
  static const snapshot = DashboardSnapshot(
    today: 0,
    tomorrow: 0,
    pending: 0,
    overdue: 0,
    completedToday: 0,
    upcoming: 0,
    favorites: 0,
    recentKnowledge: 0,
  );

  final preferences = const [
    DashboardWidgetPreference(
      kind: DashboardWidgetKind.today,
      visible: true,
      sortOrder: 0,
      size: DashboardWidgetSize.compact,
    ),
  ];

  @override
  Future<Result<DashboardSnapshot>> loadSnapshot(DateTime now) async =>
      const Success(snapshot);

  @override
  Future<Result<List<DashboardWidgetPreference>>> loadPreferences() async =>
      Success(preferences);

  @override
  Future<Result<List<DashboardWidgetPreference>>> resetPreferences() async =>
      Success(preferences);

  @override
  Future<Result<void>> savePreferences(
    List<DashboardWidgetPreference> preferences,
  ) async => const Success(null);
}
