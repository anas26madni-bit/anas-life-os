import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_foundation_status.dart';
import '../providers/infrastructure_providers.dart';

final startupControllerProvider =
    AsyncNotifierProvider<StartupController, DatabaseFoundationReport>(
  StartupController.new,
);

class StartupController extends AsyncNotifier<DatabaseFoundationReport> {
  @override
  Future<DatabaseFoundationReport> build() {
    return ref.read(databaseInitializerProvider).verifyFoundation();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(databaseInitializerProvider).verifyFoundation,
    );
  }
}
