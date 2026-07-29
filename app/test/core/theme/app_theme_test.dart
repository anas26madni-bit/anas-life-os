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

    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.contrastLevel, 1);
  });
}
