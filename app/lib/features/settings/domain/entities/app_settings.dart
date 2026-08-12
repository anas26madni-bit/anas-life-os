enum AppThemeSetting { system, light, dark }
enum AppLanguageSetting { system, en, ur }

final class AppSettings {
  const AppSettings({
    this.theme = AppThemeSetting.system,
    this.language = AppLanguageSetting.system,
    this.fontScalePercent = 100,
    this.accentColor = 0xFF3F51B5,
    this.useDynamicColor = true,
    this.reduceMotion = false,
  });

  final AppThemeSetting theme;
  final AppLanguageSetting language;
  final int fontScalePercent;
  final int accentColor;
  final bool useDynamicColor;
  final bool reduceMotion;

  AppSettings copyWith({
    AppThemeSetting? theme,
    AppLanguageSetting? language,
    int? fontScalePercent,
    int? accentColor,
    bool? useDynamicColor,
    bool? reduceMotion,
  }) => AppSettings(
    theme: theme ?? this.theme,
    language: language ?? this.language,
    fontScalePercent: fontScalePercent ?? this.fontScalePercent,
    accentColor: accentColor ?? this.accentColor,
    useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    reduceMotion: reduceMotion ?? this.reduceMotion,
  );
}
