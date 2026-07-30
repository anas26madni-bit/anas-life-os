enum TaskStatus {
  draft,
  scheduled,
  pending,
  inProgress,
  waiting,
  blocked,
  completed,
  archived,
  deleted,
}

enum TaskPriority { none, low, medium, high, critical }

enum DependencyType {
  finishToStart,
  startToStart,
  finishToFinish,
  startToFinish,
}

enum RepeatFrequency { daily, weekly, monthly, yearly, custom }

enum RepeatEndType { never, onDate, afterOccurrences }

enum CustomFieldOwner { task, project }

enum CustomFieldType {
  text,
  integer,
  decimal,
  boolean,
  date,
  dateTime,
  singleSelect,
  multiSelect,
}
