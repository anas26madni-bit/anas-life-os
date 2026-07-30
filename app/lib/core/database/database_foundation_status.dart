enum DatabaseFoundationStatus { checking, ready, unavailable }

final class DatabaseFoundationReport {
  const DatabaseFoundationReport({
    required this.status,
    this.engineVersion,
    this.cipherVersion,
    this.failureCode,
  });

  const DatabaseFoundationReport.checking()
    : this(status: DatabaseFoundationStatus.checking);

  final DatabaseFoundationStatus status;
  final String? engineVersion;
  final String? cipherVersion;
  final String? failureCode;

  bool get isReady => status == DatabaseFoundationStatus.ready;
}
