import 'package:anas_life_os/features/database_foundation/data/repositories/drift_plugin_registry_repository.dart';
import 'package:anas_life_os/features/database_foundation/domain/entities/plugin_descriptor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('persists inert plugin descriptors with normalized permissions', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftPluginRegistryRepository(database);
    final installedAt = DateTime.utc(2026, 7, 30);

    await repository.save(
      PluginDescriptor(
        uuid: '00000000-0000-7000-8000-000000000001',
        name: 'core.descriptor',
        version: '1.0.0',
        enabled: true,
        installedAt: installedAt,
        updatedAt: installedAt,
        requiredPermissions: const ['read_notes', 'read_tasks', 'read_notes'],
      ),
    );

    final descriptor = await repository.findByName('core.descriptor');
    expect(descriptor, isNotNull);
    expect(descriptor!.requiredPermissions, ['read_notes', 'read_tasks']);
    expect((await repository.getEnabled()).single.name, 'core.descriptor');
  });

  test('validates descriptor identity fields', () {
    final now = DateTime.utc(2026, 7, 30);
    expect(
      () => PluginDescriptor(
        uuid: 'invalid',
        name: 'core.descriptor',
        version: '1.0.0',
        enabled: false,
        installedAt: now,
        updatedAt: now,
        requiredPermissions: const [],
      ),
      throwsArgumentError,
    );
    expect(
      () => PluginDescriptor(
        uuid: '00000000-0000-7000-8000-000000000001',
        name: ' ',
        version: '1.0.0',
        enabled: false,
        installedAt: now,
        updatedAt: now,
        requiredPermissions: const [],
      ),
      throwsArgumentError,
    );
    expect(
      () => PluginDescriptor(
        uuid: '00000000-0000-7000-8000-000000000001',
        name: 'core.descriptor',
        version: '',
        enabled: false,
        installedAt: now,
        updatedAt: now,
        requiredPermissions: const [],
      ),
      throwsArgumentError,
    );
    expect(
      () => PluginDescriptor(
        uuid: '00000000-0000-7000-8000-000000000001',
        name: 'core.descriptor',
        version: '1.0.0',
        enabled: false,
        installedAt: now,
        updatedAt: now.subtract(const Duration(seconds: 1)),
        requiredPermissions: const [],
      ),
      throwsArgumentError,
    );
  });
}
