enum ReminderPriority { low, normal, high, critical }

enum ReminderAction {
  triggered,
  opened,
  completed,
  dismissed,
  ignored,
  snoozed,
  expired,
}

enum ReminderSchedulePrecision { exact, inexact }

enum ReminderRepeatFrequency { none, daily, weekly, monthly, yearly, custom }

enum ReminderRepeatEnd { never, onDate, afterOccurrences }
