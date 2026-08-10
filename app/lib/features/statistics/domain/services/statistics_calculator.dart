import '../entities/statistics_models.dart';

abstract final class StatisticsCalculator {
  static StatisticsReport aggregate({
    required StatisticsRange range,
    required StatisticsGranularity granularity,
    required List<DailyStatistics> daily,
  }) => StatisticsReport(
    range: range,
    granularity: granularity,
    daily: List.unmodifiable(daily),
    eligibleCount: daily.fold(0, (sum, item) => sum + item.eligibleCount),
    completedByEndCount: daily.fold(
      0,
      (sum, item) => sum + item.completedByEndCount,
    ),
    onTimeCount: daily.fold(0, (sum, item) => sum + item.onTimeCount),
    delayTotalMicroseconds: daily.fold(
      0,
      (sum, item) => sum + item.delayTotalMicroseconds,
    ),
    delaySampleCount: daily.fold(
      0,
      (sum, item) => sum + item.delaySampleCount,
    ),
  );
}
