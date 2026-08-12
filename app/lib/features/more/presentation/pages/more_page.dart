import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.moreTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _DestinationCard(
              icon: Icons.work_outline,
              title: localization.projectsTitle,
              onTap: () => const ProjectsRoute().go(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DestinationCard(
              icon: Icons.notifications_active_outlined,
              title: localization.remindersTitle,
              onTap: () => const RemindersRoute().go(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DestinationCard(
              icon: Icons.folder_copy_outlined,
              title: localization.documentsTitle,
              onTap: () => const DocumentsRoute().go(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DestinationCard(
              icon: Icons.insights_outlined,
              title: localization.statisticsTitle,
              onTap: () => const StatisticsRoute().go(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DestinationCard(
              icon: Icons.backup_outlined,
              title: localization.backupTitle,
              onTap: () => const BackupRoute().go(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DestinationCard(
              icon: Icons.security_outlined,
              title: localization.securityTitle,
              onTap: () => const SecurityRoute().go(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DestinationCard(
              icon: Icons.settings_outlined,
              title: localization.settingsTitle,
              onTap: () => const SettingsRoute().go(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minTileHeight: 64,
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(
        Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left
            : Icons.chevron_right,
      ),
      onTap: onTap,
    ),
  );
}
