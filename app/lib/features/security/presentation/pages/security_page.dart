import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../controllers/security_controller.dart';
import '../../domain/entities/security_models.dart';

class SecurityPage extends ConsumerWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final security = ref.watch(securityControllerProvider);
    return Scaffold(
      appBar: AppTopBar(title: Text(l10n.securityTitle)),
      body: SafeArea(
        child: security.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, stackTrace) =>
              Center(child: Text(l10n.securityOperationFailed)),
          data: (state) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(l10n.securityFailClosed),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.pin_outlined),
                      title: Text(
                        state.preferences.pinEnabled
                            ? l10n.changePin
                            : l10n.configurePin,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _pinDialog(
                        context,
                        ref,
                        change: state.preferences.pinEnabled,
                      ),
                    ),
                    if (state.preferences.pinEnabled)
                      ListTile(
                        leading: const Icon(Icons.lock_open_outlined),
                        title: Text(l10n.disablePin),
                        onTap: () => _disableDialog(context, ref),
                      ),
                  ],
                ),
              ),
              if (state.preferences.pinEnabled) ...[
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.fingerprint),
                        title: Text(l10n.biometricLock),
                        subtitle: state.nativeStatus.biometricAvailable
                            ? null
                            : Text(l10n.biometricUnavailable),
                        value:
                            state.preferences.biometricEnabled &&
                            state.nativeStatus.biometricAvailable,
                        onChanged: state.nativeStatus.biometricAvailable
                            ? (value) => _update(
                                ref,
                                state.preferences.copyWith(
                                  biometricEnabled: value,
                                ),
                              )
                            : null,
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.timer_outlined),
                        title: Text(l10n.autoLock),
                        value: state.preferences.autoLockEnabled,
                        onChanged: (value) => _update(
                          ref,
                          state.preferences.copyWith(autoLockEnabled: value),
                        ),
                      ),
                      ListTile(
                        title: Text(l10n.autoLockTimeout),
                        trailing: DropdownButton<int>(
                          value: state.preferences.timeoutSeconds,
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text(l10n.immediately),
                            ),
                            DropdownMenuItem(
                              value: 30,
                              child: Text(l10n.seconds30),
                            ),
                            DropdownMenuItem(
                              value: 60,
                              child: Text(l10n.minute1),
                            ),
                            DropdownMenuItem(
                              value: 300,
                              child: Text(l10n.minutes5),
                            ),
                            DropdownMenuItem(
                              value: 900,
                              child: Text(l10n.minutes15),
                            ),
                          ],
                          onChanged: state.preferences.autoLockEnabled
                              ? (value) {
                                  if (value != null)
                                    _update(
                                      ref,
                                      state.preferences.copyWith(
                                        timeoutSeconds: value,
                                      ),
                                    );
                                }
                              : null,
                        ),
                      ),
                      SwitchListTile(
                        secondary: const Icon(Icons.visibility_off_outlined),
                        title: Text(l10n.hiddenItemsProtection),
                        value: state.preferences.hiddenItemsEnabled,
                        onChanged: (value) => _update(
                          ref,
                          state.preferences.copyWith(hiddenItemsEnabled: value),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _update(WidgetRef ref, SecurityPreferences preferences) => ref
      .read(securityControllerProvider.notifier)
      .updatePreferences(preferences);

  Future<void> _pinDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool change,
  }) async {
    final l10n = AppLocalizations.of(context);
    final current = TextEditingController();
    final pin = TextEditingController();
    final confirm = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(change ? l10n.changePin : l10n.configurePin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (change)
              TextField(
                controller: current,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.currentPin),
              ),
            TextField(
              controller: pin,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.newPin,
                helperText: l10n.pinMinimum,
              ),
            ),
            TextField(
              controller: confirm,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.confirmPin),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (pin.text != confirm.text) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.pinsDoNotMatch)));
                return;
              }
              final ok = change
                  ? await ref
                        .read(securityControllerProvider.notifier)
                        .changePin(current.text, pin.text)
                  : await ref
                        .read(securityControllerProvider.notifier)
                        .configurePin(pin.text);
              if (dialogContext.mounted && ok) Navigator.pop(dialogContext);
              if (context.mounted && !ok)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.securityOperationFailed)),
                );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    current.dispose();
    pin.dispose();
    confirm.dispose();
  }

  Future<void> _disableDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final pin = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.disablePin),
        content: TextField(
          controller: pin,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.currentPin),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await ref
                  .read(securityControllerProvider.notifier)
                  .disablePin(pin.text);
              if (dialogContext.mounted && ok) Navigator.pop(dialogContext);
              if (context.mounted && !ok)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.securityOperationFailed)),
                );
            },
            child: Text(l10n.disable),
          ),
        ],
      ),
    );
    pin.dispose();
  }
}
