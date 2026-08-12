import '../entities/security_models.dart';

abstract interface class SecurityRepository {
  Future<SecurityPreferences> loadPreferences();
  Future<void> savePreferences(SecurityPreferences preferences);
  Future<void> recordUnlock({
    required UnlockMethod method,
    required bool success,
    required int failedAttempts,
  });
  Future<void> recordAudit(String action, {required bool success});
}
