enum MigrationStatus { running, succeeded, failed }

final class MigrationRecord {
  const MigrationRecord({
    required this.id,
    required this.uuid,
    required this.fromVersion,
    required this.toVersion,
    required this.name,
    required this.startedAt,
    required this.status,
    this.completedAt,
  });

  final int id;
  final String uuid;
  final int fromVersion;
  final int toVersion;
  final String name;
  final DateTime startedAt;
  final DateTime? completedAt;
  final MigrationStatus status;
}
