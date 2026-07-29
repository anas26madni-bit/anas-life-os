import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_initializer.dart';
import '../logging/app_logger.dart';

final appLoggerProvider = Provider<AppLogger>(
  (ref) => throw StateError('AppLogger override was not installed.'),
);

final databaseInitializerProvider = Provider<DatabaseInitializer>(
  (ref) => throw StateError('DatabaseInitializer override was not installed.'),
);
