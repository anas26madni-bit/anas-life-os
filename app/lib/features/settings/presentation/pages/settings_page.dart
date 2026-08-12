import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../domain/entities/app_settings.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      appBar: AppTopBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: settings.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, stackTrace) =>
              Center(child: Text(l10n.securityOperationFailed)),
          data: (value) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SectionTitle(l10n.appearance),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(l10n.themeSetting),
                      trailing: DropdownButton<AppThemeSetting>(
                        value: value.theme,
                        items: [
                          DropdownMenuItem(
                            value: AppThemeSetting.system,
                            child: Text(l10n.systemDefault),
                          ),
                          DropdownMenuItem(
                            value: AppThemeSetting.light,
                            child: Text(l10n.lightTheme),
                          ),
                          DropdownMenuItem(
                            value: AppThemeSetting.dark,
                            child: Text(l10n.darkTheme),
                          ),
                        ],
                        onChanged: (theme) async {
                          if (theme != null) {
                            await _save(ref, value.copyWith(theme: theme));
                          }
                        },
                      ),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.color_lens_outlined),
                      title: Text(l10n.dynamicColor),
                      value: value.useDynamicColor,
                      onChanged: (enabled) =>
                          _save(ref, value.copyWith(useDynamicColor: enabled)),
                    ),
                    ListTile(
                      title: Text(l10n.languageSetting),
                      trailing: DropdownButton<AppLanguageSetting>(
                        value: value.language,
                        items: [
                          DropdownMenuItem(
                            value: AppLanguageSetting.system,
                            child: Text(l10n.systemDefault),
                          ),
                          DropdownMenuItem(
                            value: AppLanguageSetting.en,
                            child: Text(l10n.english),
                          ),
                          DropdownMenuItem(
                            value: AppLanguageSetting.ur,
                            child: Text(l10n.urdu),
                          ),
                        ],
                        onChanged: (language) async {
                          if (language != null) {
                            await _save(
                              ref,
                              value.copyWith(language: language),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionTitle(l10n.accessibilitySettings),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(l10n.fontScale),
                      subtitle: Slider(
                        value: value.fontScalePercent.toDouble(),
                        min: 80,
                        max: 200,
                        divisions: 12,
                        label: '${value.fontScalePercent}%',
                        onChanged: (scale) => _save(
                          ref,
                          value.copyWith(fontScalePercent: scale.round()),
                        ),
                      ),
                      trailing: Text('${value.fontScalePercent}%'),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.motion_photos_off_outlined),
                      title: Text(l10n.reduceMotion),
                      value: value.reduceMotion,
                      onChanged: (enabled) =>
                          _save(ref, value.copyWith(reduceMotion: enabled)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionTitle(l10n.aboutTitle),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.appVersionLabel),
                  subtitle: Text(l10n.privacySummary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(WidgetRef ref, AppSettings settings) =>
      ref.read(settingsControllerProvider.notifier).save(settings);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(
      start: AppSpacing.sm,
      bottom: AppSpacing.xs,
    ),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
