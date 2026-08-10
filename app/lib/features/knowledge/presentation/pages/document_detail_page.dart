import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_top_bar.dart';
import '../../../../shared/presentation/async_state_view.dart';
import '../controllers/document_controller.dart';

class DocumentDetailPage extends ConsumerWidget {
  const DocumentDetailPage({required this.documentId, super.key});

  final int documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final document = ref.watch(documentDetailProvider(documentId));
    return Scaffold(
      appBar: AppTopBar(title: Text(localization.documentDetails)),
      body: SafeArea(
        child: document.when(
          loading: LoadingStateView.new,
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.invalidate(documentDetailProvider(documentId)),
          ),
          data: (item) {
            if (item == null) {
              return ActionStateView(
                icon: Icons.description_outlined,
                title: localization.documentNotFound,
                message: localization.documentNotFoundMessage,
              );
            }
            final image = item.mimeType.startsWith('image/') &&
                File(item.storagePath).existsSync();
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (image)
                  Semantics(
                    label: item.title,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(item.storagePath),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          const Icon(Icons.description_outlined, size: 64),
                          const SizedBox(height: AppSpacing.sm),
                          Text(localization.offlineMetadataPreview),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                _Metadata(label: localization.fileName, value: item.fileName),
                _Metadata(label: localization.fileType, value: item.mimeType),
                _Metadata(
                  label: localization.fileSize,
                  value: '${item.fileSize} B',
                ),
                _Metadata(
                  label: localization.createdDate,
                  value: DateFormat.yMMMd()
                      .add_jm()
                      .format(item.createdAt.toLocal()),
                ),
                _Metadata(
                  label: localization.encryption,
                  value: item.encrypted
                      ? localization.encrypted
                      : localization.protectedLocalStorage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: SelectableText(value),
  );
}
