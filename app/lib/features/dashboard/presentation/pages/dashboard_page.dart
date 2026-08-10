import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../../domain/entities/dashboard_models.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final dashboard = ref.watch(dashboardControllerProvider);
    return Scaffold(
      appBar: AppTopBar(
        title: Text(localization.dashboardTitle),
        actions: [
          IconButton(
            tooltip: localization.customizeDashboard,
            onPressed: dashboard.hasValue
                ? () => _customize(context, ref, dashboard.requireValue)
                : null,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => const TaskCreateRoute().push<void>(context),
        icon: const Icon(Icons.add_task),
        label: Text(localization.quickAdd),
      ),
      body: SafeArea(
        child: dashboard.when(
          loading: LoadingStateView.new,
          error: (error, stackTrace) => ErrorStateView(
            message: error.toString(),
            onRetry: ref.read(dashboardControllerProvider.notifier).refresh,
          ),
          data: (state) {
            final visible = [
              ...state.preferences,
            ]..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
            return RefreshIndicator(
              onRefresh: ref.read(dashboardControllerProvider.notifier).refresh,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverList.list(
                      children: [
                        for (final preference in visible.where(
                          (item) => item.visible,
                        )) ...[
                          _DashboardCard(
                            preference: preference,
                            snapshot: state.snapshot,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 96)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _customize(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: Column(
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context).customizeDashboard),
              trailing: TextButton(
                onPressed: () =>
                    ref.read(dashboardControllerProvider.notifier).reset(),
                child: Text(AppLocalizations.of(context).reset),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.preferences.length,
                itemBuilder: (context, index) {
                  final item = state.preferences[index];
                  return ListTile(
                    leading: Checkbox(
                      value: item.visible,
                      onChanged: (_) => ref
                          .read(dashboardControllerProvider.notifier)
                          .toggle(item.kind),
                    ),
                    title: Text(_label(context, item.kind)),
                    subtitle: DropdownButton<DashboardWidgetSize>(
                      value: item.size,
                      items: DashboardWidgetSize.values
                          .map(
                            (size) => DropdownMenuItem(
                              value: size,
                            child: Text(_sizeLabel(context, size)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (size) => size == null
                          ? null
                          : ref
                                .read(dashboardControllerProvider.notifier)
                                .resize(item.kind, size),
                    ),
                    trailing: PopupMenuButton<int>(
                      tooltip: AppLocalizations.of(context).availableActions,
                      onSelected: (delta) => ref
                          .read(dashboardControllerProvider.notifier)
                          .move(item.kind, delta),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: -1,
                          enabled: index > 0,
                          child: Text(AppLocalizations.of(context).moveUp),
                        ),
                        PopupMenuItem(
                          value: 1,
                          enabled: index < state.preferences.length - 1,
                          child: Text(AppLocalizations.of(context).moveDown),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );

  static String _value(
    BuildContext context,
    DashboardSnapshot snapshot,
    DashboardWidgetKind kind,
  ) =>
      switch (kind) {
        DashboardWidgetKind.today => '${snapshot.today}',
        DashboardWidgetKind.tomorrow => '${snapshot.tomorrow}',
        DashboardWidgetKind.pending => '${snapshot.pending}',
        DashboardWidgetKind.overdue => '${snapshot.overdue}',
        DashboardWidgetKind.completedToday => '${snapshot.completedToday}',
        DashboardWidgetKind.upcoming => '${snapshot.upcoming}',
        DashboardWidgetKind.favorites => '${snapshot.favorites}',
        DashboardWidgetKind.progress =>
          '${(snapshot.completionRate * 100).round()}%',
        DashboardWidgetKind.recentKnowledge => '${snapshot.recentKnowledge}',
        DashboardWidgetKind.dateTime => DateFormat.yMMMMEEEEd().add_jm().format(DateTime.now()),
        DashboardWidgetKind.quickActions => AppLocalizations.of(context).availableActions,
        DashboardWidgetKind.miniCalendar => DateFormat.yMMMM().format(DateTime.now()),
        DashboardWidgetKind.recentProjects => '${snapshot.recentProjects}',
        DashboardWidgetKind.recentActivity => '${snapshot.recentActivity}',
        DashboardWidgetKind.productivity => '${snapshot.productivityScore}%',
      };

  static String _label(BuildContext context, DashboardWidgetKind kind) =>
      AppLocalizations.of(context).dashboardWidgetLabel(kind.name);

  static String _sizeLabel(BuildContext context, DashboardWidgetSize size) =>
      AppLocalizations.of(context).dashboardSizeLabel(size.name);
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.preference, required this.snapshot});
  final DashboardWidgetPreference preference;
  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        '${DashboardPage._label(context, preference.kind)}: ${DashboardPage._value(context, snapshot, preference.kind)}',
    child: Card(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: switch (preference.size) {
            DashboardWidgetSize.compact => 96,
            DashboardWidgetSize.regular => 128,
            DashboardWidgetSize.expanded => 176,
          },
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DashboardPage._label(context, preference.kind)),
              const SizedBox(height: AppSpacing.xs),
              if (preference.kind == DashboardWidgetKind.quickActions)
                _QuickActions()
              else if (preference.kind == DashboardWidgetKind.miniCalendar)
                _MiniCalendar()
              else
                Text(
                  DashboardPage._value(context, snapshot, preference.kind),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ActionChip(
          avatar: const Icon(Icons.add_task, size: 18),
          label: Text(localization.tasksTitle),
          onPressed: () => const TasksRoute().go(context),
        ),
        ActionChip(
          avatar: const Icon(Icons.calendar_month_outlined, size: 18),
          label: Text(localization.calendarTitle),
          onPressed: () => const CalendarRoute().go(context),
        ),
        ActionChip(
          avatar: const Icon(Icons.search, size: 18),
          label: Text(localization.searchTitle),
          onPressed: () => const SearchRoute().push<void>(context),
        ),
      ],
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = DateUtils.getDaysInMonth(now.year, now.month);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat.yMMMM().format(now)),
        const SizedBox(height: AppSpacing.xs),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 32,
          ),
          itemCount: days,
          itemBuilder: (context, index) => Center(
            child: Text(
              '${index + 1}',
              style: index + 1 == now.day
                  ? TextStyle(color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
