import 'package:anas_life_os/core/database/database_foundation_status.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/core/startup/foundation_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  testWidgets('shows a localized ready state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseInitializerProvider.overrideWithValue(
            FakeDatabaseInitializer(
              const DatabaseFoundationReport(
                status: DatabaseFoundationStatus.ready,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FoundationPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Private workspace ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses RTL direction for Urdu', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseInitializerProvider.overrideWithValue(
            FakeDatabaseInitializer(
              const DatabaseFoundationReport(
                status: DatabaseFoundationStatus.ready,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ur'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FoundationPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
    expect(find.text('نجی جگہ تیار ہے'), findsOneWidget);
  });
}
