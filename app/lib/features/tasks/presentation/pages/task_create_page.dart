import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../reminders/domain/entities/reminder_entity.dart';
import '../../../reminders/presentation/controllers/reminder_list_controller.dart';
import '../controllers/task_list_controller.dart';
import '../widgets/task_form_fields.dart';
import '../widgets/task_reminder_fields.dart';

class TaskCreatePage extends ConsumerStatefulWidget {
  const TaskCreatePage({super.key});

  @override
  ConsumerState<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends ConsumerState<TaskCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _task = TaskFormData();
  final _reminder = TaskReminderFormData();
  var _saving = false;
  String? _saveError;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final parentCandidates = ref.watch(taskListControllerProvider).value ?? [];
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
                parentCandidates: parentCandidates,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.lg),
              TaskReminderFields(
                data: _reminder,
                onChanged: () => setState(() {}),
              ),
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
      if (_reminder.enabled) {
        final useCases = await ref.read(reminderUseCasesProvider.future);
        final result = await useCases.create(
          _reminder.toDraft(
            taskId: task.id,
            title: task.title,
            message: task.description,
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
