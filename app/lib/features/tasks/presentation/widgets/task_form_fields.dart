import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_enums.dart';

final class TaskFormData {
  TaskFormData({
    this.title = '',
    this.description = '',
    this.projectId = '',
    this.parentTaskId = '',
    this.priority = TaskPriority.none,
    this.status = TaskStatus.pending,
    this.mandatory = false,
    this.progress = 0,
    this.startAt,
    this.dueAt,
    this.categoryId,
    this.subcategoryId,
    this.sortOrder = 0,
  });

  factory TaskFormData.fromTask(TaskEntity task) => TaskFormData(
    title: task.title,
    description: task.description ?? '',
    projectId: task.projectId?.toString() ?? '',
    parentTaskId: task.parentTaskId?.toString() ?? '',
    priority: task.priority,
    status: task.status,
    mandatory: task.isMandatory,
    progress: task.progress.toDouble(),
    startAt: task.startAt,
    dueAt: task.dueAt,
    categoryId: task.categoryId,
    subcategoryId: task.subcategoryId,
    sortOrder: task.sortOrder,
  );

  String title;
  String description;
  String projectId;
  String parentTaskId;
  TaskPriority priority;
  TaskStatus status;
  bool mandatory;
  double progress;
  DateTime? startAt;
  DateTime? dueAt;
  final int? categoryId;
  final int? subcategoryId;
  final int sortOrder;

  TaskDraft toDraft() => TaskDraft(
    title: title,
    description: description.trim().isEmpty ? null : description.trim(),
    projectId: _positiveId(projectId),
    parentTaskId: _positiveId(parentTaskId),
    categoryId: categoryId,
    subcategoryId: subcategoryId,
    sortOrder: sortOrder,
    priority: priority,
    status: status,
    isMandatory: mandatory,
    progress: progress.round(),
    startAt: startAt,
    dueAt: dueAt,
  );

  static int? _positiveId(String value) {
    final parsed = int.tryParse(value);
    return parsed != null && parsed > 0 ? parsed : null;
  }
}

class TaskFormFields extends StatelessWidget {
  const TaskFormFields({
    required this.data,
    required this.onChanged,
    this.allowParentSelection = false,
    super.key,
  });

  final TaskFormData data;
  final VoidCallback onChanged;
  final bool allowParentSelection;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('task-title-field'),
          initialValue: data.title,
          autofocus: true,
          maxLength: 300,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: localization.taskTitle),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return localization.taskTitleRequired;
            }
            return value.runes.length > 300
                ? localization.taskTitleTooLong
                : null;
          },
          onChanged: (value) => data.title = value,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          key: const Key('task-description-field'),
          initialValue: data.description,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(labelText: localization.description),
          onChanged: (value) => data.description = value,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          key: const Key('task-project-field'),
          initialValue: data.projectId,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: localization.projectId),
          onChanged: (value) => data.projectId = value,
        ),
        if (allowParentSelection) ...[
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const Key('task-parent-field'),
            initialValue: data.parentTaskId,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: localization.parentTaskId,
              helperText: localization.parentTaskHelper,
            ),
            onChanged: (value) => data.parentTaskId = value,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<TaskPriority>(
          key: const Key('task-priority-field'),
          initialValue: data.priority,
          decoration: InputDecoration(labelText: localization.priority),
          items: TaskPriority.values
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(localization.taskPriorityLabel(value.name)),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value == null) return;
            data.priority = value;
            onChanged();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<TaskStatus>(
          key: const Key('task-status-field'),
          initialValue: data.status,
          decoration: InputDecoration(labelText: localization.status),
          items: TaskStatus.values
              .where((value) => value != TaskStatus.deleted)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(localization.taskStatusLabel(value.name)),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value == null) return;
            data.status = value;
            if (value == TaskStatus.completed) data.progress = 100;
            onChanged();
          },
        ),
        FormField<bool>(
          initialValue: data.mandatory,
          validator: (_) =>
              data.mandatory &&
                  TaskFormData._positiveId(data.parentTaskId) == null
              ? localization.mandatoryTaskRequiresParent
              : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                key: const Key('task-mandatory-field'),
                contentPadding: EdgeInsets.zero,
                title: Text(localization.mandatory),
                value: data.mandatory,
                onChanged: (value) {
                  data.mandatory = value;
                  field.didChange(value);
                  onChanged();
                },
              ),
              if (field.errorText != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.md,
                  ),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Text(localization.progressPercent(data.progress.round())),
        Slider(
          key: const Key('task-progress-field'),
          value: data.progress,
          max: 100,
          divisions: 20,
          label: '${data.progress.round()}%',
          onChanged: data.status == TaskStatus.completed
              ? null
              : (value) {
                  data.progress = value;
                  onChanged();
                },
        ),
        _DateField(
          key: const Key('task-start-date-field'),
          label: localization.startDate,
          value: data.startAt,
          onChanged: (value) {
            data.startAt = value;
            onChanged();
          },
        ),
        FormField<DateTime?>(
          key: const Key('task-due-date-field'),
          validator: (_) =>
              data.startAt != null &&
                  data.dueAt != null &&
                  data.dueAt!.isBefore(data.startAt!)
              ? localization.invalidTaskDates
              : null,
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DateField(
                key: const Key('task-due-date-tile'),
                label: localization.dueDate,
                value: data.dueAt,
                onChanged: (value) {
                  data.dueAt = value;
                  field.didChange(value);
                  onChanged();
                },
              ),
              if (field.errorText != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.md,
                  ),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: value == null
        ? null
        : Text(DateFormat.yMMMd().format(value!.toLocal())),
    trailing: Wrap(
      spacing: AppSpacing.xs,
      children: [
        if (value != null)
          IconButton(
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            onPressed: () => onChanged(null),
            icon: const Icon(Icons.clear),
          ),
        const Icon(Icons.event_outlined),
      ],
    ),
    onTap: () async {
      final selected = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: value?.toLocal() ?? DateTime.now(),
      );
      if (selected != null) onChanged(selected);
    },
  );
}
