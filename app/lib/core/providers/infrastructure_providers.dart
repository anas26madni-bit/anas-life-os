import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/database_foundation/data/database/app_database.dart';
import '../../features/knowledge/data/repositories/drift_document_repository.dart';
import '../../features/knowledge/data/repositories/drift_knowledge_repository.dart';
import '../../features/knowledge/domain/repositories/document_repository.dart';
import '../../features/knowledge/domain/repositories/knowledge_repository.dart';
import '../../features/reminders/data/repositories/drift_reminder_repository.dart';
import '../../features/reminders/data/services/android_reminder_scheduler.dart';
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../../features/reminders/domain/services/reminder_scheduler.dart';
import '../../features/tasks/data/repositories/drift_project_repository.dart';
import '../../features/tasks/data/repositories/drift_task_composition_repository.dart';
import '../../features/tasks/data/repositories/drift_task_repository.dart';
import '../../features/tasks/data/repositories/drift_task_support_repository.dart';
import '../../features/tasks/domain/repositories/project_repository.dart';
import '../../features/tasks/domain/repositories/task_composition_repository.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/repositories/task_support_repository.dart';
import '../database/android_database_platform.dart';
import '../database/database_file_resolver.dart';
import '../database/database_initializer.dart';
import '../database/encrypted_database_opener.dart';
import '../logging/app_logger.dart';

final appLoggerProvider = Provider<AppLogger>(
  (ref) => throw StateError('AppLogger override was not installed.'),
);

final databaseInitializerProvider = Provider<DatabaseInitializer>(
  (ref) => throw StateError('DatabaseInitializer override was not installed.'),
);

final androidDatabasePlatformProvider = Provider<AndroidDatabasePlatform>(
  (ref) => const AndroidDatabasePlatform(),
);

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final platform = ref.watch(androidDatabasePlatformProvider);
  final database = await EncryptedDatabaseOpener(
    DatabaseFileResolver(platform.databaseDirectory),
    platform,
  ).open();
  ref.onDispose(database.close);
  return database;
});

final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftTaskRepository(database);
});

final taskSupportRepositoryProvider = FutureProvider<TaskSupportRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftTaskSupportRepository(database);
});
final taskCompositionRepositoryProvider =
    FutureProvider<TaskCompositionRepository>((ref) async {
      final database = await ref.watch(appDatabaseProvider.future);
      return DriftTaskCompositionRepository(database);
    });

final projectRepositoryProvider = FutureProvider<ProjectRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftProjectRepository(database);
});

final reminderRepositoryProvider = FutureProvider<ReminderRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftReminderRepository(database);
});

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => const AndroidReminderScheduler(),
);

final knowledgeRepositoryProvider = FutureProvider<KnowledgeRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftKnowledgeRepository(database);
});

final documentRepositoryProvider = FutureProvider<DocumentRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftDocumentRepository(database);
});
