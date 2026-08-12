import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/security_models.dart';

final securityControllerProvider = AsyncNotifierProvider<SecurityController, SecurityState>(SecurityController.new);

final class SecurityState {
  const SecurityState({required this.preferences, required this.nativeStatus, required this.isLocked});
  final SecurityPreferences preferences;
  final NativeSecurityStatus nativeStatus;
  final bool isLocked;
  SecurityState copyWith({SecurityPreferences? preferences, NativeSecurityStatus? nativeStatus, bool? isLocked}) =>
      SecurityState(preferences: preferences ?? this.preferences, nativeStatus: nativeStatus ?? this.nativeStatus, isLocked: isLocked ?? this.isLocked);
}

class SecurityController extends AsyncNotifier<SecurityState> {
  @override
  Future<SecurityState> build() async {
    final repository = await ref.watch(securityRepositoryProvider.future);
    final platform = ref.watch(securityPlatformProvider);
    final preferences = await repository.loadPreferences();
    final nativeStatus = await platform.status();
    final enabled = preferences.pinEnabled && nativeStatus.hasPin;
    await platform.setSecureWindow(enabled);
    final gate = ref.read(authorizationGateProvider);
    enabled ? gate.lock() : gate.authorize();
    return SecurityState(
      preferences: preferences.copyWith(pinEnabled: enabled),
      nativeStatus: nativeStatus,
      isLocked: enabled,
    );
  }

  Future<bool> configurePin(String pin) async {
    if (!RegExp(r'^\d{6,}$').hasMatch(pin)) return false;
    final platform = ref.read(securityPlatformProvider);
    final result = await platform.configurePin(pin);
    if (!result.success) return false;
    final current = state.requireValue;
    final preferences = current.preferences.copyWith(pinEnabled: true);
    final repository = await ref.read(securityRepositoryProvider.future);
    await repository.savePreferences(preferences);
    await repository.recordAudit('pin_configured', success: true);
    await platform.setSecureWindow(true);
    ref.read(authorizationGateProvider).authorize();
    state = AsyncData(current.copyWith(preferences: preferences, isLocked: false));
    return true;
  }

  Future<UnlockResult> unlockWithPin(String pin) async {
    final result = await ref.read(securityPlatformProvider).verifyPin(pin);
    await _recordUnlock(UnlockMethod.pin, result);
    if (result.success) _authorize();
    return result;
  }

  Future<UnlockResult> unlockWithBiometric({required String title, required String subtitle, required String cancelLabel}) async {
    final result = await ref.read(securityPlatformProvider).authenticateBiometric(
      title: title, subtitle: subtitle, cancelLabel: cancelLabel,
    );
    await _recordUnlock(UnlockMethod.biometric, result);
    if (result.success) _authorize();
    return result;
  }

  Future<bool> changePin(String currentPin, String newPin) async {
    if (!RegExp(r'^\d{6,}$').hasMatch(newPin)) return false;
    final result = await ref.read(securityPlatformProvider).changePin(currentPin, newPin);
    await _recordUnlock(UnlockMethod.pin, result);
    if (!result.success) return false;
    await (await ref.read(securityRepositoryProvider.future)).recordAudit('pin_changed', success: true);
    return true;
  }

  Future<bool> disablePin(String currentPin) async {
    final result = await ref.read(securityPlatformProvider).disablePin(currentPin);
    if (!result.success) return false;
    final current = state.requireValue;
    const preferences = SecurityPreferences();
    final repository = await ref.read(securityRepositoryProvider.future);
    await repository.savePreferences(preferences);
    await repository.recordAudit('pin_disabled', success: true);
    await ref.read(securityPlatformProvider).setSecureWindow(false);
    ref.read(authorizationGateProvider).authorize();
    state = AsyncData(current.copyWith(preferences: preferences, isLocked: false));
    return true;
  }

  Future<void> updatePreferences(SecurityPreferences preferences) async {
    final current = state.requireValue;
    final safe = preferences.copyWith(pinEnabled: current.preferences.pinEnabled);
    await (await ref.read(securityRepositoryProvider.future)).savePreferences(safe);
    state = AsyncData(current.copyWith(preferences: safe));
  }

  void lock() {
    final current = state.value;
    if (current == null || !current.preferences.pinEnabled) return;
    ref.read(authorizationGateProvider).lock();
    state = AsyncData(current.copyWith(isLocked: true));
  }

  Future<void> _recordUnlock(UnlockMethod method, UnlockResult result) async =>
      (await ref.read(securityRepositoryProvider.future)).recordUnlock(
        method: method, success: result.success, failedAttempts: result.failedAttempts,
      );

  void _authorize() {
    ref.read(authorizationGateProvider).authorize();
    state = AsyncData(state.requireValue.copyWith(isLocked: false));
  }
}
