import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../../domain/entities/search_models.dart';
import '../../domain/services/voice_search_service.dart';
import '../controllers/search_controller.dart';

class UniversalSearchPage extends ConsumerStatefulWidget {
  const UniversalSearchPage({super.key});

  @override
  ConsumerState<UniversalSearchPage> createState() =>
      _UniversalSearchPageState();
}

class _UniversalSearchPageState extends ConsumerState<UniversalSearchPage> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final search = ref.watch(universalSearchControllerProvider);
    ref.listen(universalSearchControllerProvider, (previous, next) {
      final queryText = next.value?.query.text;
      if (queryText != null && queryText != _textController.text) {
        _textController.value = TextEditingValue(
          text: queryText,
          selection: TextSelection.collapsed(offset: queryText.length),
        );
      }
      if (next.value?.voiceUnavailable == true &&
          previous?.value?.voiceUnavailable != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localization.voiceSearchUnavailable)),
        );
      }
    });
    return Scaffold(
      appBar: AppTopBar(
        title: Text(localization.searchTitle),
        showSearch: false,
        actions: [
          IconButton(
            tooltip: localization.searchFilters,
            onPressed: search.hasValue
                ? () => _showFilters(context, search.requireValue.query)
                : null,
            icon: const Icon(Icons.filter_alt_outlined),
          ),
          IconButton(
            tooltip: localization.saveSearch,
            onPressed: search.hasValue ? () => _saveSearch(context) : null,
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: SearchBar(
                controller: _textController,
                hintText: localization.searchHint,
                leading: const Icon(Icons.search),
                trailing: [
                  PopupMenuButton<VoiceSearchLocale>(
                    tooltip: localization.voiceSearchEnglish,
                    icon: const Icon(Icons.mic_none),
                    onSelected: ref
                        .read(universalSearchControllerProvider.notifier)
                        .listen,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: VoiceSearchLocale.english,
                        child: Text(localization.voiceSearchEnglish),
                      ),
                      PopupMenuItem(
                        value: VoiceSearchLocale.urdu,
                        child: Text(localization.voiceSearchUrdu),
                      ),
                    ],
                  ),
                ],
                onChanged: ref
                    .read(universalSearchControllerProvider.notifier)
                    .scheduleText,
                onSubmitted: (text) async {
                  final current = search.value?.query ?? const SearchQuery();
                  await ref
                      .read(universalSearchControllerProvider.notifier)
                      .execute(current.copyWith(text: text));
                },
              ),
            ),
            if (search case AsyncData(:final value)) ...[
              _SearchShortcuts(state: value),
              _SearchControls(state: value),
            ],
            Expanded(
              child: search.when(
                loading: LoadingStateView.new,
                error: (error, stackTrace) => ErrorStateView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(
                    universalSearchControllerProvider,
                  ),
                ),
                data: (state) => state.results.isEmpty
                    ? _SearchMessage(
                        icon: Icons.manage_search,
                        title: localization.noSearchResults,
                        message: localization.noSearchResultsMessage,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.xl,
                        ),
                        itemCount: state.results.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (context, index) =>
                            _ResultCard(item: state.results[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSearch(BuildContext context) async {
    final localization = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    var name = '';
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localization.saveSearch),
        content: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: localization.savedSearchName,
            ),
            onChanged: (value) => name = value,
            validator: (value) => value == null || value.trim().isEmpty
                ? localization.savedSearchName
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(localization.cancel),
          ),
          FilledButton(
            onPressed: () => formKey.currentState!.validate()
                ? Navigator.pop(dialogContext, true)
                : null,
            child: Text(localization.save),
          ),
        ],
      ),
    );
    if (saved == true) {
      await ref
          .read(universalSearchControllerProvider.notifier)
          .saveCurrent(name);
    }
  }

  Future<void> _showFilters(BuildContext context, SearchQuery initial) async {
    final localization = AppLocalizations.of(context);
    var query = initial;
    var projectText = initial.projectId?.toString() ?? '';
    var tagText = initial.tags.join(', ');
    final selected = await showModalBottomSheet<SearchQuery>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localization.searchFilters,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: SearchEntityType.values
                        .map((type) {
                          return FilterChip(
                            label: Text(_entityLabel(localization, type)),
                            selected: query.entityTypes.contains(type),
                            onSelected: (active) => setState(() {
                              final types = {...query.entityTypes};
                              active ? types.add(type) : types.remove(type);
                              query = query.copyWith(entityTypes: types);
                            }),
                          );
                        })
                        .toList(growable: false),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: projectText),
                    decoration: InputDecoration(
                      labelText: localization.searchProjectId,
                    ),
                    onChanged: (value) => projectText = value,
                  ),
                  TextField(
                    controller: TextEditingController(text: tagText),
                    decoration: InputDecoration(
                      labelText: localization.searchTags,
                    ),
                    onChanged: (value) => tagText = value,
                  ),
                  _DateFilterTile(
                    label: localization.searchFromDate,
                    date: query.dateFrom,
                    onChanged: (date) =>
                        setState(() => query = query.copyWith(dateFrom: date)),
                  ),
                  _DateFilterTile(
                    label: localization.searchToDate,
                    date: query.dateTo,
                    onChanged: (date) =>
                        setState(() => query = query.copyWith(dateTo: date)),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          initial.copyWith(
                            entityTypes: const {},
                            tags: const [],
                            clearDates: true,
                            clearProject: true,
                          ),
                        ),
                        child: Text(localization.clearFilters),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          query.copyWith(
                            projectId: int.tryParse(projectText),
                            clearProject: projectText.trim().isEmpty,
                            tags: tagText
                                .split(',')
                                .map((tag) => tag.trim())
                                .where((tag) => tag.isNotEmpty)
                                .toList(growable: false),
                          ),
                        ),
                        child: Text(localization.applyFilters),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (selected != null) {
      await ref
          .read(universalSearchControllerProvider.notifier)
          .execute(selected);
    }
  }
}

class _SearchShortcuts extends ConsumerWidget {
  const _SearchShortcuts({required this.state});
  final UniversalSearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.recent.isEmpty && state.saved.isEmpty) {
      return const SizedBox(height: AppSpacing.sm);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          for (final saved in state.saved)
            InputChip(
              avatar: const Icon(Icons.bookmark_outline, size: 18),
              label: Text(saved.name),
              onPressed: () => ref
                  .read(universalSearchControllerProvider.notifier)
                  .execute(saved.query),
              onDeleted: () => ref
                  .read(universalSearchControllerProvider.notifier)
                  .deleteSaved(saved.id),
            ),
          for (final recent in state.recent.take(5))
            if (recent.query.text.isNotEmpty)
              ActionChip(
                avatar: const Icon(Icons.history, size: 18),
                label: Text(recent.query.text),
                onPressed: () => ref
                    .read(universalSearchControllerProvider.notifier)
                    .execute(recent.query),
              ),
        ],
      ),
    );
  }
}

class _SearchControls extends ConsumerWidget {
  const _SearchControls({required this.state});
  final UniversalSearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DropdownButtonFormField<SearchSortMode>(
        initialValue: state.query.sortMode,
        decoration: InputDecoration(labelText: localization.searchSort),
        items: SearchSortMode.values
            .map(
              (mode) => DropdownMenuItem(
                value: mode,
                child: Text(_sortLabel(localization, mode)),
              ),
            )
            .toList(growable: false),
        onChanged: (mode) => mode == null
            ? null
            : ref
                  .read(universalSearchControllerProvider.notifier)
                  .execute(state.query.copyWith(sortMode: mode)),
      ),
    );
  }
}

class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.item});
  final SearchResultItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
    child: ListTile(
      leading: Icon(_entityIcon(item.entityType)),
      title: Text(item.title),
      subtitle: item.summary == null ? null : Text(item.summary!, maxLines: 2),
      trailing: Text(DateFormat.yMMMd().format(item.updatedAt.toLocal())),
      onTap: () => _openResult(context, ref),
    ),
  );

  Future<void> _openResult(BuildContext context, WidgetRef ref) async {
    switch (item.entityType) {
      case SearchEntityType.task:
        return TaskDetailRoute(item.entityId).go(context);
      case SearchEntityType.project:
        return ProjectDetailRoute(item.entityId).go(context);
      case SearchEntityType.note:
        return KnowledgeDetailRoute(item.entityId).go(context);
      case SearchEntityType.document:
        return DocumentDetailRoute(item.entityId).go(context);
      case SearchEntityType.attachment:
        final repository = await ref.read(taskSupportRepositoryProvider.future);
        final result = await repository.attachmentTarget(item.entityId);
        if (!context.mounted) return;
        final target = switch (result) {
          Success(:final value) => value,
          FailureResult(:final failure) => throw StateError(failure.safeMessage),
        };
        if (target?.taskId != null) {
          return TaskDetailRoute(target!.taskId!).go(context);
        }
        if (target?.projectId != null) {
          return ProjectDetailRoute(target!.projectId!).go(context);
        }
        if (target?.knowledgeNoteId != null) {
          return KnowledgeDetailRoute(target!.knowledgeNoteId!).go(context);
        }
        if (target?.documentId != null) {
          return DocumentDetailRoute(target!.documentId!).go(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).sourceUnavailable)),
        );
    }
  }
}

class _DateFilterTile extends StatelessWidget {
  const _DateFilterTile({
    required this.label,
    required this.date,
    required this.onChanged,
  });
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: date == null ? null : Text(DateFormat.yMMMd().format(date!)),
    trailing: const Icon(Icons.date_range),
    onTap: () async {
      final selected = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: date ?? DateTime.now(),
      );
      if (selected != null) onChanged(selected);
    },
  );
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 64),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

String _entityLabel(AppLocalizations localization, SearchEntityType type) =>
    switch (type) {
      SearchEntityType.task => localization.searchTasks,
      SearchEntityType.project => localization.searchProjects,
      SearchEntityType.note => localization.searchNotes,
      SearchEntityType.document => localization.searchDocuments,
      SearchEntityType.attachment => localization.searchAttachments,
    };

String _sortLabel(AppLocalizations localization, SearchSortMode mode) =>
    switch (mode) {
      SearchSortMode.relevance => localization.searchRelevance,
      SearchSortMode.newest => localization.searchNewest,
      SearchSortMode.oldest => localization.searchOldest,
      SearchSortMode.title => localization.searchTitleSort,
    };

IconData _entityIcon(SearchEntityType type) => switch (type) {
  SearchEntityType.task => Icons.task_alt,
  SearchEntityType.project => Icons.work_outline,
  SearchEntityType.note => Icons.notes,
  SearchEntityType.document => Icons.description_outlined,
  SearchEntityType.attachment => Icons.attach_file,
};
