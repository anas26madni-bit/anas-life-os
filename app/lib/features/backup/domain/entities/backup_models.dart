enum BackupFrequency { daily, weekly }

enum BackupOperationStatus { running, succeeded, failed, cancelled }

final class BackupSettings {
  const BackupSettings({
    required this.automaticEnabled,
    required this.frequency,
    required this.retentionCount,
    this.destinationUri,
  });

  final bool automaticEnabled;
  final BackupFrequency frequency;
  final int retentionCount;
  final String? destinationUri;

  bool get canSchedule =>
      automaticEnabled && destinationUri != null && destinationUri!.isNotEmpty;
}

final class BackupRecord {
  const BackupRecord({
    required this.id,
    required this.name,
    required this.automatic,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.sizeBytes,
    this.safeError,
  });

  final int id;
  final String name;
  final bool automatic;
  final BackupOperationStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? sizeBytes;
  final String? safeError;
}

final class BackupArchiveResult {
  const BackupArchiveResult({
    required this.uri,
    required this.sizeBytes,
    required this.sha256,
  });

  final String uri;
  final int sizeBytes;
  final String sha256;
}

final class RestoreArchiveResult {
  const RestoreArchiveResult({required this.recordsRestored});

  final int recordsRestored;
}
