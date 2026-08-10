import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../../domain/entities/calendar_models.dart';
import '../controllers/calendar_controller.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final calendar = ref.watch(calendarControllerProvider);
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.calendarTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createEvent(context, ref),
        icon: const Icon(Icons.event_available_outlined),
        label: Text(localization.addEvent),
      ),
      body: SafeArea(
        child: calendar.when(
          loading: LoadingStateView.new,
          error: (error, stackTrace) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.invalidate(calendarControllerProvider),
          ),
          data: (state) => Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: SegmentedButton<CalendarViewMode>(
                  showSelectedIcon: false,
                  segments: CalendarViewMode.values
                      .map(
                        (view) => ButtonSegment(
                          value: view,
                          label: Text(_viewLabel(localization, view)),
                        ),
                      )
                      .toList(growable: false),
                  selected: {state.view},
                  onSelectionChanged: (selection) => ref
                      .read(calendarControllerProvider.notifier)
                      .selectView(selection.first),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: localization.previousPeriod,
                      onPressed: () => ref
                          .read(calendarControllerProvider.notifier)
                          .move(-1),
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.chevron_right
                            : Icons.chevron_left,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _periodLabel(localization, state.anchor, state.view),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: localization.nextPeriod,
                      onPressed: () =>
                          ref.read(calendarControllerProvider.notifier).move(1),
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _CalendarContent(
                  state: state,
                  onCreate: () => _createEvent(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createEvent(BuildContext context, WidgetRef ref) async {
    final localization = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    var title = '';
    var start = DateTime.now().add(const Duration(hours: 1));
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localization.addEvent),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  autofocus: true,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: localization.eventTitle,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? localization.eventTitleRequired
                      : null,
                  onChanged: (value) => title = value,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(localization.starts),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(start)),
                  trailing: const Icon(Icons.schedule),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: start,
                    );
                    if (date != null) {
                      start = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        start.hour,
                        start.minute,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localization.cancel),
          ),
          FilledButton(
            onPressed: () => formKey.currentState!.validate()
                ? Navigator.pop(dialogContext, true)
                : null,
            child: Text(localization.save),
          ),
        ],
      ),
    );
    if (saved == true) {
      await ref
          .read(calendarControllerProvider.notifier)
          .create(title, start, start.add(const Duration(hours: 1)));
    }
  }

  static String _viewLabel(
    AppLocalizations localization,
    CalendarViewMode view,
  ) => switch (view) {
    CalendarViewMode.day => localization.dayView,
    CalendarViewMode.week => localization.weekView,
    CalendarViewMode.month => localization.monthView,
    CalendarViewMode.year => localization.yearView,
    CalendarViewMode.agenda => localization.agendaView,
    CalendarViewMode.timeline => localization.timelineView,
    CalendarViewMode.heatMap => localization.heatMapView,
  };

  static String _periodLabel(
    AppLocalizations localization,
    DateTime date,
    CalendarViewMode view,
  ) => switch (view) {
    CalendarViewMode.day ||
    CalendarViewMode.timeline => DateFormat.yMMMMd().format(date),
    CalendarViewMode.week || CalendarViewMode.agenda =>
      localization.weekStarting(DateFormat.yMMMd().format(date)),
    CalendarViewMode.month ||
    CalendarViewMode.heatMap => DateFormat.yMMMM().format(date),
    CalendarViewMode.year => DateFormat.y().format(date),
  };
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({required this.state, required this.onCreate});
  final CalendarState state;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    if (state.view == CalendarViewMode.heatMap) {
      final counts = <int, int>{};
      for (final item in state.items) {
        counts.update(
          item.startAt.day,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 96),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemCount: DateUtils.getDaysInMonth(
          state.anchor.year,
          state.anchor.month,
        ),
        itemBuilder: (context, index) {
          final count = counts[index + 1] ?? 0;
          return Semantics(
            label: AppLocalizations.of(
              context,
            ).calendarDayItems(index + 1, count),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer.withAlpha(
                count == 0 ? 40 : (80 + count * 30).clamp(80, 255),
              ),
              child: Center(child: Text('${index + 1}')),
            ),
          );
        },
      );
    }
    if (state.items.isEmpty) {
      return ActionStateView(
        icon: Icons.event_busy_outlined,
        title: AppLocalizations.of(context).noCalendarItems,
        message: AppLocalizations.of(context).noCalendarItemsMessage,
        actionLabel: AppLocalizations.of(context).addEvent,
        onAction: onCreate,
      );
    }
    return switch (state.view) {
      CalendarViewMode.day => _DayTimeline(items: state.items),
      CalendarViewMode.week => _WeekGrid(
        anchor: state.anchor,
        items: state.items,
      ),
      CalendarViewMode.month => _MonthGrid(
        anchor: state.anchor,
        items: state.items,
      ),
      CalendarViewMode.year => _YearGrid(
        anchor: state.anchor,
        items: state.items,
      ),
      CalendarViewMode.agenda => _Agenda(items: state.items),
      CalendarViewMode.timeline => _DayTimeline(
        items: state.items,
        detailed: true,
      ),
      CalendarViewMode.heatMap => const SizedBox.shrink(),
    };
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.items});
  final List<CalendarItem> items;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 96),
    itemCount: items.length,
    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
    itemBuilder: (context, index) {
      final item = items[index];
      return Card(
        child: ListTile(
          leading: Icon(
            item.kind == CalendarItemKind.task
                ? Icons.task_alt
                : Icons.event_outlined,
          ),
          title: Text(item.title),
          subtitle: Text(DateFormat.yMMMd().add_jm().format(item.startAt)),
        ),
      );
    },
  );
}

class _DayTimeline extends StatelessWidget {
  const _DayTimeline({required this.items, this.detailed = false});
  final List<CalendarItem> items;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final ordered = [...items]..sort((a, b) => a.startAt.compareTo(b.startAt));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 96),
      itemCount: ordered.length,
      itemBuilder: (context, index) {
        final item = ordered[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 72,
                child: Text(DateFormat.jm().format(item.startAt.toLocal())),
              ),
              VerticalDivider(
                color: Theme.of(context).colorScheme.primary,
                thickness: 2,
              ),
              Expanded(
                child: Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: detailed
                        ? Text(
                            '${DateFormat.jm().format(item.startAt.toLocal())} – '
                            '${DateFormat.jm().format(item.endAt.toLocal())}',
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.anchor, required this.items});
  final DateTime anchor;
  final List<CalendarItem> items;

  @override
  Widget build(BuildContext context) => ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      0,
      AppSpacing.md,
      AppSpacing.md,
    ),
    itemCount: 7,
    itemBuilder: (context, index) {
      final day = DateTime(
        anchor.year,
        anchor.month,
        anchor.day,
      ).add(Duration(days: index));
      final dayItems = items.where(
        (item) => DateUtils.isSameDay(item.startAt.toLocal(), day),
      );
      return SizedBox(
        width: 152,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DateFormat.E().add_d().format(day),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Divider(),
                for (final item in dayItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      item.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.anchor, required this.items});
  final DateTime anchor;
  final List<CalendarItem> items;

  @override
  Widget build(BuildContext context) {
    final count = DateUtils.getDaysInMonth(anchor.year, anchor.month);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: .72,
      ),
      itemCount: count,
      itemBuilder: (context, index) {
        final day = index + 1;
        final dayItems = items
            .where((item) => item.startAt.toLocal().day == day)
            .toList();
        return Semantics(
          label: AppLocalizations.of(
            context,
          ).calendarDayItems(day, dayItems.length),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Text('$day'),
                  for (final item in dayItems.take(2))
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _YearGrid extends StatelessWidget {
  const _YearGrid({required this.anchor, required this.items});
  final DateTime anchor;
  final List<CalendarItem> items;

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 96),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
      childAspectRatio: 1.4,
    ),
    itemCount: 12,
    itemBuilder: (context, index) {
      final month = index + 1;
      final count = items
          .where((item) => item.startAt.toLocal().month == month)
          .length;
      return Card(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat.MMMM().format(DateTime(anchor.year, month))),
              Text(AppLocalizations.of(context).itemCount(count)),
            ],
          ),
        ),
      );
    },
  );
}
