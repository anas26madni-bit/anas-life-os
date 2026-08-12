import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/security/domain/entities/security_models.dart';
import 'package:anas_life_os/features/security/domain/services/security_platform.dart';
import 'package:anas_life_os/features/security/presentation/pages/security_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  testWidgets('security screen supports Urdu RTL and 48dp controls', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => database),
        securityPlatformProvider.overrideWithValue(_FakeSecurityPlatform()),
      ],
      child: MaterialApp(
        locale: const Locale('ur'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const SecurityPage(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SecurityPage), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(SecurityPage))), TextDirection.rtl);
    expect(tester.getSize(find.byType(ListTile).first).height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });
}

final class _FakeSecurityPlatform implements SecurityPlatform {
  @override Future<NativeSecurityStatus> status() async => const NativeSecurityStatus(hasPin: false, biometricAvailable: true, failedAttempts: 0, cooldownSeconds: 0);
  @override Future<UnlockResult> authenticateBiometric({required String title, required String subtitle, required String cancelLabel}) async => const UnlockResult(success: true);
  @override Future<UnlockResult> changePin(String currentPin, String newPin) async => const UnlockResult(success: true);
  @override Future<UnlockResult> configurePin(String pin) async => const UnlockResult(success: true);
  @override Future<UnlockResult> disablePin(String currentPin) async => const UnlockResult(success: true);
  @override Future<void> setSecureWindow(bool enabled) async {}
  @override Future<UnlockResult> verifyPin(String pin) async => const UnlockResult(success: true);
}
