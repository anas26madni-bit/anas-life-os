import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../domain/entities/task_draft.dart';
import '../../domain/entities/task_enums.dart';
import '../controllers/task_list_controller.dart';

class TaskCreatePage extends ConsumerStatefulWidget {
  const TaskCreatePage({super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  var _title = '';
  var _description = '';
  var _projectId = '';
  var _priority = TaskPriority.none;
  var _mandatory = false;
  DateTime? _start;
  DateTime? _due;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.createTask)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              TextFormField(
                autofocus: true,
                maxLength: 300,
                decoration: InputDecoration(labelText: localization.taskTitle),
                validator: (value) => value == null || value.trim().isEmpty
                    ? localization.taskTitleRequired
                    : null,
                onChanged: (value) => _title = value,
              ),
              TextFormField(
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(labelText: localization.description),
                onChanged: (value) => _description = value,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: localization.projectId),
                onChanged: (value) => _projectId = value,
              ),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                decoration: InputDecoration(labelText: localization.priority),
                items: TaskPriority.values
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(localization.taskPriorityLabel(value.name)),
                        ))
                    .toList(growable: false),
                onChanged: (value) => setState(() => _priority = value!),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localization.mandatory),
                value: _mandatory,
                onChanged: (value) => setState(() => _mandatory = value),
              ),
              _DateTile(
                label: localization.startDate,
                value: _start,
                onChanged: (value) => setState(() => _start = value),
              ),
              _DateTile(
                label: localization.dueDate,
                value: _due,
                onChanged: (value) => setState(() => _due = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(localization.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(taskListControllerProvider.notifier).create(
      TaskDraft(
        title: _title,
        description: _description.trim().isEmpty ? null : _description.trim(),
        projectId: int.tryParse(_projectId),
        priority: _priority,
        isMandatory: _mandatory,
        startAt: _start,
        dueAt: _due,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.value, required this.onChanged});
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: value == null ? null : Text(DateFormat.yMMMd().format(value!)),
    trailing: const Icon(Icons.event_outlined),
    onTap: () async {
      final selected = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: value ?? DateTime.now(),
      );
      if (selected != null) onChanged(selected);
    },
  );
}
