import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/tasks/presentation/pages/task_list_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  testWidgets('creates and completes a task through the accessible UI', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TaskListPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No tasks yet'), findsOneWidget);
    await tester.tap(find.text('Create task').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Offline task');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Offline task'), findsOneWidget);
    await tester.tap(find.byTooltip('Complete task'));
    await tester.pumpAndSettle();
    expect(find.text('completed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supports RTL and large text without overflow', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
        ],
        child: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: MaterialApp(
            locale: Locale('ur'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TaskListPage(),
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
