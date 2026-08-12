import 'package:anas_life_os/features/security/data/repositories/drift_security_repository.dart';
import 'package:anas_life_os/features/security/domain/entities/security_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test(
    'persists approved security settings and redacted audit events',
    () async {
      final database = createTestDatabase();
      addTearDown(database.close);
      final repository = DriftSecurityRepository(
        database,
        clock: () => DateTime.utc(2026),
        uuidFactory: () => '00000000-0000-4000-8000-000000000010',
      );

      const preferences = SecurityPreferences(
        pinEnabled: true,
        biometricEnabled: true,
        timeoutSeconds: 300,
      );
      await repository.savePreferences(preferences);
      await repository.recordUnlock(
        method: UnlockMethod.pin,
        success: false,
        failedAttempts: 2,
      );
      await repository.recordAudit('pin_configured', success: true);

      final loaded = await repository.loadPreferences();
      expect(loaded.pinEnabled, isTrue);
      expect(loaded.timeoutSeconds, 300);
      expect(
        (await database.select(database.appLockSessions).get())
            .single
            .failedAttempts,
        2,
      );
      expect(
        (await database.select(database.securityAuditLog).get())
            .single
            .safeDetail,
        isEmpty,
      );
    },
  );
}
