import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemePreferences>(ThemeController.new);

@immutable
class ThemePreferences {
  const ThemePreferences({
    this.mode = ThemeMode.system,
    this.seedColor = AppTheme.defaultSeedColor,
    this.useDynamicColor = true,
    this.locale,
  });

  final ThemeMode mode;
  final Color seedColor;
  final bool useDynamicColor;
  final Locale? locale;

  ThemePreferences copyWith({
    ThemeMode? mode,
    Color? seedColor,
    bool? useDynamicColor,
    Locale? locale,
    bool clearLocale = false,
  }) {
    return ThemePreferences(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      locale: clearLocale ? null : locale ?? this.locale,
    );
  }
}

class ThemeController extends Notifier<ThemePreferences> {
  @override
  ThemePreferences build() => const ThemePreferences();

  void setLocale(Locale? locale) {
    state = state.copyWith(locale: locale, clearLocale: locale == null);
  }

  void setMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setSeedColor(Color seedColor) {
    state = state.copyWith(seedColor: seedColor, useDynamicColor: false);
  }

  void setUseDynamicColor(bool enabled) {
    state = state.copyWith(useDynamicColor: enabled);
  }
}
