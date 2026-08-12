import 'package:anas_life_os/core/providers/infrastructure_providers.dart';
import 'package:anas_life_os/core/theme/theme_controller.dart';
import 'package:anas_life_os/features/settings/domain/entities/app_settings.dart';
import 'package:anas_life_os/features/settings/domain/repositories/settings_repository.dart';
import 'package:anas_life_os/features/settings/presentation/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and applies persisted app settings then saves changes', () async {
    final repository = _SettingsRepository();
    final container = ProviderContainer(overrides: [
      settingsRepositoryProvider.overrideWith((ref) async => repository),
    ]);
    addTearDown(container.dispose);
    final loaded = await container.read(settingsControllerProvider.future);
    expect(loaded.language, AppLanguageSetting.ur);
    var theme = container.read(themeControllerProvider);
    expect(theme.mode, ThemeMode.dark);
    expect(theme.locale, const Locale('ur'));
    expect(theme.fontScale, 1.5);
    expect(theme.reduceMotion, isTrue);

    const updated = AppSettings(
      theme: AppThemeSetting.light,
      language: AppLanguageSetting.en,
      fontScalePercent: 120,
      useDynamicColor: true,
    );
    await container.read(settingsControllerProvider.notifier).save(updated);
    theme = container.read(themeControllerProvider);
    expect(repository.value, updated);
    expect(theme.mode, ThemeMode.light);
    expect(theme.locale, const Locale('en'));
    expect(theme.useDynamicColor, isTrue);
  });
}

final class _SettingsRepository implements SettingsRepository {
  AppSettings value = const AppSettings(
    theme: AppThemeSetting.dark,
    language: AppLanguageSetting.ur,
    fontScalePercent: 150,
    useDynamicColor: false,
    reduceMotion: true,
  );
  @override Future<AppSettings> load() async => value;
  @override Future<void> save(AppSettings settings) async { value = settings; }
}
