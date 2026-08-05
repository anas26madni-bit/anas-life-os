import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../controllers/task_list_controller.dart';

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final tasks = ref.watch(taskListControllerProvider);
    ref.listen(taskListControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(localization.tasksTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(localization.createTask),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ref.read(taskListControllerProvider.notifier).refresh,
          child: tasks.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, stackTrace) => _ErrorState(
              message: error.toString(),
              onRetry: ref.read(taskListControllerProvider.notifier).refresh,
            ),
            data: (items) => items.isEmpty
                ? _EmptyState(onCreate: () => _showCreateDialog(context, ref))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      96,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) => _TaskCard(
                      task: items[index],
                      onComplete: () => ref
                          .read(taskListControllerProvider.notifier)
                          .complete(items[index].id),
                      onArchive: () => ref
                          .read(taskListControllerProvider.notifier)
                          .archive(items[index].id),
                      onDelete: () => ref
                          .read(taskListControllerProvider.notifier)
                          .delete(items[index].id),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final localization = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    var taskTitle = '';
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.createTask),
        content: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            maxLength: 300,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(labelText: localization.taskTitle),
            onChanged: (value) => taskTitle = value,
            validator: (value) => value == null || value.trim().isEmpty
                ? localization.taskTitleRequired
                : null,
            onFieldSubmitted: (_) {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(taskTitle.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(taskTitle.trim());
              }
            },
            child: Text(localization.save),
          ),
        ],
      ),
    );
    if (title != null && context.mounted) {
      await ref
          .read(taskListControllerProvider.notifier)
          .create(TaskDraft(title: title));
    }
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onComplete,
    required this.onArchive,
    required this.onDelete,
  });

  final TaskEntity task;
  final VoidCallback onComplete;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final completed = task.status == TaskStatus.completed;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minVerticalPadding: AppSpacing.sm,
        leading: IconButton(
          tooltip: localization.completeTask,
          onPressed: completed ? null : onComplete,
          icon: Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
          ),
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: completed
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Text(task.status.name),
        trailing: PopupMenuButton<_TaskAction>(
          tooltip: localization.taskActions,
          onSelected: (action) => switch (action) {
            _TaskAction.archive => onArchive(),
            _TaskAction.delete => onDelete(),
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _TaskAction.archive,
              child: Text(localization.archive),
            ),
            PopupMenuItem(
              value: _TaskAction.delete,
              child: Text(localization.delete),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TaskAction { archive, delete }

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: 96),
        Icon(
          Icons.task_alt,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          localization.noTasksTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          localization.noTasksMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: Text(localization.createTask),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: 96),
        Icon(
          Icons.error_outline,
          size: 72,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          localization.tasksErrorTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(localization.retry),
          ),
        ),
      ],
    );
  }
}
