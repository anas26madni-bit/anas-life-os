import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../domain/entities/reminder_draft.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/entities/reminder_enums.dart';
import '../controllers/reminder_list_controller.dart';

class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final reminders = ref.watch(reminderListControllerProvider);
    ref.listen(reminderListControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });
    return Scaffold(
      appBar: AppTopBar(
        title: Text(localization.remindersTitle),
        actions: [
          IconButton(
            tooltip: localization.missedReminders,
            onPressed: () => _showMissedReport(context, ref),
            icon: const Icon(Icons.history_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_alert_outlined),
        label: Text(localization.createReminder),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ref.read(reminderListControllerProvider.notifier).refresh,
          child: reminders.when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, stackTrace) => _ReminderErrorState(
              message: error.toString(),
              onRetry: ref
                  .read(reminderListControllerProvider.notifier)
                  .refresh,
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
                      onEdit: () => _showCreateDialog(
                        context,
                        ref,
                        initial: items[index],
                      ),
                      onSnooze: () => ref
                          .read(reminderListControllerProvider.notifier)
                          .recordSnooze(items[index]),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    WidgetRef ref, {
    ReminderEntity? initial,
  }) async {
    final localization = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    var taskId = initial?.taskId ?? 0;
    var title = initial?.title ?? '';
    var message = initial?.message ?? '';
    var scheduledAt =
        initial?.scheduledAt.toLocal() ??
        DateTime.now().add(const Duration(hours: 1));
    var vibration = initial?.vibration ?? true;
    var voice = initial?.voiceEnabled ?? false;
    var flash = initial?.flash ?? false;
    var fullScreen = initial?.fullScreen ?? false;
    var autoSnooze = initial?.autoSnooze ?? false;
    var snoozeMinutes = initial?.snoozeMinutes ?? 10;
    var maxSnoozes = initial?.maxSnoozes ?? 3;
    var escalationStep = initial?.escalationStep ?? 0;
    var repeatRuleId = initial?.repeatRuleId?.toString() ?? '';
    var priority = initial?.priority ?? ReminderPriority.normal;
    final draft = await showDialog<ReminderDraft>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            initial == null
                ? localization.createReminder
                : localization.editReminder,
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: taskId == 0 ? null : '$taskId',
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
                      initialValue: title,
                      maxLength: 200,
                      decoration: InputDecoration(
                        labelText: localization.reminderTitle,
                      ),
                      onChanged: (value) => title = value,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? localization.reminderTitleRequired
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      initialValue: message,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: localization.reminderMessage,
                      ),
                      onChanged: (value) => message = value,
                    ),
                    DropdownButtonFormField<ReminderPriority>(
                      initialValue: priority,
                      decoration: InputDecoration(
                        labelText: localization.priority,
                      ),
                      items: ReminderPriority.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(
                                localization.reminderPriorityLabel(value.name),
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => priority = value!,
                    ),
                    TextFormField(
                      initialValue: repeatRuleId,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: localization.repeatRuleId,
                      ),
                      onChanged: (value) => repeatRuleId = value,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: '$snoozeMinutes',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: localization.snoozeMinutes,
                            ),
                            onChanged: (value) =>
                                snoozeMinutes = int.tryParse(value) ?? 10,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextFormField(
                            initialValue: '$maxSnoozes',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: localization.maximumSnoozes,
                            ),
                            onChanged: (value) =>
                                maxSnoozes = int.tryParse(value) ?? 3,
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      initialValue: '$escalationStep',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: localization.escalationStep,
                      ),
                      onChanged: (value) =>
                          escalationStep = int.tryParse(value) ?? 0,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_outlined),
                      title: Text(localization.reminderDateTime),
                      subtitle: Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatFullDate(scheduledAt),
                      ),
                      trailing: Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatTimeOfDay(TimeOfDay.fromDateTime(scheduledAt)),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
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
                    message: message.trim().isEmpty ? null : message.trim(),
                    scheduledAt: scheduledAt.toUtc(),
                    timezoneId: DateTime.now().timeZoneName,
                    vibration: vibration,
                    voiceEnabled: voice,
                    flash: flash,
                    fullScreen: fullScreen,
                    autoSnooze: autoSnooze,
                    priority: priority,
                    repeatRuleId: int.tryParse(repeatRuleId),
                    snoozeMinutes: snoozeMinutes,
                    maxSnoozes: maxSnoozes,
                    escalationStep: escalationStep,
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
      if (initial == null) {
        await ref.read(reminderListControllerProvider.notifier).create(draft);
      } else {
        await ref
            .read(reminderListControllerProvider.notifier)
            .update(initial.id, draft);
      }
    }
  }

  Future<void> _showMissedReport(BuildContext context, WidgetRef ref) async {
    final localization = AppLocalizations.of(context);
    final missed = await ref
        .read(reminderListControllerProvider.notifier)
        .missedReport();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: missed.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(localization.noMissedReminders),
              )
            : ListView.builder(
                itemCount: missed.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.notification_important_outlined),
                  title: Text(
                    localization.reminderNumber(missed[index].reminderId),
                  ),
                  subtitle: Text(
                    localization.reminderActionLabel(missed[index].action.name),
                  ),
                ),
              ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.reminder,
    required this.onEnabledChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onSnooze,
  });

  final ReminderEntity reminder;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        onTap: onEdit,
        leading: const Icon(Icons.notifications_active_outlined),
        title: Text(
          reminder.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          MaterialLocalizations.of(
            context,
          ).formatFullDate(reminder.scheduledAt.toLocal()),
        ),
        trailing: PopupMenuButton<_ReminderAction>(
          tooltip: localization.availableActions,
          onSelected: (action) {
            switch (action) {
              case _ReminderAction.snooze:
                onSnooze();
              case _ReminderAction.toggle:
                onEnabledChanged(!reminder.enabled);
              case _ReminderAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _ReminderAction.snooze,
              child: Text(localization.snooze),
            ),
            PopupMenuItem(
              value: _ReminderAction.toggle,
              child: Text(
                reminder.enabled ? localization.disable : localization.enable,
              ),
            ),
            PopupMenuItem(
              value: _ReminderAction.delete,
              child: Text(localization.delete),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ReminderAction { snooze, toggle, delete }

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
        Icon(
          Icons.notifications_none,
          size: 72,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          localization.noRemindersTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
        Icon(
          Icons.error_outline,
          size: 72,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          localization.remindersErrorTitle,
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
