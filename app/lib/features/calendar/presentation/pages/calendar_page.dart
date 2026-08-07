import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/calendar_models.dart';
import '../controllers/calendar_controller.dart';

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final calendar = ref.watch(calendarControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(localization.calendarTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createEvent(context, ref),
        icon: const Icon(Icons.event_available_outlined),
        label: Text(localization.addEvent),
      ),
      body: SafeArea(
        child: calendar.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
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
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        _periodLabel(state.anchor, state.view),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: localization.nextPeriod,
                      onPressed: () =>
                          ref.read(calendarControllerProvider.notifier).move(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              Expanded(child: _CalendarContent(state: state)),
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

  static String _periodLabel(DateTime date, CalendarViewMode view) =>
      switch (view) {
        CalendarViewMode.day ||
        CalendarViewMode.timeline => DateFormat.yMMMMd().format(date),
        CalendarViewMode.week ||
        CalendarViewMode.agenda => 'Week of ${DateFormat.yMMMd().format(date)}',
        CalendarViewMode.month ||
        CalendarViewMode.heatMap => DateFormat.yMMMM().format(date),
        CalendarViewMode.year => DateFormat.y().format(date),
      };
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({required this.state});
  final CalendarState state;

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
            label: 'Day ${index + 1}, $count items',
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
      return Center(child: Text(AppLocalizations.of(context).noCalendarItems));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 96),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final item = state.items[index];
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
}
