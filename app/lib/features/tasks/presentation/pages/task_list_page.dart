import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';
import '../controllers/task_list_controller.dart';

enum TaskViewMode { list, board, timeline, calendar }

final taskViewModeProvider = StateProvider<TaskViewMode>(
  (ref) => TaskViewMode.list,
);

class TaskListPage extends ConsumerWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final tasks = ref.watch(taskListControllerProvider);
    final view = ref.watch(taskViewModeProvider);
    ref.listen(taskListControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    return Scaffold(
      appBar: AppTopBar(title: Text(localization.tasksTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => const TaskCreateRoute().push<void>(context),
        icon: const Icon(Icons.add),
        label: Text(localization.createTask),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: SegmentedButton<TaskViewMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: TaskViewMode.list,
                    label: Text(localization.listView),
                  ),
                  ButtonSegment(
                    value: TaskViewMode.board,
                    label: Text(localization.boardView),
                  ),
                  ButtonSegment(
                    value: TaskViewMode.timeline,
                    label: Text(localization.timelineView),
                  ),
                  ButtonSegment(
                    value: TaskViewMode.calendar,
                    label: Text(localization.calendarTitle),
                  ),
                ],
                selected: {view},
                onSelectionChanged: (value) =>
                    ref.read(taskViewModeProvider.notifier).state = value.first,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: ref
                    .read(taskListControllerProvider.notifier)
                    .refresh,
                child: tasks.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                  error: (error, stackTrace) => _ErrorState(
                    message: error.toString(),
                    onRetry: ref
                        .read(taskListControllerProvider.notifier)
                        .refresh,
                  ),
                  data: (items) => items.isEmpty
                      ? _EmptyState(
                          onCreate: () => _showCreateDialog(context, ref),
                        )
                      : _TaskCollection(items: items, view: view),
                ),
              ),
            ),
          ],
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

class _TaskCollection extends ConsumerWidget {
  const _TaskCollection({required this.items, required this.view});
  final List<TaskEntity> items;
  final TaskViewMode view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordered = [...items];
    if (view == TaskViewMode.timeline || view == TaskViewMode.calendar) {
      ordered.sort(
        (left, right) => switch ((left.dueAt, right.dueAt)) {
          (null, null) => left.id.compareTo(right.id),
          (null, _) => 1,
          (_, null) => -1,
          (final leftDate?, final rightDate?) => leftDate.compareTo(rightDate),
        },
      );
    } else if (view == TaskViewMode.board) {
      ordered.sort(
        (left, right) => left.status.index.compareTo(right.status.index),
      );
    }
    return ListView.separated(
      key: PageStorageKey(view),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        96,
      ),
      itemCount: ordered.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final task = ordered[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (view == TaskViewMode.board &&
                (index == 0 || ordered[index - 1].status != task.status))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).taskStatusLabel(task.status.name),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            if ((view == TaskViewMode.timeline ||
                    view == TaskViewMode.calendar) &&
                task.dueAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatFullDate(task.dueAt!.toLocal()),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            _TaskCard(
              task: task,
              onComplete: () => ref
                  .read(taskListControllerProvider.notifier)
                  .complete(task.id),
              onArchive: () => ref
                  .read(taskListControllerProvider.notifier)
                  .archive(task.id),
              onDelete: () =>
                  ref.read(taskListControllerProvider.notifier).delete(task.id),
            ),
          ],
        );
      },
    );
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
        subtitle: Text(localization.taskStatusLabel(task.status.name)),
        onTap: () => TaskDetailRoute(task.id).push<void>(context),
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
