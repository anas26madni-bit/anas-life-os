import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../controllers/document_controller.dart';

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final documents = ref.watch(documentListControllerProvider);
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.documentsTitle)),
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
                hintText: localization.searchDocuments,
                leading: const Icon(Icons.search),
                onSubmitted: ref
                    .read(documentListControllerProvider.notifier)
                    .search,
              ),
            ),
            Expanded(
              child: documents.when(
                loading: LoadingStateView.new,
                error: (error, _) => ErrorStateView(
                  message: error.toString(),
                  onRetry: ref
                      .read(documentListControllerProvider.notifier)
                      .refresh,
                ),
                data: (items) => items.isEmpty
                    ? ActionStateView(
                        icon: Icons.folder_copy_outlined,
                        title: localization.noDocumentsTitle,
                        message: localization.noDocumentsMessage,
                      )
                    : RefreshIndicator(
                        onRefresh: ref
                            .read(documentListControllerProvider.notifier)
                            .refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final document = items[index];
                            return Card(
                              child: ListTile(
                                minTileHeight: 64,
                                leading: Icon(_documentIcon(document.mimeType)),
                                title: Text(document.title),
                                subtitle: Text(
                                  '${document.fileName} · ${_fileSize(document.fileSize)}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: PopupMenuButton<String>(
                                  tooltip: localization.documentActions,
                                  onSelected: (action) {
                                    if (action == 'delete') {
                                      ref
                                          .read(
                                            documentListControllerProvider
                                                .notifier,
                                          )
                                          .delete(document.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(localization.delete),
                                    ),
                                  ],
                                ),
                                onTap: () => DocumentDetailRoute(
                                  document.id,
                                ).push<void>(context),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _documentIcon(String mimeType) {
  if (mimeType.startsWith('image/')) return Icons.image_outlined;
  if (mimeType.startsWith('audio/')) return Icons.audio_file_outlined;
  if (mimeType.startsWith('video/')) return Icons.video_file_outlined;
  if (mimeType == 'application/pdf') return Icons.picture_as_pdf_outlined;
  return Icons.description_outlined;
}

String _fileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
