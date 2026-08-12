import 'package:flutter/services.dart';

import '../../domain/entities/security_models.dart';
import '../../domain/services/security_platform.dart';

final class AndroidSecurityPlatform implements SecurityPlatform {
  const AndroidSecurityPlatform({MethodChannel channel = _defaultChannel})
    : _channel = channel;

  static const _defaultChannel = MethodChannel('com.anaslifeos.app/security');
  final MethodChannel _channel;

  @override
  Future<NativeSecurityStatus> status() async {
    final value = await _channel.invokeMapMethod<String, Object?>('status');
    return NativeSecurityStatus(
      hasPin: value?['hasPin'] == true,
      biometricAvailable: value?['biometricAvailable'] == true,
      failedAttempts: value?['failedAttempts'] as int? ?? 0,
      cooldownSeconds: value?['cooldownSeconds'] as int? ?? 0,
    );
  }

  @override
  Future<UnlockResult> configurePin(String pin) =>
      _result('configurePin', <String, Object?>{'pin': pin});

  @override
  Future<UnlockResult> verifyPin(String pin) =>
      _result('verifyPin', <String, Object?>{'pin': pin});

  @override
  Future<UnlockResult> changePin(String currentPin, String newPin) => _result(
    'changePin',
    <String, Object?>{'currentPin': currentPin, 'newPin': newPin},
  );

  @override
  Future<UnlockResult> disablePin(String currentPin) =>
      _result('disablePin', <String, Object?>{'pin': currentPin});

  @override
  Future<UnlockResult> authenticateBiometric({
    required String title,
    required String subtitle,
    required String cancelLabel,
  }) => _result('authenticateBiometric', <String, Object?>{
    'title': title,
    'subtitle': subtitle,
    'cancelLabel': cancelLabel,
  });

  @override
  Future<void> setSecureWindow(bool enabled) =>
      _channel.invokeMethod<void>('setSecureWindow', enabled);

  Future<UnlockResult> _result(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    final value = await _channel.invokeMapMethod<String, Object?>(
      method,
      arguments,
    );
    return UnlockResult(
      success: value?['success'] == true,
      failedAttempts: value?['failedAttempts'] as int? ?? 0,
      cooldownSeconds: value?['cooldownSeconds'] as int? ?? 0,
    );
  }
}
