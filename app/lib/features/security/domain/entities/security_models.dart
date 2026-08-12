enum UnlockMethod { pin, biometric }

final class SecurityPreferences {
  const SecurityPreferences({
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.autoLockEnabled = true,
    this.timeoutSeconds = 0,
    this.hiddenItemsEnabled = true,
  });

  final bool pinEnabled;
  final bool biometricEnabled;
  final bool autoLockEnabled;
  final int timeoutSeconds;
  final bool hiddenItemsEnabled;

  SecurityPreferences copyWith({
    bool? pinEnabled,
    bool? biometricEnabled,
    bool? autoLockEnabled,
    int? timeoutSeconds,
    bool? hiddenItemsEnabled,
  }) => SecurityPreferences(
    pinEnabled: pinEnabled ?? this.pinEnabled,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    hiddenItemsEnabled: hiddenItemsEnabled ?? this.hiddenItemsEnabled,
  );
}

final class NativeSecurityStatus {
  const NativeSecurityStatus({
    required this.hasPin,
    required this.biometricAvailable,
    required this.failedAttempts,
    required this.cooldownSeconds,
  });

  final bool hasPin;
  final bool biometricAvailable;
  final int failedAttempts;
  final int cooldownSeconds;
}

final class UnlockResult {
  const UnlockResult({
    required this.success,
    this.failedAttempts = 0,
    this.cooldownSeconds = 0,
  });

  final bool success;
  final int failedAttempts;
  final int cooldownSeconds;
}
