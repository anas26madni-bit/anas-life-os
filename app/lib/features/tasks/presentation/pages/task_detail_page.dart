import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../../../reminders/domain/entities/reminder_entity.dart';
import '../../../reminders/presentation/controllers/reminder_list_controller.dart';
import '../../domain/entities/task_entity.dart';
import '../controllers/task_detail_controller.dart';
import '../widgets/task_form_fields.dart';
import '../widgets/task_reminder_fields.dart';

class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({required this.taskId, super.key});

  final int taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final task = ref.watch(taskDetailProvider(taskId));
    return Scaffold(
      appBar: AppTopBar(
        title: Text(localization.taskDetails),
        actions: [
          IconButton(
            tooltip: localization.duplicate,
            onPressed: () =>
                ref.read(taskDetailActionsProvider).duplicate(taskId),
            icon: const Icon(Icons.copy_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: task.when(
          loading: LoadingStateView.new,
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
          ),
          data: (item) => item == null
              ? ActionStateView(
                  icon: Icons.task_alt_outlined,
                  title: localization.taskNotFound,
                  message: localization.taskNotFoundMessage,
                )
              : _TaskDetails(task: item),
        ),
      ),
      floatingActionButton: task.value == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _editTask(context, ref, task.requireValue!),
              icon: const Icon(Icons.edit_outlined),
              label: Text(localization.edit),
            ),
    );
  }
}

class _TaskDetails extends ConsumerWidget {
  const _TaskDetails({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        96,
      ),
      children: [
        Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
        if (task.description?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(task.description!),
        ],
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            Chip(label: Text(localization.taskStatusLabel(task.status.name))),
            Chip(
              label: Text(localization.taskPriorityLabel(task.priority.name)),
            ),
            if (task.isMandatory)
              Chip(
                avatar: const Icon(Icons.priority_high, size: 18),
                label: Text(localization.mandatory),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LinearProgressIndicator(
          value: task.progress / 100,
          semanticsLabel: localization.completionProgress,
          semanticsValue: '${task.progress}%',
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('${task.progress}%'),
        if (task.startAt != null || task.dueAt != null) ...[
          const SizedBox(height: AppSpacing.md),
          if (task.startAt != null)
            _InfoTile(
              icon: Icons.play_circle_outline,
              label: localization.startDate,
              value: DateFormat.yMMMd().add_jm().format(
                task.startAt!.toLocal(),
              ),
            ),
          if (task.dueAt != null)
            _InfoTile(
              icon: Icons.event_outlined,
              label: localization.dueDate,
              value: DateFormat.yMMMd().add_jm().format(task.dueAt!.toLocal()),
            ),
        ],
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () => _addTextValue(
                context,
                localization.addTag,
                (value) =>
                    ref.read(taskDetailActionsProvider).addTag(task.id, value),
              ),
              icon: const Icon(Icons.label_outline),
              label: Text(localization.addTag),
            ),
            OutlinedButton.icon(
              onPressed: () => _addTextValue(
                context,
                localization.addChecklist,
                (value) => ref
                    .read(taskDetailActionsProvider)
                    .addChecklist(task.id, value),
              ),
              icon: const Icon(Icons.checklist_outlined),
              label: Text(localization.addChecklist),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(value),
  );
}

Future<void> _addTextValue(
  BuildContext context,
  String title,
  Future<void> Function(String value) save,
) async {
  var value = '';
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        autofocus: true,
        onChanged: (text) => value = text,
        onSubmitted: (text) => Navigator.pop(context, text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, value.trim()),
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    ),
  );
  if (result != null && result.isNotEmpty) await save(result);
}

Future<void> _editTask(
  BuildContext context,
  WidgetRef ref,
  TaskEntity task,
) async {
  final localization = AppLocalizations.of(context);
  final key = GlobalKey<FormState>();
  final data = TaskFormData.fromTask(task);
  final reminderUseCases = await ref.read(reminderUseCasesProvider.future);
  final reminderResult = await reminderUseCases.list(limit: 200);
  final reminders = switch (reminderResult) {
    Success<List<ReminderEntity>>(:final value) => value,
    FailureResult<List<ReminderEntity>>() => const <ReminderEntity>[],
  };
  final existingReminder = reminders
      .where((reminder) => reminder.taskId == task.id)
      .firstOrNull;
  final reminderData = TaskReminderFormData.fromReminder(existingReminder);
  if (!context.mounted) return;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localization.editTask,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TaskFormFields(data: data, onChanged: () => setState(() {})),
                  const SizedBox(height: AppSpacing.lg),
                  TaskReminderFields(
                    data: reminderData,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    key: const Key('task-edit-save'),
                    onPressed: () => key.currentState!.validate()
                        ? Navigator.pop(context, true)
                        : null,
                    child: Text(localization.save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  if (saved == true) {
    await ref.read(taskDetailActionsProvider).update(task.id, data.toDraft());
    if (existingReminder == null && reminderData.enabled) {
      final result = await reminderUseCases.create(
        reminderData.toDraft(
          taskId: task.id,
          title: data.title.trim(),
          message: data.description.trim().isEmpty
              ? null
              : data.description.trim(),
        ),
      );
      if (result case FailureResult<ReminderEntity>(:final failure)) {
        throw StateError(failure.safeMessage);
      }
    } else if (existingReminder != null) {
      if (reminderData.enabled) {
        final result = await reminderUseCases.update(
          existingReminder.id,
          reminderData.toDraft(
            taskId: task.id,
            title: data.title.trim(),
            message: data.description.trim().isEmpty
                ? null
                : data.description.trim(),
          ),
        );
        if (result case FailureResult<ReminderEntity>(:final failure)) {
          throw StateError(failure.safeMessage);
        }
      } else if (existingReminder.enabled) {
        final result = await reminderUseCases.setEnabled(
          existingReminder.id,
          false,
        );
        if (result case FailureResult<ReminderEntity>(:final failure)) {
          throw StateError(failure.safeMessage);
        }
      }
    }
    ref.invalidate(reminderListControllerProvider);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
