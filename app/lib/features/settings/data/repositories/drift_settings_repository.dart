import 'package:drift/drift.dart';

import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

final class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._database, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _clock;

  @override
  Future<AppSettings> load() async {
    final row = await (_database.select(_database.systemSettings)
          ..where((table) => table.id.equals(1)))
        .getSingleOrNull();
    if (row == null) return const AppSettings();
    return AppSettings(
      theme: AppThemeSetting.values.byName(row.theme),
      language: AppLanguageSetting.values.byName(row.language),
      fontScalePercent: row.fontScalePercent,
      accentColor: row.accentColor,
      useDynamicColor: row.useDynamicColor,
      reduceMotion: row.reduceMotion,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final now = _clock().toUtc().microsecondsSinceEpoch;
    await _database.into(_database.systemSettings).insertOnConflictUpdate(
      SystemSettingsCompanion.insert(
        id: const Value(1),
        language: Value(settings.language.name),
        theme: Value(settings.theme.name),
        fontScalePercent: Value(settings.fontScalePercent.clamp(80, 200)),
        accentColor: Value(settings.accentColor),
        useDynamicColor: Value(settings.useDynamicColor),
        reduceMotion: Value(settings.reduceMotion),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
