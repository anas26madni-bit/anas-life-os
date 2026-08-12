import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/security_models.dart';
import '../../domain/repositories/security_repository.dart';

final class DriftSecurityRepository implements SecurityRepository {
  DriftSecurityRepository(this._database, {DateTime Function()? clock, String Function()? uuidFactory})
      : _clock = clock ?? DateTime.now,
        _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  @override
  Future<SecurityPreferences> loadPreferences() async {
    final row = await (_database.select(_database.securitySettings)
          ..where((table) => table.id.equals(1)))
        .getSingleOrNull();
    if (row == null) return const SecurityPreferences();
    return SecurityPreferences(
      pinEnabled: row.pinEnabled,
      biometricEnabled: row.biometricEnabled,
      autoLockEnabled: row.autoLockEnabled,
      timeoutSeconds: row.appLockTimeoutSeconds,
      hiddenItemsEnabled: row.hiddenItemsEnabled,
    );
  }

  @override
  Future<void> savePreferences(SecurityPreferences preferences) async {
    final now = _clock().toUtc().microsecondsSinceEpoch;
    await _database.into(_database.securitySettings).insertOnConflictUpdate(
      SecuritySettingsCompanion.insert(
        id: const Value(1),
        pinEnabled: Value(preferences.pinEnabled),
        biometricEnabled: Value(preferences.biometricEnabled),
        autoLockEnabled: Value(preferences.autoLockEnabled),
        appLockTimeoutSeconds: Value(preferences.timeoutSeconds),
        hiddenItemsEnabled: Value(preferences.hiddenItemsEnabled),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> recordUnlock({required UnlockMethod method, required bool success, required int failedAttempts}) async {
    final now = _clock().toUtc().microsecondsSinceEpoch;
    await _database.into(_database.appLockSessions).insert(
      AppLockSessionsCompanion.insert(
        uuid: _uuidFactory(), sessionStart: now, sessionEnd: Value(success ? now : null),
        unlockMethod: method.name, success: success, failedAttempts: Value(failedAttempts),
        deviceTime: now, createdAt: now,
      ),
    );
  }

  @override
  Future<void> recordAudit(String action, {required bool success}) async {
    await _database.into(_database.securityAuditLog).insert(
      SecurityAuditLogCompanion.insert(
        uuid: _uuidFactory(), action: action, success: success,
        createdAt: _clock().toUtc().microsecondsSinceEpoch,
      ),
    );
  }
}
