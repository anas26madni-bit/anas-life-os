import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      label: MaterialLocalizations.of(context).alertDialogLabel,
      child: const CircularProgressIndicator.adaptive(),
    ),
  );
}

class ActionStateView extends StatelessWidget {
  const ActionStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(AppSpacing.xl),
    children: [
      const SizedBox(height: AppSpacing.xl),
      Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: AppSpacing.lg),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(message, textAlign: TextAlign.center),
      if (actionLabel != null && onAction != null) ...[
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh),
            label: Text(actionLabel!),
          ),
        ),
      ],
    ],
  );
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ActionStateView(
    icon: Icons.error_outline,
    title: AppLocalizations.of(context).unavailableTitle,
    message: message,
    actionLabel: AppLocalizations.of(context).retry,
    onAction: onRetry,
  );
}
