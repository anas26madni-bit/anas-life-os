import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../../domain/entities/knowledge_enums.dart';
import '../../domain/entities/knowledge_note.dart';
import '../controllers/knowledge_controller.dart';

class KnowledgeDetailPage extends ConsumerWidget {
  const KnowledgeDetailPage({required this.noteId, super.key});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final note = ref.watch(knowledgeDetailProvider(noteId));
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.noteDetails)),
      body: SafeArea(
        child: note.when(
          loading: LoadingStateView.new,
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.invalidate(knowledgeDetailProvider(noteId)),
          ),
          data: (item) => item == null
              ? ActionStateView(
                  icon: Icons.notes_outlined,
                  title: localization.noteNotFound,
                  message: localization.noteNotFoundMessage,
                )
              : _NoteContent(note: item),
        ),
      ),
      floatingActionButton: note.value == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _editNote(context, ref, note.requireValue!),
              icon: const Icon(Icons.edit_outlined),
              label: Text(localization.edit),
            ),
    );
  }
}

class _NoteContent extends ConsumerWidget {
  const _NoteContent({required this.note});
  final KnowledgeNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final versions = ref.watch(knowledgeVersionsProvider(note.id));
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
            ),
            if (note.pinned) const Icon(Icons.push_pin_outlined),
            if (note.favorite) const Icon(Icons.star),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            Chip(label: Text(localization.noteTypeLabel(note.type.name))),
            Chip(label: Text(localization.contentFormatLabel(note.format.name))),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SelectableText(note.content.isEmpty ? localization.emptyNote : note.content),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () => _editTags(context, ref, note.id),
              icon: const Icon(Icons.label_outline),
              label: Text(localization.editTags),
            ),
            OutlinedButton.icon(
              onPressed: () => _linkNote(context, ref, note.id),
              icon: const Icon(Icons.link),
              label: Text(localization.linkNote),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(localization.versionHistory, style: Theme.of(context).textTheme.titleLarge),
        versions.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(error.toString()),
          data: (items) => Column(
            children: [
              for (final version in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: Text(localization.versionNumber(version.versionNumber)),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(version.createdAt.toLocal())),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _editTags(BuildContext context, WidgetRef ref, int noteId) async {
  var value = '';
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context).editTags),
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(labelText: AppLocalizations.of(context).tagsCommaSeparated),
        onChanged: (text) => value = text,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, value), child: Text(AppLocalizations.of(context).save)),
      ],
    ),
  );
  if (result != null) {
    await ref.read(knowledgeListControllerProvider.notifier).replaceTags(
      noteId,
      result.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
    );
  }
}

Future<void> _linkNote(BuildContext context, WidgetRef ref, int sourceId) async {
  var target = '';
  final result = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context).linkNote),
      content: TextField(
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: AppLocalizations.of(context).targetNoteId),
        onChanged: (value) => target = value,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, int.tryParse(target)), child: Text(AppLocalizations.of(context).save)),
      ],
    ),
  );
  if (result != null) {
    await ref
        .read(knowledgeListControllerProvider.notifier)
        .link(sourceId, result, KnowledgeLinkType.reference);
  }
}

Future<void> _editNote(
  BuildContext context,
  WidgetRef ref,
  KnowledgeNote note,
) async {
  final localization = AppLocalizations.of(context);
  final key = GlobalKey<FormState>();
  var title = note.title;
  var content = note.content;
  var type = note.type;
  var format = note.format;
  var favorite = note.favorite;
  var pinned = note.pinned;
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
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
                  Text(localization.editNote, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    initialValue: title,
                    maxLength: 300,
                    decoration: InputDecoration(labelText: localization.noteTitle),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? localization.noteTitleRequired
                        : null,
                    onChanged: (value) => title = value,
                  ),
                  DropdownButtonFormField<KnowledgeNoteType>(
                    initialValue: type,
                    decoration: InputDecoration(labelText: localization.noteType),
                    items: KnowledgeNoteType.values
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(localization.noteTypeLabel(value.name)),
                            ))
                        .toList(growable: false),
                    onChanged: (value) => type = value!,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(localization.markdownMode),
                    value: format == KnowledgeContentFormat.markdown,
                    onChanged: (value) => setState(() => format = value
                        ? KnowledgeContentFormat.markdown
                        : KnowledgeContentFormat.richText),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(localization.favorite),
                    value: favorite,
                    onChanged: (value) => setState(() => favorite = value),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(localization.pinned),
                    value: pinned,
                    onChanged: (value) => setState(() => pinned = value),
                  ),
                  TextFormField(
                    initialValue: content,
                    minLines: 10,
                    maxLines: 20,
                    decoration: InputDecoration(labelText: localization.noteContent),
                    onChanged: (value) => content = value,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => key.currentState!.validate() ? Navigator.pop(context, true) : null,
                    child: Text(localization.save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  if (saved == true) {
    await ref.read(knowledgeListControllerProvider.notifier).update(
      note,
      KnowledgeNoteDraft(
        spaceId: note.spaceId,
        folderId: note.folderId,
        title: title,
        content: content,
        summary: note.summary,
        type: type,
        format: format,
        status: note.status,
        favorite: favorite,
        pinned: pinned,
      ),
    );
  }
}
