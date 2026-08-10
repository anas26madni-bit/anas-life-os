import 'package:anas_life_os/features/statistics/domain/entities/statistics_models.dart';
import 'package:anas_life_os/features/statistics/domain/services/statistics_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the approved completion, delay, and productivity formulas', () {
    final start = DateTime(2026, 8, 10);
    final report = StatisticsCalculator.aggregate(
      range: StatisticsRange(
        start: start,
        end: start.add(const Duration(days: 1)),
      ),
      granularity: StatisticsGranularity.day,
      daily: [
        DailyStatistics(
          periodStart: start,
          periodEnd: start.add(const Duration(days: 1)),
          eligibleCount: 10,
          completedByEndCount: 8,
          onTimeCount: 6,
          delayTotalMicroseconds: const Duration(hours: 6).inMicroseconds,
          delaySampleCount: 2,
        ),
      ],
    );

    expect(report.completionRate, 80);
    expect(report.onTimeRate, 60);
    expect(report.productivityScore, 74);
    expect(report.averageDelay, const Duration(hours: 3));
  });

  test('returns unavailable metrics for an empty cohort', () {
    final range = StatisticsRange.forSelection(
      DateTime(2026, 8, 10),
      StatisticsGranularity.week,
    );
    final report = StatisticsCalculator.aggregate(
      range: range,
      granularity: StatisticsGranularity.week,
      daily: const [],
    );

    expect(report.completionRate, isNull);
    expect(report.onTimeRate, isNull);
    expect(report.productivityScore, isNull);
    expect(report.averageDelay, isNull);
    expect(range.start.weekday, DateTime.monday);
  });
}
