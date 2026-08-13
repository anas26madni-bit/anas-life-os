import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../reminders/domain/entities/reminder_draft.dart';
import '../../../reminders/domain/entities/reminder_entity.dart';
import '../../../reminders/presentation/controllers/reminder_list_controller.dart';
import '../controllers/task_list_controller.dart';
import '../widgets/task_form_fields.dart';

class TaskCreatePage extends ConsumerStatefulWidget {
  const TaskCreatePage({super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _task = TaskFormData();
  var _reminderEnabled = false;
  var _reminderAt = DateTime.now().add(const Duration(hours: 1));
  var _repeatRuleId = '';
  var _saving = false;
  String? _saveError;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.createTask)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            key: const Key('task-create-scroll-view'),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              TaskFormFields(
                data: _task,
                allowParentSelection: true,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              Semantics(
                header: true,
                child: Text(
                  localization.reminderSectionTitle,
                  key: const Key('task-reminder-section'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SwitchListTile(
                key: const Key('task-reminder-enabled'),
                contentPadding: EdgeInsets.zero,
                title: Text(localization.reminderEnabled),
                value: _reminderEnabled,
                onChanged: (value) => setState(() => _reminderEnabled = value),
              ),
              if (_reminderEnabled) ...[
                ListTile(
                  key: const Key('task-reminder-date'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(localization.reminderDate),
                  subtitle: Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatFullDate(_reminderAt),
                  ),
                  onTap: _selectReminderDate,
                ),
                ListTile(
                  key: const Key('task-reminder-time'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(localization.reminderTime),
                  subtitle: Text(
                    MaterialLocalizations.of(context).formatTimeOfDay(
                      TimeOfDay.fromDateTime(_reminderAt),
                    ),
                  ),
                  onTap: _selectReminderTime,
                ),
                TextFormField(
                  key: const Key('task-reminder-repeat-rule'),
                  initialValue: _repeatRuleId,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: localization.repeatRuleId,
                  ),
                  onChanged: (value) => _repeatRuleId = value,
                ),
              ],
              if (_saveError != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _saveError!,
                  key: const Key('task-create-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: FilledButton.icon(
            key: const Key('task-create-save'),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(localization.save),
          ),
        ),
      ),
    );
  }

  Future<void> _selectReminderDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 3650)),
      initialDate: _reminderAt,
    );
    if (selected == null) return;
    setState(() {
      _reminderAt = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _reminderAt.hour,
        _reminderAt.minute,
      );
    });
  }

  Future<void> _selectReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt),
    );
    if (selected == null) return;
    setState(() {
      _reminderAt = DateTime(
        _reminderAt.year,
        _reminderAt.month,
        _reminderAt.day,
        selected.hour,
        selected.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final task = await ref
          .read(taskListControllerProvider.notifier)
          .create(_task.toDraft());
      if (_reminderEnabled) {
        final useCases = await ref.read(reminderUseCasesProvider.future);
        final result = await useCases.create(
          ReminderDraft(
            taskId: task.id,
            title: task.title,
            message: task.description,
            scheduledAt: _reminderAt.toUtc(),
            timezoneId: DateTime.now().timeZoneName,
            repeatRuleId: int.tryParse(_repeatRuleId),
          ),
        );
        if (result case FailureResult<ReminderEntity>(:final failure)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  ).taskSavedReminderFailed(failure.safeMessage),
                ),
              ),
            );
            Navigator.of(context).pop(task.id);
          }
          return;
        }
        ref.invalidate(reminderListControllerProvider);
      }
      if (mounted) Navigator.of(context).pop(task.id);
    } on Object catch (error) {
      if (mounted) setState(() => _saveError = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
