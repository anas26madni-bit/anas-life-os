import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../controllers/project_controller.dart';
import '../controllers/task_list_controller.dart';
import 'project_list_page.dart';

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final project = ref.watch(projectDetailProvider(projectId));
    final tasks = ref.watch(taskListControllerProvider).value ?? const [];
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.projectDetails)),
      body: SafeArea(
        child: project.when(
          loading: LoadingStateView.new,
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
          ),
          data: (item) {
            if (item == null) {
              return ActionStateView(
                icon: Icons.work_off_outlined,
                title: localization.projectNotFound,
                message: localization.projectNotFoundMessage,
              );
            }
            final projectTasks = tasks
                .where((task) => task.projectId == projectId)
                .toList(growable: false);
            final completed = projectTasks
                .where((task) => task.progress == 100)
                .length;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (item.description != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(item.description!),
                ],
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(
                  value: projectTasks.isEmpty
                      ? 0
                      : completed / projectTasks.length,
                  semanticsLabel: localization.completionProgress,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  localization.completedCount(completed, projectTasks.length),
                ),
                if (item.dueAt != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: Text(localization.dueDate),
                    subtitle: Text(
                      DateFormat.yMMMd().format(item.dueAt!.toLocal()),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(
                  localization.projectTasks,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (projectTasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(localization.noProjectTasks),
                  )
                else
                  for (final task in projectTasks)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.task_alt_outlined),
                        title: Text(task.title),
                        subtitle: Text(
                          localization.taskStatusLabel(task.status.name),
                        ),
                      ),
                    ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          showProjectEditor(context, ref, initial: item),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(localization.edit),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ref
                          .read(projectListControllerProvider.notifier)
                          .archive(projectId),
                      icon: const Icon(Icons.archive_outlined),
                      label: Text(localization.archive),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(projectListControllerProvider.notifier)
                            .delete(projectId);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(localization.delete),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
