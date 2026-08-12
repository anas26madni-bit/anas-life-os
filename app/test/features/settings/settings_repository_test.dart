import 'package:anas_life_os/features/settings/data/repositories/drift_settings_repository.dart';
import 'package:anas_life_os/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/database_test_harness.dart';

void main() {
  test('persists theme, language and accessibility settings', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final repository = DriftSettingsRepository(database, clock: () => DateTime.utc(2026));
    const settings = AppSettings(
      theme: AppThemeSetting.dark,
      language: AppLanguageSetting.ur,
      fontScalePercent: 150,
      useDynamicColor: false,
      reduceMotion: true,
    );

    await repository.save(settings);
    final loaded = await repository.load();

    expect(loaded.theme, AppThemeSetting.dark);
    expect(loaded.language, AppLanguageSetting.ur);
    expect(loaded.fontScalePercent, 150);
    expect(loaded.reduceMotion, isTrue);
  });
}
