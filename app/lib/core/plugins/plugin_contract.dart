import 'package:meta/meta.dart';

enum PluginLifecycleState {
  installed,
  enabled,
  disabled,
  updated,
  removed,
  failed,
  incompatible,
}

enum PluginPermission {
  readTasks,
  writeTasks,
  readNotes,
  writeNotes,
  readFiles,
  backgroundProcessing,
  notifications,
  networkAccess,
  camera,
  microphone,
  location,
  storage,
}

@immutable
class PluginDescriptor {
  const PluginDescriptor({
    required this.id,
    required this.name,
    required this.pluginVersion,
    required this.apiVersion,
    required this.minimumAppVersion,
    required this.maximumTestedAppVersion,
    required this.permissions,
  });

  final String id;
  final String name;
  final String pluginVersion;
  final String apiVersion;
  final String minimumAppVersion;
  final String maximumTestedAppVersion;
  final Set<PluginPermission> permissions;
}

abstract interface class LifeOsPlugin {
  PluginDescriptor get descriptor;
  PluginLifecycleState get state;

  Future<void> enable(Set<PluginPermission> grantedPermissions);

  Future<void> disable();
}

/// Core-owned gateway; plugins never receive database or unrestricted storage.
abstract interface class PluginGateway {
  Future<Object?> invoke({
    required String pluginId,
    required String operation,
    required Map<String, Object?> input,
  });
}
