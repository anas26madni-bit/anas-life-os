import 'package:anas_life_os/app/app.dart';
import 'package:anas_life_os/core/database/database_foundation_status.dart';
import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('foundation shell starts and reports readiness', (tester) async {
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

    expect(find.text('Private workspace ready'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
