import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../../domain/entities/project_entity.dart';
import '../controllers/project_controller.dart';

class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final projects = ref.watch(projectListControllerProvider);
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.projectsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProjectEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(localization.createProject),
      ),
      body: SafeArea(
        child: projects.when(
          loading: LoadingStateView.new,
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref
                .read(projectListControllerProvider.notifier)
                .refresh(),
          ),
          data: (items) => items.isEmpty
              ? ActionStateView(
                  icon: Icons.work_outline,
                  title: localization.noProjectsTitle,
                  message: localization.noProjectsMessage,
                  actionLabel: localization.createProject,
                  onAction: () => showProjectEditor(context, ref),
                )
              : RefreshIndicator(
                  onRefresh: ref
                      .read(projectListControllerProvider.notifier)
                      .refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      96,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final project = items[index];
                      return Card(
                        child: ListTile(
                          minTileHeight: 64,
                          leading: const Icon(Icons.work_outline),
                          title: Text(project.title),
                          subtitle: Text(
                            project.description?.trim().isNotEmpty == true
                                ? project.description!
                                : localization.noDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              ProjectDetailRoute(project.id).push<void>(context),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

Future<void> showProjectEditor(
  BuildContext context,
  WidgetRef ref, {
  ProjectEntity? initial,
}) async {
  final localization = AppLocalizations.of(context);
  final key = GlobalKey<FormState>();
  var title = initial?.title ?? '';
  var description = initial?.description ?? '';
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  initial == null
                      ? localization.createProject
                      : localization.editProject,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  initialValue: title,
                  autofocus: true,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: localization.projectTitle,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? localization.projectTitleRequired
                      : null,
                  onChanged: (value) => title = value,
                ),
                TextFormField(
                  initialValue: description,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: localization.description,
                  ),
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => key.currentState!.validate()
                      ? Navigator.pop(context, true)
                      : null,
                  child: Text(localization.save),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  if (saved == true && context.mounted) {
    final controller = ref.read(projectListControllerProvider.notifier);
    if (initial == null) {
      await controller.create(title: title, description: description);
    } else {
      await controller.update(
        initial.id,
        title: title,
        description: description,
        dueAt: initial.dueAt,
      );
    }
  }
}
