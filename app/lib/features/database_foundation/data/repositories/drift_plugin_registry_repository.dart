import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/plugin_descriptor.dart';
import '../../domain/repositories/plugin_registry_repository.dart';
import '../database/app_database.dart';

final class DriftPluginRegistryRepository implements PluginRegistryRepository {
  const DriftPluginRegistryRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> save(PluginDescriptor descriptor) async {
    await _database
        .into(_database.pluginRegistry)
        .insertOnConflictUpdate(
          PluginRegistryCompanion.insert(
            uuid: descriptor.uuid,
            pluginName: descriptor.name,
            pluginVersion: descriptor.version,
            enabled: Value(descriptor.enabled),
            installDate: descriptor.installedAt.toUtc().microsecondsSinceEpoch,
            lastUpdate: descriptor.updatedAt.toUtc().microsecondsSinceEpoch,
            requiredPermissions: Value(
              jsonEncode(descriptor.requiredPermissions),
            ),
          ),
        );
  }

  @override
  Future<PluginDescriptor?> findByName(String name) async {
    final query = _database.select(_database.pluginRegistry)
      ..where((table) => table.pluginName.equals(name));
    final row = await query.getSingleOrNull();
    return row == null ? null : _map(row);
  }

  @override
  Future<List<PluginDescriptor>> getEnabled() async {
    final query = _database.select(_database.pluginRegistry)
      ..where((table) => table.enabled.equals(true))
      ..orderBy([(table) => OrderingTerm.asc(table.pluginName)]);
    return (await query.get()).map(_map).toList(growable: false);
  }

  PluginDescriptor _map(PluginRegistryRow row) {
    final decoded = jsonDecode(row.requiredPermissions) as List<Object?>;
    return PluginDescriptor(
      uuid: row.uuid,
      name: row.pluginName,
      version: row.pluginVersion,
      enabled: row.enabled,
      installedAt: DateTime.fromMicrosecondsSinceEpoch(
        row.installDate,
        isUtc: true,
      ),
      updatedAt: DateTime.fromMicrosecondsSinceEpoch(
        row.lastUpdate,
        isUtc: true,
      ),
      requiredPermissions: decoded.cast<String>(),
    );
  }
}
