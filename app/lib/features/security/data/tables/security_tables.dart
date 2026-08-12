import 'package:drift/drift.dart';

class SecuritySettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get pinEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get biometricEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get autoLockEnabled =>
      boolean().withDefault(const Constant(true))();
  IntColumn get appLockTimeoutSeconds =>
      integer().withDefault(const Constant(0))();
  BoolColumn get hiddenItemsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get encryptSensitiveData =>
      boolean().withDefault(const Constant(true))();
  IntColumn get failedAttemptLimit =>
      integer().withDefault(const Constant(5))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (id = 1)',
    'CHECK (app_lock_timeout_seconds >= 0 AND app_lock_timeout_seconds <= 3600)',
    'CHECK (failed_attempt_limit = 5)',
  ];
}

@TableIndex(name: 'idx_app_lock_sessions_created', columns: {#createdAt})
class AppLockSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36)();
  IntColumn get sessionStart => integer()();
  IntColumn get sessionEnd => integer().nullable()();
  TextColumn get unlockMethod => text().withLength(min: 3, max: 20)();
  BoolColumn get success => boolean()();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  IntColumn get deviceTime => integer()();
  IntColumn get createdAt => integer()();
}

@TableIndex(name: 'idx_security_audit_created', columns: {#createdAt})
class SecurityAuditLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36)();
  TextColumn get action => text().withLength(min: 3, max: 80)();
  BoolColumn get success => boolean()();
  TextColumn get safeDetail => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()();
}

class SystemSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get language => text().withDefault(const Constant('system'))();
  TextColumn get theme => text().withDefault(const Constant('system'))();
  IntColumn get fontScalePercent => integer().withDefault(const Constant(100))();
  IntColumn get accentColor => integer().withDefault(const Constant(4282339765))();
  BoolColumn get useDynamicColor =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get reduceMotion => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (id = 1)',
    'CHECK (language IN (\'system\',\'en\',\'ur\'))',
    'CHECK (theme IN (\'system\',\'light\',\'dark\'))',
    'CHECK (font_scale_percent BETWEEN 80 AND 200)',
  ];
}
