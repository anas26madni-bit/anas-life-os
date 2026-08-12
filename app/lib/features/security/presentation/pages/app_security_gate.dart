import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/security_controller.dart';

class AppSecurityGate extends ConsumerStatefulWidget {
  const AppSecurityGate({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<AppSecurityGate> createState() => _AppSecurityGateState();
}

class _AppSecurityGateState extends ConsumerState<AppSecurityGate>
    with WidgetsBindingObserver {
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final security = ref.read(securityControllerProvider).value;
    if (security == null || !security.preferences.pinEnabled) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt = DateTime.now();
      if (security.preferences.autoLockEnabled &&
          security.preferences.timeoutSeconds == 0) {
        ref.read(securityControllerProvider.notifier).lock();
      }
    } else if (state == AppLifecycleState.resumed &&
        security.preferences.autoLockEnabled &&
        _backgroundedAt != null &&
        DateTime.now().difference(_backgroundedAt!).inSeconds >=
            security.preferences.timeoutSeconds) {
      ref.read(securityControllerProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = ref.watch(securityControllerProvider);
    return security.when(
      loading: () => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: const Center(child: CircularProgressIndicator.adaptive()),
      ),
      error: (error, stackTrace) =>
          ColoredBox(color: Theme.of(context).colorScheme.surface),
      data: (data) => data.isLocked
          ? _UnlockPage(
              biometricEnabled:
                  data.preferences.biometricEnabled &&
                  data.nativeStatus.biometricAvailable,
            )
          : widget.child,
    );
  }
}

class _UnlockPage extends ConsumerStatefulWidget {
  const _UnlockPage({required this.biometricEnabled});
  final bool biometricEnabled;

  @override
  ConsumerState<_UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends ConsumerState<_UnlockPage> {
  final _pin = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 64),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.appLocked,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.unlockMessage, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _pin,
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: l10n.enterPin,
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _unlock(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _busy ? null : _unlock,
                        child: Text(l10n.unlock),
                      ),
                    ),
                    if (widget.biometricEnabled) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _busy ? null : _biometric,
                          icon: const Icon(Icons.fingerprint),
                          label: Text(l10n.useBiometric),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(securityControllerProvider.notifier)
        .unlockWithPin(_pin.text);
    if (!mounted || result.success) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = false;
      _error = result.cooldownSeconds > 0
          ? l10n.cooldownMessage(result.cooldownSeconds)
          : l10n.invalidPin;
    });
  }

  Future<void> _biometric() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(securityControllerProvider.notifier)
        .unlockWithBiometric(
          title: l10n.biometricPromptTitle,
          subtitle: l10n.biometricPromptSubtitle,
          cancelLabel: l10n.usePin,
        );
    if (!mounted || result.success) return;
    setState(() {
      _busy = false;
      _error = l10n.invalidPin;
    });
  }
}
