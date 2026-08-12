import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/backup/data/repositories/drift_backup_repository.dart';
import '../../features/backup/data/services/android_backup_platform.dart';
import '../../features/backup/domain/repositories/backup_repository.dart';
import '../../features/backup/domain/services/backup_platform.dart';
import '../../features/calendar/data/repositories/drift_calendar_repository.dart';
import '../../features/calendar/domain/repositories/calendar_repository.dart';
import '../../features/dashboard/data/repositories/drift_dashboard_repository.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/database_foundation/data/database/app_database.dart';
import '../../features/knowledge/data/repositories/drift_document_repository.dart';
import '../../features/knowledge/data/repositories/drift_knowledge_repository.dart';
import '../../features/knowledge/domain/repositories/document_repository.dart';
import '../../features/knowledge/domain/repositories/knowledge_repository.dart';
import '../../features/reminders/data/repositories/drift_reminder_repository.dart';
import '../../features/reminders/data/services/android_reminder_scheduler.dart';
import '../../features/reminders/domain/repositories/reminder_repository.dart';
import '../../features/reminders/domain/services/reminder_scheduler.dart';
import '../../features/search/data/repositories/drift_search_repository.dart';
import '../../features/search/data/services/android_voice_search_service.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/services/voice_search_service.dart';
import '../../features/security/data/repositories/drift_security_repository.dart';
import '../../features/security/data/services/android_security_platform.dart';
import '../../features/security/domain/repositories/security_repository.dart';
import '../../features/security/domain/services/security_platform.dart';
import '../../features/settings/data/repositories/drift_settings_repository.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/statistics/data/repositories/drift_statistics_repository.dart';
import '../../features/statistics/domain/repositories/statistics_repository.dart';
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
import '../security/authorization_gate.dart';

final appLoggerProvider = Provider<AppLogger>(
  (ref) => throw StateError('AppLogger override was not installed.'),
);

final databaseInitializerProvider = Provider<DatabaseInitializer>(
  (ref) => throw StateError('DatabaseInitializer override was not installed.'),
);

final androidDatabasePlatformProvider = Provider<AndroidDatabasePlatform>(
  (ref) => const AndroidDatabasePlatform(),
);

final backupPlatformProvider = Provider<BackupPlatform>(
  (ref) => const AndroidBackupPlatform(),
);

final securityPlatformProvider = Provider<SecurityPlatform>(
  (ref) => const AndroidSecurityPlatform(),
);

final authorizationGateProvider = Provider<AuthorizationGate>(
  (ref) => AuthorizationGate(),
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

final dashboardRepositoryProvider = FutureProvider<DashboardRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftDashboardRepository(database);
});

final calendarRepositoryProvider = FutureProvider<CalendarRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftCalendarRepository(database);
});

final searchRepositoryProvider = FutureProvider<SearchRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final session = await database.verifySearchSession();
  return DriftSearchRepository(
    session,
    authorizationGate: ref.watch(authorizationGateProvider),
  );
});

final statisticsRepositoryProvider = FutureProvider<StatisticsRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftStatisticsRepository(database);
});

final backupRepositoryProvider = FutureProvider<BackupRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final databasePlatform = ref.watch(androidDatabasePlatformProvider);
  return DriftBackupRepository(
    database,
    ref.watch(backupPlatformProvider),
    databasePlatform.databaseDirectory,
  );
});

final voiceSearchServiceProvider = Provider<VoiceSearchService>(
  (ref) => const AndroidVoiceSearchService(),
);

final securityRepositoryProvider = FutureProvider<SecurityRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftSecurityRepository(database);
});

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return DriftSettingsRepository(database);
});
