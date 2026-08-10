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

  test('uses half-open local day, month, and year boundaries', () {
    final day = StatisticsRange.forSelection(
      DateTime(2026, 12, 31, 23),
      StatisticsGranularity.day,
    );
    final month = StatisticsRange.forSelection(
      DateTime(2026, 12, 15),
      StatisticsGranularity.month,
    );
    final year = StatisticsRange.forSelection(
      DateTime(2026, 6, 15),
      StatisticsGranularity.year,
    );

    expect(day.start, DateTime(2026, 12, 31));
    expect(day.end, DateTime(2027));
    expect(month.start, DateTime(2026, 12));
    expect(month.end, DateTime(2027));
    expect(year.start, DateTime(2026));
    expect(year.end, DateTime(2027));
  });

  test('daily projection exposes weighted source measures', () {
    final start = DateTime(2026, 8, 10);
    final populated = DailyStatistics(
      periodStart: start,
      periodEnd: start.add(const Duration(days: 1)),
      eligibleCount: 4,
      completedByEndCount: 3,
      onTimeCount: 2,
      delayTotalMicroseconds: const Duration(minutes: 45).inMicroseconds,
      delaySampleCount: 3,
    );
    final empty = DailyStatistics(
      periodStart: start,
      periodEnd: start.add(const Duration(days: 1)),
      eligibleCount: 0,
      completedByEndCount: 0,
      onTimeCount: 0,
      delayTotalMicroseconds: 0,
      delaySampleCount: 0,
    );

    expect(populated.completionRate, 75);
    expect(populated.onTimeRate, 50);
    expect(populated.averageDelay, const Duration(minutes: 15));
    expect(empty.completionRate, isNull);
    expect(empty.onTimeRate, isNull);
    expect(empty.averageDelay, isNull);
  });

  test('aggregates daily source counts instead of averaging percentages', () {
    final start = DateTime(2026, 8, 10);
    DailyStatistics point(
      int offset,
      int eligible,
      int completed,
      int onTime,
    ) => DailyStatistics(
      periodStart: start.add(Duration(days: offset)),
      periodEnd: start.add(Duration(days: offset + 1)),
      eligibleCount: eligible,
      completedByEndCount: completed,
      onTimeCount: onTime,
      delayTotalMicroseconds: const Duration(hours: 1).inMicroseconds,
      delaySampleCount: 1,
    );

    final report = StatisticsCalculator.aggregate(
      range: StatisticsRange(
        start: start,
        end: start.add(const Duration(days: 2)),
      ),
      granularity: StatisticsGranularity.week,
      daily: [point(0, 1, 1, 1), point(1, 3, 1, 0)],
    );

    expect(report.eligibleCount, 4);
    expect(report.completedByEndCount, 2);
    expect(report.onTimeCount, 1);
    expect(report.completionRate, 50);
    expect(report.onTimeRate, 25);
    expect(report.productivityScore, 43);
    expect(report.averageDelay, const Duration(hours: 1));
    expect(report.daily, hasLength(2));
  });
}
