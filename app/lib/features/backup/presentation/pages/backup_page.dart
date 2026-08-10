import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../domain/entities/backup_models.dart';
import '../controllers/backup_controller.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(backupControllerProvider);
    return Scaffold(
      appBar: AppTopBar(title: Text(l10n.backupTitle)),
      body: SafeArea(
        child: state.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, _) => _ErrorState(
            message: error.toString(),
            onRetry: ref.read(backupControllerProvider.notifier).refresh,
          ),
          data: (data) => RefreshIndicator(
            onRefresh: ref.read(backupControllerProvider.notifier).refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _ActionsCard(
                  onBackup: () => _manualBackup(context, ref),
                  onRestore: () => _restore(context, ref),
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsCard(settings: data.settings),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.backupHistory,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (data.history.isEmpty)
                  _EmptyHistory(message: l10n.noBackupsMessage)
                else
                  ...data.history.map((record) => _HistoryTile(record: record)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _manualBackup(BuildContext context, WidgetRef ref) async {
    final passphrase = await _passphrase(context, confirm: true);
    if (passphrase == null || !context.mounted) return;
    final destination = await ref
        .read(backupControllerProvider.notifier)
        .selectDestination();
    if (destination == null) return;
    await ref
        .read(backupControllerProvider.notifier)
        .manualBackup(destination, passphrase);
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.restoreBackup),
        content: Text(l10n.restoreWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.continueLabel),
          ),
        ],
      ),
    );
    if (approved != true || !context.mounted) return;
    final passphrase = await _passphrase(context);
    if (passphrase != null) {
      await ref
          .read(backupControllerProvider.notifier)
          .importAndRestore(passphrase);
    }
  }

  Future<String?> _passphrase(
    BuildContext context, {
    bool confirm = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    var first = '';
    var second = '';
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupPassphrase),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autofocus: true,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(labelText: l10n.backupPassphrase),
                onChanged: (value) => first = value,
                validator: (value) => value == null || value.isEmpty
                    ? l10n.backupPassphraseRequired
                    : null,
              ),
              if (confirm) ...[
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassphrase,
                  ),
                  onChanged: (value) => second = value,
                  validator: (_) =>
                      first == second ? null : l10n.passphrasesDoNotMatch,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate())
                Navigator.pop(dialogContext, first);
            },
            child: Text(l10n.continueLabel),
          ),
        ],
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.onBackup, required this.onRestore});
  final VoidCallback onBackup;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            FilledButton.icon(
              onPressed: onBackup,
              icon: const Icon(Icons.backup_outlined),
              label: Text(l10n.manualBackup),
            ),
            OutlinedButton.icon(
              onPressed: onRestore,
              icon: const Icon(Icons.restore_outlined),
              label: Text(l10n.importAndRestore),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends ConsumerStatefulWidget {
  const _SettingsCard({required this.settings});
  final BackupSettings settings;

  @override
  ConsumerState<_SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends ConsumerState<_SettingsCard> {
  late bool enabled = widget.settings.automaticEnabled;
  late BackupFrequency frequency = widget.settings.frequency;
  late int retention = widget.settings.retentionCount;
  late String? destination = widget.settings.destinationUri;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.automaticBackup,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.enableAutomaticBackup),
              value: enabled,
              onChanged: (value) => setState(() => enabled = value),
            ),
            DropdownButtonFormField<BackupFrequency>(
              initialValue: frequency,
              decoration: InputDecoration(labelText: l10n.backupFrequency),
              items: BackupFrequency.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        value == BackupFrequency.daily
                            ? l10n.daily
                            : l10n.weekly,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => frequency = value!),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              initialValue: '$retention',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: l10n.backupRetention),
              onChanged: (value) => retention = int.tryParse(value) ?? 7,
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.folder_outlined),
              title: Text(l10n.backupDestination),
              subtitle: Text(
                destination == null
                    ? l10n.destinationNotSelected
                    : l10n.destinationSelected,
              ),
              onTap: () async {
                final selected = await ref
                    .read(backupControllerProvider.notifier)
                    .selectDestination();
                if (selected != null) setState(() => destination = selected);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () async {
                final passphrase = enabled
                    ? await const BackupPage()._passphrase(
                        context,
                        confirm: true,
                      )
                    : '';
                if (enabled && passphrase == null) return;
                await ref
                    .read(backupControllerProvider.notifier)
                    .saveSettings(
                      BackupSettings(
                        automaticEnabled: enabled,
                        frequency: frequency,
                        retentionCount: retention,
                        destinationUri: destination,
                      ),
                      passphrase ?? '',
                    );
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});
  final BackupRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: Icon(
          record.status == BackupOperationStatus.succeeded
              ? Icons.verified_outlined
              : Icons.error_outline,
        ),
        title: Text(record.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          MaterialLocalizations.of(context).formatFullDate(record.startedAt),
        ),
        trailing: Text(
          record.status == BackupOperationStatus.succeeded
              ? l10n.backupSucceeded
              : l10n.backupFailed,
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    label: message,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.history_toggle_off_outlined, size: 64),
          const SizedBox(height: AppSpacing.md),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
