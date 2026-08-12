import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/security/domain/entities/security_models.dart';
import 'package:anas_life_os/features/security/domain/repositories/security_repository.dart';
import 'package:anas_life_os/features/security/domain/services/security_platform.dart';
import 'package:anas_life_os/features/security/presentation/controllers/security_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('configures, locks, unlocks, updates, changes and disables PIN', () async {
    final repository = _SecurityRepository();
    final platform = _SecurityPlatform();
    final container = ProviderContainer(overrides: [
      securityRepositoryProvider.overrideWith((ref) async => repository),
      securityPlatformProvider.overrideWithValue(platform),
    ]);
    addTearDown(container.dispose);
    final notifier = container.read(securityControllerProvider.notifier);
    expect((await container.read(securityControllerProvider.future)).isLocked, isFalse);
    expect(container.read(authorizationGateProvider).isAuthorized, isTrue);

    expect(await notifier.configurePin('123'), isFalse);
    expect(await notifier.configurePin('123456'), isTrue);
    expect(repository.preferences.pinEnabled, isTrue);
    notifier.lock();
    expect(container.read(securityControllerProvider).requireValue.isLocked, isTrue);
    expect(container.read(authorizationGateProvider).isAuthorized, isFalse);

    platform.verifyResult = const UnlockResult(success: false, failedAttempts: 1);
    expect((await notifier.unlockWithPin('000000')).success, isFalse);
    platform.verifyResult = const UnlockResult(success: true);
    expect((await notifier.unlockWithPin('123456')).success, isTrue);
    expect(container.read(authorizationGateProvider).isAuthorized, isTrue);

    await notifier.updatePreferences(
      repository.preferences.copyWith(autoLockEnabled: false, timeoutSeconds: 60),
    );
    expect(repository.preferences.timeoutSeconds, 60);
    expect(await notifier.changePin('123456', '1'), isFalse);
    expect(await notifier.changePin('123456', '654321'), isTrue);
    expect(await notifier.disablePin('654321'), isTrue);
    expect(repository.preferences.pinEnabled, isFalse);
    expect(platform.secureWindow, isFalse);
    expect(repository.audits, containsAll(['pin_configured', 'pin_changed', 'pin_disabled']));
  });

  test('biometric success authorizes a locked session', () async {
    final repository = _SecurityRepository()
      ..preferences = const SecurityPreferences(pinEnabled: true, biometricEnabled: true);
    final platform = _SecurityPlatform(hasPin: true, biometricAvailable: true);
    final container = ProviderContainer(overrides: [
      securityRepositoryProvider.overrideWith((ref) async => repository),
      securityPlatformProvider.overrideWithValue(platform),
    ]);
    addTearDown(container.dispose);
    expect((await container.read(securityControllerProvider.future)).isLocked, isTrue);

    final result = await container.read(securityControllerProvider.notifier).unlockWithBiometric(
      title: 'title', subtitle: 'subtitle', cancelLabel: 'cancel',
    );

    expect(result.success, isTrue);
    expect(container.read(securityControllerProvider).requireValue.isLocked, isFalse);
    expect(repository.unlockMethods, contains(UnlockMethod.biometric));
  });
}

final class _SecurityRepository implements SecurityRepository {
  SecurityPreferences preferences = const SecurityPreferences();
  final audits = <String>[];
  final unlockMethods = <UnlockMethod>[];
  @override Future<SecurityPreferences> loadPreferences() async => preferences;
  @override Future<void> savePreferences(SecurityPreferences value) async { preferences = value; }
  @override Future<void> recordAudit(String action, {required bool success}) async { audits.add(action); }
  @override Future<void> recordUnlock({required UnlockMethod method, required bool success, required int failedAttempts}) async { unlockMethods.add(method); }
}

final class _SecurityPlatform implements SecurityPlatform {
  _SecurityPlatform({this.hasPin = false, this.biometricAvailable = false});
  final bool hasPin;
  final bool biometricAvailable;
  UnlockResult verifyResult = const UnlockResult(success: true);
  bool secureWindow = false;
  @override Future<NativeSecurityStatus> status() async => NativeSecurityStatus(hasPin: hasPin, biometricAvailable: biometricAvailable, failedAttempts: 0, cooldownSeconds: 0);
  @override Future<UnlockResult> authenticateBiometric({required String title, required String subtitle, required String cancelLabel}) async => const UnlockResult(success: true);
  @override Future<UnlockResult> changePin(String currentPin, String newPin) async => const UnlockResult(success: true);
  @override Future<UnlockResult> configurePin(String pin) async => const UnlockResult(success: true);
  @override Future<UnlockResult> disablePin(String currentPin) async => const UnlockResult(success: true);
  @override Future<void> setSecureWindow(bool enabled) async { secureWindow = enabled; }
  @override Future<UnlockResult> verifyPin(String pin) async => verifyResult;
}
