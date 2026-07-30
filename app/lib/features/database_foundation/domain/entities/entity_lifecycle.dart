final class EntityLifecycle {
  factory EntityLifecycle({
    required int version,
    required bool isDeleted,
    DateTime? deletedAt,
  }) {
    if (version < 1) {
      throw ArgumentError.value(version, 'version', 'Version must be positive.');
    }
    if (isDeleted != (deletedAt != null)) {
      throw ArgumentError(
        'Deleted state and deletion timestamp must change together.',
      );
    }
    return EntityLifecycle._(
      version: version,
      isDeleted: isDeleted,
      deletedAt: deletedAt?.toUtc(),
    );
  }

  const EntityLifecycle.active()
    : version = 1,
      isDeleted = false,
      deletedAt = null;

  const EntityLifecycle._({
    required this.version,
    required this.isDeleted,
    required this.deletedAt,
  });

  final int version;
  final bool isDeleted;
  final DateTime? deletedAt;

  EntityLifecycle softDelete(DateTime timestamp) {
    if (isDeleted) {
      return this;
    }
    return EntityLifecycle(
      version: version + 1,
      isDeleted: true,
      deletedAt: timestamp.toUtc(),
    );
  }

  EntityLifecycle restore() {
    if (!isDeleted) {
      return this;
    }
    return EntityLifecycle(
      version: version + 1,
      isDeleted: false,
    );
  }
}
