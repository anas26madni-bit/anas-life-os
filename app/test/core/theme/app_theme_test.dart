import 'package:anas_life_os/core/theme/app_theme.dart';
import 'package:anas_life_os/core/theme/semantic_colors.dart';
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
    final scheme = theme.colorScheme;
    final contrastRatio = _contrastRatio(scheme.surface, scheme.onSurface);

    expect(theme.brightness, Brightness.dark);
    expect(contrastRatio, greaterThanOrEqualTo(7));
  });

  test('applies one accessible modern color language to shared components', () {
    final theme = AppTheme.light(seedColor: AppTheme.defaultSeedColor);
    final scheme = theme.colorScheme;
    final semantic = theme.extension<SemanticColors>()!;

    expect(theme.scaffoldBackgroundColor, scheme.surface);
    expect(theme.cardTheme.color, scheme.surfaceContainerLow);
    expect(theme.navigationBarTheme.backgroundColor, scheme.surfaceContainer);
    expect(theme.inputDecorationTheme.fillColor, scheme.surfaceContainerLowest);
    expect(theme.dialogTheme.backgroundColor, scheme.surfaceContainerHigh);
    expect(
      _contrastRatio(semantic.success, semantic.onSuccess),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(semantic.warning, semantic.onWarning),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(semantic.info, semantic.onInfo),
      greaterThanOrEqualTo(4.5),
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
