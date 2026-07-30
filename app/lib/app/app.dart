import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../l10n/app_localizations.dart';

class AnasLifeOsApp extends ConsumerWidget {
  const AnasLifeOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreferences = ref.watch(themeControllerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final seedColor = themePreferences.seedColor;
        final lightScheme = themePreferences.useDynamicColor
            ? lightDynamic
            : null;
        final darkScheme = themePreferences.useDynamicColor
            ? darkDynamic
            : null;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          routerConfig: appRouter,
          theme: AppTheme.light(
            seedColor: seedColor,
            dynamicScheme: lightScheme,
          ),
          darkTheme: AppTheme.dark(
            seedColor: seedColor,
            dynamicScheme: darkScheme,
          ),
          highContrastTheme: AppTheme.highContrastLight(seedColor: seedColor),
          highContrastDarkTheme: AppTheme.highContrastDark(
            seedColor: seedColor,
          ),
          themeMode: themePreferences.mode,
          locale: themePreferences.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        );
      },
    );
  }
}
