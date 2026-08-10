import 'package:anas_life_os/app/app.dart';
import 'package:anas_life_os/core/database/database_foundation_status.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('foundation enters the dashboard shell when ready', (tester) async {
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
        child: const AnasLifeOsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
