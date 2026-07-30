import 'package:anas_life_os/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the approved default seed and Material 3', () {
    final theme = AppTheme.light(seedColor: AppTheme.defaultSeedColor);

    expect(AppTheme.defaultSeedColor, const Color(0xFF3F51B5));
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.light);
  });

  test('high contrast themes expose maximum contrast', () {
    final theme = AppTheme.highContrastDark(
      seedColor: AppTheme.defaultSeedColor,
    );
    final standardTheme = AppTheme.dark(
      seedColor: AppTheme.defaultSeedColor,
    );

    expect(theme.brightness, Brightness.dark);
    expect(
      _contrastRatio(
        theme.colorScheme.surface,
        theme.colorScheme.onSurface,
      ),
      greaterThan(
        _contrastRatio(
          standardTheme.colorScheme.surface,
          standardTheme.colorScheme.onSurface,
        ),
      ),
    );
  });
}

double _contrastRatio(Color first, Color second) {
  final lighter = first.computeLuminance() > second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  final darker = first.computeLuminance() < second.computeLuminance()
      ? first.computeLuminance()
      : second.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}
