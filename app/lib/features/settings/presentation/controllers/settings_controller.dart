import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/infrastructure_providers.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../domain/entities/app_settings.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final settings = await (await ref.watch(
      settingsRepositoryProvider.future,
    )).load();
    _apply(settings);
    return settings;
  }

  Future<void> save(AppSettings settings) async {
    await (await ref.read(settingsRepositoryProvider.future)).save(settings);
    _apply(settings);
    state = AsyncData(settings);
  }

  void _apply(AppSettings settings) {
    final theme = ref.read(themeControllerProvider.notifier);
    theme.setMode(switch (settings.theme) {
      AppThemeSetting.system => ThemeMode.system,
      AppThemeSetting.light => ThemeMode.light,
      AppThemeSetting.dark => ThemeMode.dark,
    });
    theme.setLocale(switch (settings.language) {
      AppLanguageSetting.system => null,
      AppLanguageSetting.en => const Locale('en'),
      AppLanguageSetting.ur => const Locale('ur'),
    });
    theme.setAccessibility(
      fontScale: settings.fontScalePercent / 100,
      reduceMotion: settings.reduceMotion,
    );
    if (settings.useDynamicColor) {
      theme.setUseDynamicColor(true);
    } else {
      theme.setSeedColor(Color(settings.accentColor));
    }
  }
}
