import 'package:drift/drift.dart';

@DataClassName('PluginRegistryRow')
@TableIndex(name: 'idx_plugin_registry_uuid', columns: {#uuid}, unique: true)
@TableIndex(
  name: 'idx_plugin_registry_name',
  columns: {#pluginName},
  unique: true,
)
@TableIndex(name: 'idx_plugin_registry_enabled', columns: {#enabled})
class PluginRegistry extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 36, max: 36)();

  TextColumn get pluginName => text().withLength(min: 1, max: 200)();

  TextColumn get pluginVersion => text().withLength(min: 1, max: 100)();

  BoolColumn get enabled => boolean().withDefault(const Constant(false))();

  IntColumn get installDate => integer()();

  IntColumn get lastUpdate => integer()();

  TextColumn get requiredPermissions =>
      text().withDefault(const Constant('[]'))();

  @override
  String get tableName => 'plugin_registry';
}
