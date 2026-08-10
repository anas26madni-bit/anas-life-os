enum StatisticsGranularity { day, week, month, year }

final class StatisticsRange {
  const StatisticsRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  static StatisticsRange forSelection(
    DateTime selection,
    StatisticsGranularity granularity,
  ) {
    final local = selection.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    return switch (granularity) {
      StatisticsGranularity.day => StatisticsRange(
        start: day,
        end: day.add(const Duration(days: 1)),
      ),
      StatisticsGranularity.week => _week(day),
      StatisticsGranularity.month => StatisticsRange(
        start: DateTime(day.year, day.month),
        end: DateTime(day.year, day.month + 1),
      ),
      StatisticsGranularity.year => StatisticsRange(
        start: DateTime(day.year),
        end: DateTime(day.year + 1),
      ),
    };
  }

  static StatisticsRange _week(DateTime day) {
    final start = day.subtract(Duration(days: day.weekday - DateTime.monday));
    return StatisticsRange(
      start: start,
      end: start.add(const Duration(days: 7)),
    );
  }
}

final class DailyStatistics {
  const DailyStatistics({
    required this.periodStart,
    required this.periodEnd,
    required this.eligibleCount,
    required this.completedByEndCount,
    required this.onTimeCount,
    required this.delayTotalMicroseconds,
    required this.delaySampleCount,
  });

  final DateTime periodStart;
  final DateTime periodEnd;
  final int eligibleCount;
  final int completedByEndCount;
  final int onTimeCount;
  final int delayTotalMicroseconds;
  final int delaySampleCount;

  double? get completionRate =>
      eligibleCount == 0 ? null : completedByEndCount / eligibleCount * 100;
  double? get onTimeRate =>
      eligibleCount == 0 ? null : onTimeCount / eligibleCount * 100;
  Duration? get averageDelay => delaySampleCount == 0
      ? null
      : Duration(microseconds: delayTotalMicroseconds ~/ delaySampleCount);
}

final class StatisticsReport {
  const StatisticsReport({
    required this.range,
    required this.granularity,
    required this.daily,
    required this.eligibleCount,
    required this.completedByEndCount,
    required this.onTimeCount,
    required this.delayTotalMicroseconds,
    required this.delaySampleCount,
  });

  final StatisticsRange range;
  final StatisticsGranularity granularity;
  final List<DailyStatistics> daily;
  final int eligibleCount;
  final int completedByEndCount;
  final int onTimeCount;
  final int delayTotalMicroseconds;
  final int delaySampleCount;

  double? get completionRate =>
      eligibleCount == 0 ? null : completedByEndCount / eligibleCount * 100;
  double? get onTimeRate =>
      eligibleCount == 0 ? null : onTimeCount / eligibleCount * 100;
  int? get productivityScore {
    final completion = completionRate;
    final onTime = onTimeRate;
    if (completion == null || onTime == null) return null;
    return (completion * .70 + onTime * .30).round().clamp(0, 100);
  }

  Duration? get averageDelay => delaySampleCount == 0
      ? null
      : Duration(microseconds: delayTotalMicroseconds ~/ delaySampleCount);
}
