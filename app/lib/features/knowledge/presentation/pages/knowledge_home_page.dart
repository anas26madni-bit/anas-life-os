import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/knowledge_enums.dart';
import '../../domain/entities/knowledge_note.dart';
import '../controllers/knowledge_controller.dart';

class KnowledgeHomePage extends ConsumerWidget {
  const KnowledgeHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final notes = ref.watch(knowledgeListControllerProvider);
    ref.listen(knowledgeListControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.knowledgeTitle),
        actions: [
          IconButton(
            tooltip: localization.documentsTitle,
            onPressed: () => const DocumentsRoute().go(context),
            icon: const Icon(Icons.folder_copy_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ref),
        icon: const Icon(Icons.note_add_outlined),
        label: Text(localization.createNote),
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
                hintText: localization.searchKnowledge,
                leading: const Icon(Icons.search),
                onSubmitted: ref
                    .read(knowledgeListControllerProvider.notifier)
                    .search,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: SegmentedButton<KnowledgeNoteType?>(
                segments: [
                  ButtonSegment(value: null, label: Text(localization.allNotes)),
                  ButtonSegment(
                    value: KnowledgeNoteType.note,
                    label: Text(localization.notesLabel),
                  ),
                  ButtonSegment(
                    value: KnowledgeNoteType.journal,
                    label: Text(localization.journalLabel),
                  ),
                  ButtonSegment(
                    value: KnowledgeNoteType.wiki,
                    label: Text(localization.wikiLabel),
                  ),
                ],
                selected: const {null},
                onSelectionChanged: (value) => ref
                    .read(knowledgeListControllerProvider.notifier)
                    .filter(value.first),
              ),
            ),
            Expanded(
              child: notes.when(
                loading: () => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                error: (error, stackTrace) => _KnowledgeMessage(
                  icon: Icons.error_outline,
                  title: localization.knowledgeErrorTitle,
                  message: error.toString(),
                ),
                data: (items) => items.isEmpty
                    ? _KnowledgeMessage(
                        icon: Icons.auto_stories_outlined,
                        title: localization.noKnowledgeTitle,
                        message: localization.noKnowledgeMessage,
                      )
                    : RefreshIndicator(
                        onRefresh: ref
                            .read(knowledgeListControllerProvider.notifier)
                            .refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            96,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) => _KnowledgeCard(
                            note: items[index],
                            onFavorite: () => ref
                                .read(knowledgeListControllerProvider.notifier)
                                .setFavorite(
                                  items[index].id,
                                  !items[index].favorite,
                                ),
                            onDelete: () => ref
                                .read(knowledgeListControllerProvider.notifier)
                                .delete(items[index].id),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditor(BuildContext context, WidgetRef ref) async {
    final localization = AppLocalizations.of(context);
    final formKey = GlobalKey<FormState>();
    var title = '';
    var content = '';
    var type = KnowledgeNoteType.note;
    var format = KnowledgeContentFormat.richText;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(localization.createNote),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      autofocus: true,
                      maxLength: 300,
                      decoration: InputDecoration(
                        labelText: localization.noteTitle,
                      ),
                      onChanged: (value) => title = value,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? localization.noteTitleRequired
                          : null,
                    ),
                    DropdownButtonFormField<KnowledgeNoteType>(
                      initialValue: type,
                      decoration: InputDecoration(
                        labelText: localization.noteType,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: KnowledgeNoteType.note,
                          child: Text(localization.notesLabel),
                        ),
                        DropdownMenuItem(
                          value: KnowledgeNoteType.journal,
                          child: Text(localization.journalLabel),
                        ),
                        DropdownMenuItem(
                          value: KnowledgeNoteType.wiki,
                          child: Text(localization.wikiLabel),
                        ),
                      ],
                      onChanged: (value) => setState(() => type = value!),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.markdownMode),
                      value: format == KnowledgeContentFormat.markdown,
                      onChanged: (value) => setState(
                        () => format = value
                            ? KnowledgeContentFormat.markdown
                            : KnowledgeContentFormat.richText,
                      ),
                    ),
                    TextFormField(
                      minLines: 8,
                      maxLines: 16,
                      decoration: InputDecoration(
                        labelText: localization.noteContent,
                        alignLabelWithHint: true,
                      ),
                      onChanged: (value) => content = value,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localization.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: Text(localization.save),
            ),
          ],
        ),
      ),
    );
    if (saved == true && context.mounted) {
      await ref.read(knowledgeListControllerProvider.notifier).create(
        title: title,
        content: content,
        type: type,
        format: format,
      );
    }
  }
}

class _KnowledgeCard extends StatelessWidget {
  const _KnowledgeCard({
    required this.note,
    required this.onFavorite,
    required this.onDelete,
  });
  final KnowledgeNote note;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(switch (note.type) {
        KnowledgeNoteType.note => Icons.notes_outlined,
        KnowledgeNoteType.journal => Icons.book_outlined,
        KnowledgeNoteType.wiki => Icons.hub_outlined,
      }),
      title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        note.content.isEmpty ? AppLocalizations.of(context).emptyNote : note.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context).favorite,
            onPressed: onFavorite,
            icon: Icon(note.favorite ? Icons.star : Icons.star_border),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context).delete,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    ),
  );
}

class _KnowledgeMessage extends StatelessWidget {
  const _KnowledgeMessage({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.xl),
    children: [
      const SizedBox(height: 64),
      Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: AppSpacing.lg),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(message, textAlign: TextAlign.center),
    ],
  );
}
