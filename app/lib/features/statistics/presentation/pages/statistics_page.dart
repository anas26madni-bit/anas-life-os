import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../../domain/entities/statistics_models.dart';
import '../controllers/statistics_controller.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({this.projectId, super.key});

  final int? projectId;

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  DateTime _selection = DateTime.now();
  StatisticsGranularity _granularity = StatisticsGranularity.week;

  StatisticsRequest get _request => StatisticsRequest(
    selection: _selection,
    granularity: _granularity,
    projectId: widget.projectId,
  );

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final report = ref.watch(statisticsReportProvider(_request));
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.statisticsTitle)),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SegmentedButton<StatisticsGranularity>(
                segments: [
                  ButtonSegment(
                    value: StatisticsGranularity.day,
                    label: Text(localization.dayView),
                  ),
                  ButtonSegment(
                    value: StatisticsGranularity.week,
                    label: Text(localization.weekView),
                  ),
                  ButtonSegment(
                    value: StatisticsGranularity.month,
                    label: Text(localization.monthView),
                  ),
                  ButtonSegment(
                    value: StatisticsGranularity.year,
                    label: Text(localization.yearView),
                  ),
                ],
                selected: {_granularity},
                onSelectionChanged: (value) => setState(() {
                  _granularity = value.single;
                }),
              ),
            ),
            _PeriodNavigation(
              range: StatisticsRange.forSelection(_selection, _granularity),
              onMove: _move,
            ),
            Expanded(
              child: report.when(
                loading: LoadingStateView.new,
                error: (error, _) => ErrorStateView(
                  message: localization.unavailableTitle,
                  onRetry: () =>
                      ref.invalidate(statisticsReportProvider(_request)),
                ),
                data: (value) => _ReportBody(
                  report: value,
                  onRefresh: () async {
                    ref.invalidate(statisticsReportProvider(_request));
                    await ref.read(statisticsReportProvider(_request).future);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _move(int direction) => setState(() {
    _selection = switch (_granularity) {
      StatisticsGranularity.day => _selection.add(Duration(days: direction)),
      StatisticsGranularity.week => _selection.add(
        Duration(days: direction * 7),
      ),
      StatisticsGranularity.month => DateTime(
        _selection.year,
        _selection.month + direction,
        1,
      ),
      StatisticsGranularity.year => DateTime(_selection.year + direction, 1),
    };
  });
}

class _PeriodNavigation extends StatelessWidget {
  const _PeriodNavigation({required this.range, required this.onMove});

  final StatisticsRange range;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final rtl = Directionality.of(context) == ui.TextDirection.rtl;
    final text = range.end.difference(range.start).inDays == 1
        ? DateFormat.yMMMMd().format(range.start)
        : '${DateFormat.yMMMd().format(range.start)} - '
              '${DateFormat.yMMMd().format(range.end.subtract(const Duration(days: 1)))}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            tooltip: localization.previousPeriod,
            onPressed: () => onMove(-1),
            icon: Icon(rtl ? Icons.chevron_right : Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: localization.nextPeriod,
            onPressed: () => onMove(1),
            icon: Icon(rtl ? Icons.chevron_left : Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.report, required this.onRefresh});

  final StatisticsReport report;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    if (report.eligibleCount == 0 && report.delaySampleCount == 0) {
      return ActionStateView(
        icon: Icons.insights_outlined,
        title: localization.noStatisticsTitle,
        message: localization.noStatisticsMessage,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 600 ? 4 : 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricCard(
                label: localization.completionRate,
                value: _percentage(localization, report.completionRate),
              ),
              _MetricCard(
                label: localization.onTimeRate,
                value: _percentage(localization, report.onTimeRate),
              ),
              _MetricCard(
                label: localization.productivityScore,
                value: report.productivityScore == null
                    ? localization.notAvailable
                    : '${report.productivityScore}',
              ),
              _MetricCard(
                label: localization.averageDelay,
                value: report.averageDelay == null
                    ? localization.notAvailable
                    : localization.minutesValue(report.averageDelay!.inMinutes),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            localization.historicalTrend,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final point in report.daily) _TrendRow(point: point),
        ],
      ),
    );
  }

  static String _percentage(AppLocalizations localization, double? value) =>
      value == null
      ? localization.notAvailable
      : localization.percentageValue(value.round());
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: $value',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.point});

  final DailyStatistics point;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final rate = point.completionRate;
    final label = DateFormat.MMMd().format(point.periodStart);
    final value = rate == null
        ? localization.notAvailable
        : localization.percentageValue(rate.round());
    return Semantics(
      label: '$label: $value',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            SizedBox(width: 72, child: Text(label)),
            Expanded(
              child: LinearProgressIndicator(
                value: rate == null ? 0 : rate / 100,
                semanticsLabel: '$label: $value',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(width: 48, child: Text(value, textAlign: TextAlign.end)),
          ],
        ),
      ),
    );
  }
}
