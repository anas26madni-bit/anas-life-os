import 'package:anas_life_os/core/database/database_foundation_status.dart';
import 'package:anas_life_os/core/database/database_initializer.dart';
import 'package:anas_life_os/core/logging/app_logger.dart';
import 'package:anas_life_os/features/security/domain/entities/security_models.dart';
import 'package:anas_life_os/features/security/domain/services/security_platform.dart';
import 'package:anas_life_os/features/security/domain/entities/security_models.dart';
import 'package:anas_life_os/features/security/domain/services/security_platform.dart';

class FakeAppLogger implements AppLogger {
  final messages = <String>[];

  @override
  void debug(String message, {Map<String, Object?> context = const {}}) {
    messages.add(message);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    messages.add(message);
  }

  @override
  void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    messages.add(message);
  }

  @override
  void info(String message, {Map<String, Object?> context = const {}}) {
    messages.add(message);
  }

  @override
  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    messages.add(message);
  }
}

final class FakeSecurityPlatform implements SecurityPlatform {
  const FakeSecurityPlatform({this.hasPin = false});
  final bool hasPin;

  @override
  Future<NativeSecurityStatus> status() async => NativeSecurityStatus(
    hasPin: hasPin,
    biometricAvailable: false,
    failedAttempts: 0,
    cooldownSeconds: 0,
  );
  @override
  Future<UnlockResult> authenticateBiometric({required String title, required String subtitle, required String cancelLabel}) async => const UnlockResult(success: false);
  @override Future<UnlockResult> changePin(String currentPin, String newPin) async => const UnlockResult(success: true);
  @override Future<UnlockResult> configurePin(String pin) async => const UnlockResult(success: true);
  @override Future<UnlockResult> disablePin(String currentPin) async => const UnlockResult(success: true);
  @override Future<void> setSecureWindow(bool enabled) async {}
  @override Future<UnlockResult> verifyPin(String pin) async => const UnlockResult(success: true);
}

final class FakeSecurityPlatform implements SecurityPlatform {
  const FakeSecurityPlatform({this.hasPin = false});
  final bool hasPin;

  @override
  Future<NativeSecurityStatus> status() async => NativeSecurityStatus(
    hasPin: hasPin,
    biometricAvailable: false,
    failedAttempts: 0,
    cooldownSeconds: 0,
  );
  @override
  Future<UnlockResult> authenticateBiometric({required String title, required String subtitle, required String cancelLabel}) async => const UnlockResult(success: false);
  @override Future<UnlockResult> changePin(String currentPin, String newPin) async => const UnlockResult(success: true);
  @override Future<UnlockResult> configurePin(String pin) async => const UnlockResult(success: true);
  @override Future<UnlockResult> disablePin(String currentPin) async => const UnlockResult(success: true);
  @override Future<void> setSecureWindow(bool enabled) async {}
  @override Future<UnlockResult> verifyPin(String pin) async => const UnlockResult(success: true);
}

class FakeDatabaseInitializer extends DatabaseInitializer {
  FakeDatabaseInitializer(this.report, {this.delay = Duration.zero})
    : super(FakeAppLogger());

  final DatabaseFoundationReport report;
  final Duration delay;

  @override
  Future<DatabaseFoundationReport> verifyFoundation() async {
    await Future<void>.delayed(delay);
    return report;
  }
}
