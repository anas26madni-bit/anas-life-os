import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'semantic_colors.dart';

abstract final class AppTheme {
  static const Color defaultSeedColor = Color(0xFF3F51B5);

  static ThemeData light({
    required Color seedColor,
    ColorScheme? dynamicScheme,
  }) {
    return _build(
      dynamicScheme ??
          ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          ),
    );
  }

  static ThemeData dark({
    required Color seedColor,
    ColorScheme? dynamicScheme,
  }) {
    return _build(
      dynamicScheme ??
          ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          ),
    );
  }

  static ThemeData highContrastLight({required Color seedColor}) {
    return _build(
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        contrastLevel: 1,
      ),
    );
  }

  static ThemeData highContrastDark({required Color seedColor}) {
    return _build(
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
        contrastLevel: 1,
      ),
    );
  }

  static ThemeData _build(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppRadius.medium);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
      extensions: [
        SemanticColors(
          success: isDark ? const Color(0xFF7DDA91) : const Color(0xFF176B37),
          onSuccess: isDark ? const Color(0xFF003916) : Colors.white,
          warning: isDark ? const Color(0xFFFFB95C) : const Color(0xFF815500),
          onWarning: isDark ? const Color(0xFF452B00) : Colors.white,
          info: isDark ? const Color(0xFF9CCAFF) : const Color(0xFF165D9B),
          onInfo: isDark ? const Color(0xFF003258) : Colors.white,
        ),
      ],
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: radius),
        filled: true,
      ),
    );
  }
}
