import 'task_enums.dart';

final class AttachmentDraft {
  const AttachmentDraft({
    required this.taskId,
    required this.fileName,
    required this.storagePath,
    required this.fileSize,
    required this.checksumSha256,
    this.originalFileName,
    this.extension,
    this.mimeType,
  });

  final int taskId;
  final String fileName;
  final String? originalFileName;
  final String? extension;
  final String? mimeType;
  final String storagePath;
  final int fileSize;
  final String checksumSha256;
}

final class RepeatRuleDraft {
  const RepeatRuleDraft({
    required this.name,
    required this.frequency,
    required this.timezoneId,
    this.interval = 1,
    this.weekdayMask = 0,
    this.dayOfMonth,
    this.monthOfYear,
    this.endType = RepeatEndType.never,
    this.endAt,
    this.occurrenceLimit,
  });

  final String name;
  final RepeatFrequency frequency;
  final int interval;
  final int weekdayMask;
  final int? dayOfMonth;
  final int? monthOfYear;
  final String timezoneId;
  final RepeatEndType endType;
  final DateTime? endAt;
  final int? occurrenceLimit;
}
