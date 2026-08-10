import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/statistics/domain/entities/statistics_models.dart';
import 'package:anas_life_os/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:anas_life_os/features/statistics/presentation/pages/statistics_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows accessible reports and Urdu RTL', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsRepositoryProvider.overrideWith(
            (ref) async => const _FakeStatisticsRepository(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('ur'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StatisticsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SegmentedButton<StatisticsGranularity>), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
    expect(find.byType(LinearProgressIndicator), findsWidgets);
    expect(find.text('74'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final class _FakeStatisticsRepository implements StatisticsRepository {
  const _FakeStatisticsRepository();

  @override
  Future<Result<StatisticsReport>> loadReport({
    required DateTime selection,
    required StatisticsGranularity granularity,
    int? projectId,
  }) async {
    final range = StatisticsRange.forSelection(selection, granularity);
    return Success(
      StatisticsReport(
        range: range,
        granularity: granularity,
        daily: [
          DailyStatistics(
            periodStart: range.start,
            periodEnd: range.start.add(const Duration(days: 1)),
            eligibleCount: 10,
            completedByEndCount: 8,
            onTimeCount: 6,
            delayTotalMicroseconds: const Duration(hours: 2).inMicroseconds,
            delaySampleCount: 2,
          ),
        ],
        eligibleCount: 10,
        completedByEndCount: 8,
        onTimeCount: 6,
        delayTotalMicroseconds: const Duration(hours: 2).inMicroseconds,
        delaySampleCount: 2,
      ),
    );
  }

  @override
  Future<Result<void>> rebuildRange(
    StatisticsRange range, {
    int? projectId,
  }) async => const Success(null);
}
