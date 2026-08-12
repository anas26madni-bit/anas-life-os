import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/features/settings/domain/entities/app_settings.dart';
import 'package:anas_life_os/features/settings/presentation/pages/settings_page.dart';
import 'package:anas_life_os/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  testWidgets(
    'settings expose persisted appearance and accessibility controls',
    (tester) async {
      final database = createTestDatabase();
      addTearDown(database.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async => database),
          ],
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DropdownButton<AppThemeSetting>), findsOneWidget);
      expect(find.byType(DropdownButton<AppLanguageSetting>), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );
}
