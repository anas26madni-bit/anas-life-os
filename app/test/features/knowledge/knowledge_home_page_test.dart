import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/knowledge/presentation/pages/knowledge_home_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  testWidgets('creates and searches a private knowledge note', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWith((ref) async => database)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: KnowledgeHomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No knowledge yet'), findsOneWidget);

    await tester.tap(find.text('Create note'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Private wiki');
    await tester.enterText(fields.at(1), 'Offline linked content');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Private wiki'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports Urdu RTL and large text without overflow', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWith((ref) async => database)],
        child: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: MaterialApp(
            locale: Locale('ur'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: KnowledgeHomePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(Scaffold))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });
}
