import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/calendar/domain/entities/calendar_models.dart';
import 'package:anas_life_os/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:anas_life_os/features/calendar/presentation/pages/calendar_page.dart';
import 'package:anas_life_os/features/dashboard/domain/entities/dashboard_models.dart';
import 'package:anas_life_os/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:anas_life_os/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard supports large text and customization', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWith(
            (ref) async => _FakeDashboardRepository(),
          ),
        ],
        child: const _TestApp(home: DashboardPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    await tester.tap(find.byTooltip('Customize dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Reset'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('calendar exposes every approved view in RTL', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarRepositoryProvider.overrideWith(
            (ref) async => _FakeCalendarRepository(),
          ),
        ],
        child: const _TestApp(home: CalendarPage(), locale: Locale('ur')),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
    for (final label in [
      'دن',
      'ہفتہ',
      'مہینہ',
      'سال',
      'ایجنڈا',
      'ٹائم لائن',
      'ہیٹ میپ',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.home, this.locale});
  final Widget home;
  final Locale? locale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.4)),
      child: child!,
    ),
    home: home,
  );
}

final class _FakeDashboardRepository implements DashboardRepository {
  final preferences = DriftDefaults.preferences;

  @override
  Future<Result<DashboardSnapshot>> loadSnapshot(DateTime now) async =>
      const Success(
        DashboardSnapshot(
          today: 1,
          tomorrow: 2,
          pending: 3,
          overdue: 0,
          completedToday: 1,
          upcoming: 4,
          favorites: 1,
          recentKnowledge: 2,
        ),
      );

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

abstract final class DriftDefaults {
  static final preferences = DashboardWidgetKind.values.indexed
      .map(
        (entry) => DashboardWidgetPreference(
          kind: entry.$2,
          visible: true,
          sortOrder: entry.$1,
          size: DashboardWidgetSize.regular,
        ),
      )
      .toList(growable: false);
}

final class _FakeCalendarRepository implements CalendarRepository {
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
