import '../entities/security_models.dart';

abstract interface class SecurityPlatform {
  Future<NativeSecurityStatus> status();
  Future<UnlockResult> configurePin(String pin);
  Future<UnlockResult> verifyPin(String pin);
  Future<UnlockResult> changePin(String currentPin, String newPin);
  Future<UnlockResult> disablePin(String currentPin);
  Future<UnlockResult> authenticateBiometric({
    required String title,
    required String subtitle,
    required String cancelLabel,
  });
  Future<void> setSecureWindow(bool enabled);
}
