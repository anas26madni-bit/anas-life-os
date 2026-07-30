final class DatabaseBackupMetadata {
  const DatabaseBackupMetadata({
    required this.databaseName,
    required this.schemaVersion,
    required this.engineVersion,
    required this.cipherVersion,
    required this.generatedAt,
  });

  final String databaseName;
  final int schemaVersion;
  final String engineVersion;
  final String cipherVersion;
  final DateTime generatedAt;
}
