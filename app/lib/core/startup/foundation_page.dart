import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../theme/app_spacing.dart';
import 'startup_controller.dart';

class FoundationPage extends ConsumerWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final startup = ref.watch(startupControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: startup.when(
                loading: () => _StatusContent(
                  icon: const CircularProgressIndicator.adaptive(),
                  title: localization.startingTitle,
                  message: localization.startingMessage,
                ),
                error: (error, stackTrace) => _FailureContent(
                  onRetry: () =>
                      ref.read(startupControllerProvider.notifier).retry(),
                ),
                data: (report) => report.isReady
                    ? const _ReadyContent()
                    : _FailureContent(
                        onRetry: () => ref
                            .read(startupControllerProvider.notifier)
                            .retry(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadyContent extends StatelessWidget {
  const _ReadyContent();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return _StatusContent(
      icon: Icon(
        Icons.shield_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.primary,
        semanticLabel: localization.foundationReadyTitle,
      ),
      title: localization.foundationReadyTitle,
      message: localization.foundationReadyMessage,
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: () => const DashboardRoute().go(context),
            icon: const Icon(Icons.dashboard_outlined),
            label: Text(localization.openDashboard),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            onPressed: () => const TasksRoute().go(context),
            icon: const Icon(Icons.task_alt),
            label: Text(localization.openTasks),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => const RemindersRoute().go(context),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(localization.openReminders),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => const KnowledgeRoute().go(context),
            icon: const Icon(Icons.auto_stories_outlined),
            label: Text(localization.openKnowledge),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => const CalendarRoute().go(context),
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(localization.openCalendar),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => const SearchRoute().go(context),
            icon: const Icon(Icons.manage_search),
            label: Text(localization.openSearch),
          ),
        ],
      ),
    );
  }
}

class _FailureContent extends StatelessWidget {
  const _FailureContent({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return _StatusContent(
      icon: Icon(
        Icons.error_outline,
        size: 64,
        color: Theme.of(context).colorScheme.error,
        semanticLabel: localization.foundationErrorTitle,
      ),
      title: localization.foundationErrorTitle,
      message: localization.foundationErrorMessage,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(localization.retry),
      ),
    );
  }
}

class _StatusContent extends StatelessWidget {
  const _StatusContent({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final Widget icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
