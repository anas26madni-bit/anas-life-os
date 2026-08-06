import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/reminder_draft.dart';
import '../../domain/entities/reminder_entity.dart';
import '../controllers/reminder_list_controller.dart';

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final reminders = ref.watch(reminderListControllerProvider);
    ref.listen(reminderListControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text(localization.remindersTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_alert_outlined),
        label: Text(localization.createReminder),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ref.read(reminderListControllerProvider.notifier).refresh,
          child: reminders.when(
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
            error: (error, stackTrace) => _ReminderErrorState(
              message: error.toString(),
              onRetry: ref.read(reminderListControllerProvider.notifier).refresh,
            ),
            data: (items) => items.isEmpty
                ? _ReminderEmptyState(
                    onCreate: () => _showCreateDialog(context, ref),
                  )
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
                    itemBuilder: (context, index) => _ReminderCard(
                      reminder: items[index],
                      onEnabledChanged: (enabled) => ref
                          .read(reminderListControllerProvider.notifier)
                          .setEnabled(items[index].id, enabled),
                      onDelete: () => ref
                          .read(reminderListControllerProvider.notifier)
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
    var taskId = 0;
    var title = '';
    var scheduledAt = DateTime.now().add(const Duration(hours: 1));
    var vibration = true;
    var voice = false;
    var flash = false;
    var fullScreen = false;
    var autoSnooze = false;
    final draft = await showDialog<ReminderDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(localization.createReminder),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: localization.reminderTaskId,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => taskId = int.tryParse(value) ?? 0,
                      validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1
                          ? localization.reminderTaskRequired
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      maxLength: 200,
                      decoration: InputDecoration(
                        labelText: localization.reminderTitle,
                      ),
                      onChanged: (value) => title = value,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? localization.reminderTitleRequired
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_outlined),
                      title: Text(localization.reminderDateTime),
                      subtitle: Text(MaterialLocalizations.of(context).formatFullDate(scheduledAt)),
                      trailing: Text(MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(scheduledAt))),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                          initialDate: scheduledAt,
                        );
                        if (date == null || !context.mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(scheduledAt),
                        );
                        if (time == null) return;
                        setState(() {
                          scheduledAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.reminderVibration),
                      value: vibration,
                      onChanged: (value) => setState(() => vibration = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.reminderVoice),
                      value: voice,
                      onChanged: (value) => setState(() => voice = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.reminderFlash),
                      value: flash,
                      onChanged: (value) => setState(() => flash = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.reminderFullScreen),
                      value: fullScreen,
                      onChanged: (value) => setState(() => fullScreen = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.reminderAutoSnooze),
                      value: autoSnooze,
                      onChanged: (value) => setState(() => autoSnooze = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localization.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(dialogContext).pop(
                  ReminderDraft(
                    taskId: taskId,
                    title: title,
                    scheduledAt: scheduledAt.toUtc(),
                    timezoneId: DateTime.now().timeZoneName,
                    vibration: vibration,
                    voiceEnabled: voice,
                    flash: flash,
                    fullScreen: fullScreen,
                    autoSnooze: autoSnooze,
                  ),
                );
              },
              child: Text(localization.save),
            ),
          ],
        ),
      ),
    );
    if (draft != null && context.mounted) {
      await ref.read(reminderListControllerProvider.notifier).create(draft);
    }
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.onEnabledChanged,
    required this.onDelete,
  });

  final ReminderEntity reminder;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.notifications_active_outlined),
        title: Text(reminder.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(MaterialLocalizations.of(context).formatFullDate(reminder.scheduledAt.toLocal())),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: reminder.enabled,
              onChanged: onEnabledChanged,
            ),
            IconButton(
              tooltip: localization.delete,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderEmptyState extends StatelessWidget {
  const _ReminderEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: 96),
        Icon(Icons.notifications_none, size: 72, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(localization.noRemindersTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(localization.noRemindersMessage, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_alert_outlined),
            label: Text(localization.createReminder),
          ),
        ),
      ],
    );
  }
}

class _ReminderErrorState extends StatelessWidget {
  const _ReminderErrorState({required this.message, required this.onRetry});

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
        Icon(Icons.error_outline, size: 72, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: AppSpacing.lg),
        Text(localization.remindersErrorTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
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
