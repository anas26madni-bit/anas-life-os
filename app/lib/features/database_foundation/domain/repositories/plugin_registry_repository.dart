import '../entities/plugin_descriptor.dart';

abstract interface class PluginRegistryRepository {
  Future<void> save(PluginDescriptor descriptor);

  Future<PluginDescriptor?> findByName(String name);

  Future<List<PluginDescriptor>> getEnabled();
}
