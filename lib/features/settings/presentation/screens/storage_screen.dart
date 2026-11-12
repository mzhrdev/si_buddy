import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../documents/domain/document_models.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../model_management/domain/model_state.dart';
import '../../../model_management/presentation/providers/model_providers.dart';
import '../providers/storage_providers.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/settings_row.dart';

/// Storage, implemented from the Figma frame "SI Buddy · Storage"
/// (5:20835).
///
/// Every figure comes from real state: the documents total from the
/// library, the model size from the model file on disk, the cache
/// and database sizes from the device's directories, and the study
/// materials from the persisted decks and stats. Clear Cache really
/// clears the temp directory; deleting a file really deletes it
/// (record, extracted text and the app's stored copy) behind a
/// confirmation dialog.
class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentsStreamProvider).value ?? const [];
    final figures = ref.watch(storageFiguresProvider).value;
    final modelReady = ref.watch(modelProvider).isReady;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Storage', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  _UsageCard(figures: figures),
                  const SizedBox(height: 16),
                  SettingsRow(
                    iconAsset: 'assets/icons/figma/cpu.svg',
                    label: 'AI Model',
                    supportingText: modelReady
                        ? '${AiModelInfo.current.displayName} · Installed'
                        : '${AiModelInfo.current.displayName} · Not installed',
                    trailingValue: modelReady
                        ? (figures == null
                              ? '…'
                              : formatFileSize(figures.modelBytes))
                        : 'Not installed',
                    showDivider: true,
                    onTap: () => context.push(AppRoutes.readyOffline),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      onTap: () => _confirmClearCache(context, ref, figures),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma/eraser.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                context.appPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Clear Cache',
                              style: AppTextStyles.body(context).copyWith(
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                                color: context.appPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'Local files',
                    children: [
                      if (documents.isEmpty)
                        const EmptyState(
                          icon: Icons.folder_outlined,
                          title: 'No local files yet',
                          message: 'Import a document to see it listed here.',
                        )
                      else ...[
                        for (var i = 0; i < documents.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          _LocalFileCard(document: documents[i]),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Deleting a file also removes its extracted text. '
                          'Generated study sets and progress remain.',
                          style: AppTextStyles.greeting(
                            context,
                          ).copyWith(height: 18 / 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clears the temporary cache behind the Figma confirmation
  /// dialog, then reports how much was freed.
  Future<void> _confirmClearCache(
    BuildContext context,
    WidgetRef ref,
    StorageFigures? figures,
  ) async {
    final cacheText = figures == null
        ? 'temporary cache'
        : formatFileSize(figures.cacheBytes);
    final confirmed = await showConfirmationDialog(
      context: context,
      iconAsset: 'assets/icons/figma/eraser.svg',
      indicatorColor: context.appSurface,
      iconColor: context.appPrimary,
      title: 'Clear Cache?',
      messageParagraphs: [
        'Only temporary cache is removed ($cacheText). It may be rebuilt as you use the app.',
        'Your source documents, extracted text, downloaded model, study sets and study progress are preserved.',
      ],
      confirmLabel: 'Clear Cache',
    );
    if (!confirmed) return;
    final freed = await clearCache(ref);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cache cleared · ${formatFileSize(freed)} freed.'),
        ),
      );
    }
  }
}

/// One imported document's storage card: name, format/size/pages,
/// and the details and delete actions. Deleting asks first, then
/// really deletes the document.
class _LocalFileCard extends ConsumerWidget {
  const _LocalFileCard({required this.document});

  final Document document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            document.originalFileName,
            style: AppTextStyles.body(
              context,
            ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${document.format.label} · ${formatFileSize(document.sizeBytes)} · ${document.pageCount} ${document.format.unitLabel}',
            style: AppTextStyles.greeting(context),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  ref
                      .read(selectedDocumentIdProvider.notifier)
                      .select(document.id);
                  context.push(AppRoutes.details);
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'View details',
                    style: AppTextStyles.link(context),
                  ),
                ),
              ),
              Material(
                color: context.appDangerSurface,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: () => _confirmDelete(context, ref),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    child: Text(
                      'Delete File',
                      style: AppTextStyles.link(
                        context,
                      ).copyWith(color: context.appDanger),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      iconAsset: 'assets/icons/figma/trash_2.svg',
      indicatorColor: context.appDangerSurface,
      iconColor: context.appDanger,
      title: 'Delete File?',
      messageParagraphs: const [
        'Permanently remove this app’s copy of the document and its '
            'extracted text. This cannot be undone.',
        'Already generated study sets and progress remain. Files and '
            'exports outside SI Buddy are not removed.',
      ],
      confirmLabel: 'Delete File',
      confirmColor: AppColors.danger,
    );
    if (!confirmed) return;
    await ref.read(documentRepositoryProvider).delete(document.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${document.originalFileName}.')),
      );
    }
  }
}

/// The "Known content usage" card: total, breakdown bar and
/// per-category totals — all measured. While the figures are
/// loading the card shows zeros with a "measuring…" note rather
/// than estimates.
class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.figures});

  final StorageFigures? figures;

  @override
  Widget build(BuildContext context) {
    final figures = this.figures;
    final total = figures?.totalBytes ?? 0;
    final documentsBytes = figures?.documentsBytes ?? 0;
    final fileCount = figures?.fileCount ?? 0;
    final modelBytes = figures?.modelBytes ?? 0;
    final modelInstalled = figures?.modelInstalled ?? false;
    final cacheBytes = figures?.cacheBytes ?? 0;
    final databaseBytes = figures?.databaseBytes ?? 0;
    final deckCount = figures?.deckCount ?? 0;
    final quizCount = figures?.quizCount ?? 0;
    final cardCount = figures?.cardCount ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Known-content usage',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
              color: context.appMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatFileSize(total),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 34 / 28,
              letterSpacing: -0.56,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            figures == null
                ? 'Measuring storage…'
                : 'Documents, model, cache and the local database, measured on this device.',
            style: AppTextStyles.greeting(context).copyWith(height: 18 / 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: total > 0 ? context.appPrimary : context.appBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UsageCategory(
            name: 'Documents & extracted text',
            amount: formatFileSize(documentsBytes),
            detail: fileCount == 0
                ? 'No files imported yet'
                : '$fileCount file${fileCount == 1 ? '' : 's'}',
          ),
          const SizedBox(height: 12),
          _UsageCategory(
            name: 'AI model',
            amount: modelInstalled
                ? formatFileSize(modelBytes)
                : 'Not installed',
            detail: modelInstalled
                ? '${AiModelInfo.current.displayName} · On-device model file'
                : 'Download the model to generate offline',
          ),
          const SizedBox(height: 12),
          _UsageCategory(
            name: 'Study materials',
            amount: deckCount + quizCount == 0
                ? 'None yet'
                : '$deckCount deck${deckCount == 1 ? '' : 's'} · $quizCount quiz${quizCount == 1 ? '' : 'zes'}',
            detail:
                '$cardCount flashcard${cardCount == 1 ? '' : 's'} generated · Kept in the local database',
          ),
          const SizedBox(height: 12),
          _UsageCategory(
            name: 'Local database',
            amount: formatFileSize(databaseBytes),
            detail: 'Documents, extracted text, study data and settings',
          ),
          const SizedBox(height: 12),
          _UsageCategory(
            name: 'Temporary cache',
            amount: formatFileSize(cacheBytes),
            detail:
                'Staged imports and scratch files · Cleared with Clear Cache',
          ),
        ],
      ),
    );
  }
}

/// One usage category: name and total on one line (13 semibold),
/// optional detail line (11 muted) below.
class _UsageCategory extends StatelessWidget {
  const _UsageCategory({required this.name, required this.amount, this.detail});

  final String name;
  final String amount;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final totalStyle = AppTextStyles.body(
      context,
    ).copyWith(fontSize: 13, fontWeight: FontWeight.w600, height: 18 / 13);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: totalStyle),
            Text(amount, style: totalStyle),
          ],
        ),
        if (detail != null) ...[
          const SizedBox(height: 3),
          Text(detail!, style: AppTextStyles.caption(context)),
        ],
      ],
    );
  }
}
