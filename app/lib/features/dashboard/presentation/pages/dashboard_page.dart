import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/semantic_colors.dart';
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
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  key: const Key('dashboard-scroll-view'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    112,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _DashboardHero(snapshot: state.snapshot),
                            const SizedBox(height: AppSpacing.md),
                            _DashboardGrid(
                              preferences: visible
                                  .where((item) => item.visible)
                                  .toList(growable: false),
                              snapshot: state.snapshot,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
  ) => switch (kind) {
    DashboardWidgetKind.today => '${snapshot.today}',
    DashboardWidgetKind.tomorrow => '${snapshot.tomorrow}',
    DashboardWidgetKind.pending => '${snapshot.pending}',
    DashboardWidgetKind.overdue => '${snapshot.overdue}',
    DashboardWidgetKind.completedToday => '${snapshot.completedToday}',
    DashboardWidgetKind.upcoming => '${snapshot.upcoming}',
    DashboardWidgetKind.favorites => '${snapshot.favorites}',
    DashboardWidgetKind.progress =>
      snapshot.completionRate == null
          ? AppLocalizations.of(context).notAvailable
          : AppLocalizations.of(
              context,
            ).percentageValue(snapshot.completionRate!.round()),
    DashboardWidgetKind.recentKnowledge => '${snapshot.recentKnowledge}',
    DashboardWidgetKind.dateTime => DateFormat.yMMMMEEEEd().add_jm().format(
      DateTime.now(),
    ),
    DashboardWidgetKind.quickActions => AppLocalizations.of(
      context,
    ).availableActions,
    DashboardWidgetKind.miniCalendar => DateFormat.yMMMM().format(
      DateTime.now(),
    ),
    DashboardWidgetKind.recentProjects => '${snapshot.recentProjects}',
    DashboardWidgetKind.recentActivity => '${snapshot.recentActivity}',
    DashboardWidgetKind.productivity =>
      snapshot.productivityScore == null
          ? AppLocalizations.of(context).notAvailable
          : '${snapshot.productivityScore}',
  };

  static String _label(BuildContext context, DashboardWidgetKind kind) =>
      AppLocalizations.of(context).dashboardWidgetLabel(kind.name);

  static String _sizeLabel(BuildContext context, DashboardWidgetSize size) =>
      AppLocalizations.of(context).dashboardSizeLabel(size.name);
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localization = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [scheme.primaryContainer, scheme.secondaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: .7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.space_dashboard_rounded,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.dashboardTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMMEEEEd().format(DateTime.now()),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimaryContainer.withValues(
                            alpha: .78,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _HeroMetric(
                  label: DashboardPage._label(
                    context,
                    DashboardWidgetKind.pending,
                  ),
                  value: snapshot.pending,
                ),
                _HeroMetric(
                  label: DashboardPage._label(
                    context,
                    DashboardWidgetKind.overdue,
                  ),
                  value: snapshot.overdue,
                ),
                _HeroMetric(
                  label: DashboardPage._label(
                    context,
                    DashboardWidgetKind.completedToday,
                  ),
                  value: snapshot.completedToday,
                ),
                _HeroMetric(
                  label: DashboardPage._label(
                    context,
                    DashboardWidgetKind.upcoming,
                  ),
                  value: snapshot.upcoming,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 112, minHeight: 64),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: scheme.onSurface),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid({required this.preferences, required this.snapshot});

  final List<DashboardWidgetPreference> preferences;
  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 840
          ? 3
          : constraints.maxWidth >= 520
          ? 2
          : 1;
      const gap = AppSpacing.sm;
      final unit = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: preferences
            .map((preference) {
              final forceWide =
                  preference.kind == DashboardWidgetKind.quickActions ||
                  preference.kind == DashboardWidgetKind.miniCalendar ||
                  preference.kind == DashboardWidgetKind.progress;
              final spansAll =
                  forceWide || preference.size == DashboardWidgetSize.expanded;
              return SizedBox(
                width: spansAll ? constraints.maxWidth : unit,
                child: _DashboardCard(
                  preference: preference,
                  snapshot: snapshot,
                ),
              );
            })
            .toList(growable: false),
      );
    },
  );
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.preference, required this.snapshot});

  final DashboardWidgetPreference preference;
  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final label = DashboardPage._label(context, preference.kind);
    final value = DashboardPage._value(context, snapshot, preference.kind);
    final accent = _accent(context);
    final onTap = _onTap(context);
    return Semantics(
      button: onTap != null,
      label: '$label: $value',
      child: Card(
        key: Key('dashboard-card-${preference.kind.name}'),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: switch (preference.size) {
                DashboardWidgetSize.compact => 112,
                DashboardWidgetSize.regular => 136,
                DashboardWidgetSize.expanded => 168,
              },
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(_icon(), color: accent, size: 22),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (onTap != null)
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (preference.kind == DashboardWidgetKind.quickActions)
                    const _QuickActions()
                  else if (preference.kind == DashboardWidgetKind.miniCalendar)
                    const _MiniCalendar()
                  else ...[
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (preference.kind == DashboardWidgetKind.progress &&
                        snapshot.completionRate != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: snapshot.completionRate!.clamp(0, 100) / 100,
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 8,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _accent(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    return switch (preference.kind) {
      DashboardWidgetKind.overdue => scheme.error,
      DashboardWidgetKind.pending => semantic.warning,
      DashboardWidgetKind.completedToday => semantic.success,
      DashboardWidgetKind.upcoming => semantic.info,
      DashboardWidgetKind.tomorrow => scheme.secondary,
      _ => scheme.primary,
    };
  }

  IconData _icon() => switch (preference.kind) {
    DashboardWidgetKind.today => Icons.today_rounded,
    DashboardWidgetKind.tomorrow => Icons.event_rounded,
    DashboardWidgetKind.pending => Icons.pending_actions_rounded,
    DashboardWidgetKind.overdue => Icons.notification_important_rounded,
    DashboardWidgetKind.completedToday => Icons.task_alt_rounded,
    DashboardWidgetKind.upcoming => Icons.notifications_active_rounded,
    DashboardWidgetKind.favorites => Icons.star_rounded,
    DashboardWidgetKind.progress => Icons.donut_large_rounded,
    DashboardWidgetKind.recentKnowledge => Icons.auto_stories_rounded,
    DashboardWidgetKind.dateTime => Icons.schedule_rounded,
    DashboardWidgetKind.quickActions => Icons.bolt_rounded,
    DashboardWidgetKind.miniCalendar => Icons.calendar_month_rounded,
    DashboardWidgetKind.recentProjects => Icons.folder_copy_rounded,
    DashboardWidgetKind.recentActivity => Icons.history_rounded,
    DashboardWidgetKind.productivity => Icons.insights_rounded,
  };

  VoidCallback? _onTap(BuildContext context) => switch (preference.kind) {
    DashboardWidgetKind.today ||
    DashboardWidgetKind.tomorrow ||
    DashboardWidgetKind.pending ||
    DashboardWidgetKind.overdue ||
    DashboardWidgetKind.completedToday ||
    DashboardWidgetKind.favorites => () => const TasksRoute().go(context),
    DashboardWidgetKind.upcoming => () => const RemindersRoute().push<void>(
      context,
    ),
    DashboardWidgetKind.recentKnowledge => () => const KnowledgeRoute().go(
      context,
    ),
    DashboardWidgetKind.recentProjects =>
      () => const ProjectsRoute().push<void>(context),
    DashboardWidgetKind.productivity || DashboardWidgetKind.progress =>
      () => const StatisticsRoute().push<void>(context),
    _ => null,
  };
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton.tonalIcon(
          onPressed: () => const TaskCreateRoute().push<void>(context),
          icon: const Icon(Icons.add_task_rounded),
          label: Text(localization.quickAdd),
        ),
        FilledButton.tonalIcon(
          onPressed: () => const CalendarRoute().go(context),
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(localization.calendarTitle),
        ),
        FilledButton.tonalIcon(
          onPressed: () => const SearchRoute().push<void>(context),
          icon: const Icon(Icons.search_rounded),
          label: Text(localization.searchTitle),
        ),
        FilledButton.tonalIcon(
          onPressed: () => const KnowledgeRoute().go(context),
          icon: const Icon(Icons.auto_stories_outlined),
          label: Text(localization.knowledgeTitle),
        ),
      ],
    );
  }
}

class _MiniCalendar extends StatelessWidget {
  const _MiniCalendar();

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
