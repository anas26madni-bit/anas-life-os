import 'package:anas_life_os/features/security/domain/entities/security_models.dart';
import 'package:anas_life_os/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('security preferences copy every approved policy field', () {
    const defaults = SecurityPreferences();
    final configured = defaults.copyWith(
      pinEnabled: true,
      biometricEnabled: true,
      autoLockEnabled: false,
      timeoutSeconds: 900,
      hiddenItemsEnabled: false,
    );

    expect(configured.pinEnabled, isTrue);
    expect(configured.biometricEnabled, isTrue);
    expect(configured.autoLockEnabled, isFalse);
    expect(configured.timeoutSeconds, 900);
    expect(configured.hiddenItemsEnabled, isFalse);
    expect(configured.copyWith().pinEnabled, isTrue);
    expect(UnlockMethod.values, [UnlockMethod.pin, UnlockMethod.biometric]);
  });

  test('native status and unlock result expose fail-closed state', () {
    const status = NativeSecurityStatus(
      hasPin: true,
      biometricAvailable: false,
      failedAttempts: 5,
      cooldownSeconds: 30,
    );
    const result = UnlockResult(
      success: false,
      failedAttempts: 5,
      cooldownSeconds: 30,
    );
    expect(status.hasPin, isTrue);
    expect(status.biometricAvailable, isFalse);
    expect(status.failedAttempts, 5);
    expect(status.cooldownSeconds, 30);
    expect(result.success, isFalse);
    expect(result.failedAttempts, 5);
    expect(result.cooldownSeconds, 30);
    expect(const UnlockResult(success: true).failedAttempts, 0);
  });

  test('app settings copy every persisted appearance field', () {
    const defaults = AppSettings();
    final configured = defaults.copyWith(
      theme: AppThemeSetting.dark,
      language: AppLanguageSetting.ur,
      fontScalePercent: 200,
      accentColor: 0xFF000000,
      useDynamicColor: false,
      reduceMotion: true,
    );
    expect(configured.theme, AppThemeSetting.dark);
    expect(configured.language, AppLanguageSetting.ur);
    expect(configured.fontScalePercent, 200);
    expect(configured.accentColor, 0xFF000000);
    expect(configured.useDynamicColor, isFalse);
    expect(configured.reduceMotion, isTrue);
    expect(configured.copyWith().theme, AppThemeSetting.dark);
    expect(AppThemeSetting.values, hasLength(3));
    expect(AppLanguageSetting.values, hasLength(3));
  });
}
