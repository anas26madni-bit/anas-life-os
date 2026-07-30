final class PluginDescriptor {
  PluginDescriptor({
    required this.uuid,
    required this.name,
    required this.version,
    required this.enabled,
    required this.installedAt,
    required this.updatedAt,
    required Iterable<String> requiredPermissions,
  }) : requiredPermissions = List.unmodifiable(
         requiredPermissions.toSet().toList()..sort(),
       ) {
    if (!_uuidPattern.hasMatch(uuid)) {
      throw ArgumentError.value(uuid, 'uuid', 'Plugin UUID is invalid.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Plugin name cannot be empty.');
    }
    if (version.trim().isEmpty) {
      throw ArgumentError.value(
        version,
        'version',
        'Plugin version cannot be empty.',
      );
    }
    if (updatedAt.isBefore(installedAt)) {
      throw ArgumentError.value(
        updatedAt,
        'updatedAt',
        'Plugin update time cannot precede installation.',
      );
    }
  }

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-'
    r'[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  final String uuid;
  final String name;
  final String version;
  final bool enabled;
  final DateTime installedAt;
  final DateTime updatedAt;
  final List<String> requiredPermissions;
}
