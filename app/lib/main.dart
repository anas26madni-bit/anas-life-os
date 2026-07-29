import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/database_initializer.dart';
import 'core/di/injection.dart';
import 'core/logging/app_logger.dart';
import 'core/providers/infrastructure_providers.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      configureDependencies();

      final logger = getIt<AppLogger>();
      FlutterError.onError = (details) {
        logger.error(
          'Flutter framework error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        logger.error(
          'Uncaught platform error',
          error: error,
          stackTrace: stackTrace,
        );
        return true;
      };

      runApp(
        ProviderScope(
          overrides: [
            appLoggerProvider.overrideWithValue(logger),
            databaseInitializerProvider.overrideWithValue(
              getIt<DatabaseInitializer>(),
            ),
          ],
          child: const AnasLifeOsApp(),
        ),
      );
    },
    (error, stackTrace) {
      if (getIt.isRegistered<AppLogger>()) {
        getIt<AppLogger>().fatal(
          'Uncaught bootstrap error',
          error: error,
          stackTrace: stackTrace,
        );
      }
    },
  );
}
