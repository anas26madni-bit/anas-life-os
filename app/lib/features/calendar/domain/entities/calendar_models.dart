enum CalendarViewMode { day, week, month, year, agenda, timeline, heatMap }

enum CalendarItemKind { event, task }

final class CalendarEventDraft {
  const CalendarEventDraft({
    required this.title,
    required this.startAt,
    required this.endAt,
    this.description,
    this.allDay = false,
    this.timezoneId = 'UTC',
    this.location,
    this.color,
  });

  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime endAt;
  final bool allDay;
  final String timezoneId;
  final String? location;
  final String? color;
}

final class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.uuid,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.allDay,
    required this.timezoneId,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.location,
    this.color,
  });

  final int id;
  final String uuid;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime endAt;
  final bool allDay;
  final String timezoneId;
  final String? location;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class CalendarItem {
  const CalendarItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.allDay,
  });

  final int id;
  final CalendarItemKind kind;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final bool allDay;
}
