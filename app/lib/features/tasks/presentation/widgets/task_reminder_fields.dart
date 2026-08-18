import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../reminders/domain/entities/reminder_draft.dart';
import '../../../reminders/domain/entities/reminder_entity.dart';

final class TaskReminderFormData {
  TaskReminderFormData({
    this.enabled = false,
    DateTime? scheduledAt,
    this.repeatRuleId = '',
    this.audible = true,
  }) : scheduledAt =
           scheduledAt ?? DateTime.now().add(const Duration(hours: 1));

  factory TaskReminderFormData.fromReminder(ReminderEntity? reminder) =>
      TaskReminderFormData(
        enabled: reminder?.enabled ?? false,
        scheduledAt: reminder?.scheduledAt.toLocal(),
        repeatRuleId: reminder?.repeatRuleId?.toString() ?? '',
        audible: reminder?.sound != 'silent',
      );

  bool enabled;
  DateTime scheduledAt;
  String repeatRuleId;
  bool audible;

  ReminderDraft toDraft({
    required int taskId,
    required String title,
    String? message,
  }) => ReminderDraft(
    taskId: taskId,
    title: title,
    message: message,
    scheduledAt: scheduledAt.toUtc(),
    timezoneId: DateTime.now().timeZoneName,
    repeatRuleId: int.tryParse(repeatRuleId),
    sound: audible ? 'default' : 'silent',
  );
}

class TaskReminderFields extends StatefulWidget {
  const TaskReminderFields({
    required this.data,
    required this.onChanged,
    super.key,
  });

  final TaskReminderFormData data;
  final VoidCallback onChanged;

  @override
  State<TaskReminderFields> createState() => _TaskReminderFieldsState();
}

class _TaskReminderFieldsState extends State<TaskReminderFields> {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final data = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          value: data.enabled,
          onChanged: (value) {
            setState(() => data.enabled = value);
            widget.onChanged();
          },
        ),
        if (data.enabled) ...[
          ListTile(
            key: const Key('task-reminder-date'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(localization.reminderDate),
            subtitle: Text(
              MaterialLocalizations.of(
                context,
              ).formatFullDate(data.scheduledAt),
            ),
            onTap: _selectDate,
          ),
          ListTile(
            key: const Key('task-reminder-time'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_outlined),
            title: Text(localization.reminderTime),
            subtitle: Text(
              MaterialLocalizations.of(
                context,
              ).formatTimeOfDay(TimeOfDay.fromDateTime(data.scheduledAt)),
            ),
            onTap: _selectTime,
          ),
          SwitchListTile(
            key: const Key('task-reminder-audible'),
            contentPadding: EdgeInsets.zero,
            title: Text(localization.audibleReminder),
            secondary: const Icon(Icons.volume_up_outlined),
            value: data.audible,
            onChanged: (value) {
              setState(() => data.audible = value);
              widget.onChanged();
            },
          ),
          TextFormField(
            key: const Key('task-reminder-repeat-rule'),
            initialValue: data.repeatRuleId,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: localization.repeatRuleId),
            onChanged: (value) => data.repeatRuleId = value,
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 3650)),
      initialDate: widget.data.scheduledAt,
    );
    if (selected == null) return;
    setState(() {
      final current = widget.data.scheduledAt;
      widget.data.scheduledAt = DateTime(
        selected.year,
        selected.month,
        selected.day,
        current.hour,
        current.minute,
      );
    });
    widget.onChanged();
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.data.scheduledAt),
    );
    if (selected == null) return;
    setState(() {
      final current = widget.data.scheduledAt;
      widget.data.scheduledAt = DateTime(
        current.year,
        current.month,
        current.day,
        selected.hour,
        selected.minute,
      );
    });
    widget.onChanged();
  }
}
