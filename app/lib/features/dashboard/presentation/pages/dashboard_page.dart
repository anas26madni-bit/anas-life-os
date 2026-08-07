import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dashboard_models.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final dashboard = ref.watch(dashboardControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.dashboardTitle),
        actions: [
          IconButton(
            tooltip: localization.customizeDashboard,
            onPressed: dashboard.hasValue
                ? () => _customize(context, ref, dashboard.requireValue)
                : null,
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: localization.calendarTitle,
            onPressed: () => const CalendarRoute().go(context),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => const TasksRoute().go(context),
        icon: const Icon(Icons.add_task),
        label: Text(localization.quickAdd),
      ),
      body: SafeArea(
        child: dashboard.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, stackTrace) => Center(child: Text(error.toString())),
          data: (state) {
            final visible = [...state.preferences]
              ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
            return RefreshIndicator(
              onRefresh: ref.read(dashboardControllerProvider.notifier).refresh,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 420,
                            mainAxisExtent: 128,
                            crossAxisSpacing: AppSpacing.sm,
                            mainAxisSpacing: AppSpacing.sm,
                          ),
                      delegate: SliverChildListDelegate.fixed([
                        for (final preference
                            in visible.where((item) => item.visible))
                          _DashboardCard(
                            preference: preference,
                            value: _value(state.snapshot, preference.kind),
                          ),
                      ]),
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
                onPressed: () => ref
                    .read(dashboardControllerProvider.notifier)
                    .reset(),
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
                    title: Text(_label(item.kind)),
                    subtitle: DropdownButton<DashboardWidgetSize>(
                      value: item.size,
                      items: DashboardWidgetSize.values
                          .map(
                            (size) => DropdownMenuItem(
                              value: size,
                              child: Text(size.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (size) => size == null
                          ? null
                          : ref
                                .read(dashboardControllerProvider.notifier)
                                .resize(item.kind, size),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: AppLocalizations.of(context).moveUp,
                          onPressed: index == 0
                              ? null
                              : () => ref
                                    .read(
                                      dashboardControllerProvider.notifier,
                                    )
                                    .move(item.kind, -1),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(context).moveDown,
                          onPressed: index == state.preferences.length - 1
                              ? null
                              : () => ref
                                    .read(
                                      dashboardControllerProvider.notifier,
                                    )
                                    .move(item.kind, 1),
                          icon: const Icon(Icons.arrow_downward),
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
    DashboardSnapshot snapshot,
    DashboardWidgetKind kind,
  ) => switch (kind) {
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
  };

  static String _label(DashboardWidgetKind kind) => switch (kind) {
    DashboardWidgetKind.today => 'Today',
    DashboardWidgetKind.tomorrow => 'Tomorrow',
    DashboardWidgetKind.pending => 'Pending',
    DashboardWidgetKind.overdue => 'Overdue',
    DashboardWidgetKind.completedToday => 'Completed today',
    DashboardWidgetKind.upcoming => 'Next seven days',
    DashboardWidgetKind.favorites => 'Pinned and favorites',
    DashboardWidgetKind.progress => 'Completion progress',
    DashboardWidgetKind.recentKnowledge => 'Knowledge notes',
  };
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.preference, required this.value});
  final DashboardWidgetPreference preference;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${DashboardPage._label(preference.kind)}: $value',
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DashboardPage._label(preference.kind),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    ),
  );
}
