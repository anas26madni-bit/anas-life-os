import 'dart:typed_data';

import 'package:anas_life_os/core/database/database_key.dart';
import 'package:anas_life_os/features/database_foundation/data/database/app_database.dart';

DatabaseKey testDatabaseKey([int seed = 1]) => DatabaseKey(
  Uint8List.fromList(List<int>.generate(32, (index) => (index + seed) % 256)),
);

AppDatabase createTestDatabase() => AppDatabase.inMemory(testDatabaseKey());
