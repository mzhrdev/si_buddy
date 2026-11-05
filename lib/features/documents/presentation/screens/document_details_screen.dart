import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../domain/document_models.dart';
import '../providers/documents_providers.dart';
import '../widgets/privacy_reassurance.dart';

/// Document details, implemented from the Figma frame
/// "SI Buddy · Document details" (4:5163).
///
/// Shows the document identity, original file, an extracted-text
/// preview, associated study sets, and a pinned management bar
/// (Rename / Export / Delete).
///
/// When opened from the library with a selected document, every
/// field comes from the saved record and its saved extraction; the
/// study-set rows show only this session's generation for this
/// document. Opened without a selection it shows an honest empty
/// state — never the design's sample content.
class DocumentDetailsScreen extends ConsumerWidget {
  const DocumentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedDocumentIdProvider);
    if (selectedId != null) {
      final documentsAsync = ref.watch(documentsStreamProvider);
      final document = ref.watch(selectedDocumentProvider);
      final extractedAsync = ref.watch(selectedExtractedDocumentProvider);
      if (documentsAsync.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (document == null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                AppHeader(
                  title: 'Document details',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'This document is no longer in your library. It may have been deleted.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      final extracted = extractedAsync.value;
      final preview = extracted?.sections.firstWhere(
        (section) => section.trim().isNotEmpty,
        orElse: () => '',
      );
      // This session's study sets for this document, when the last
      // generation was from it; otherwise none (persistence does not
      // exist yet, so sets from earlier sessions are not known).
      final result = ref.watch(lastGenerationResultProvider);
      final config = ref.watch(generationConfigProvider);
      final setsForThisDoc =
          result != null && result.documentId == document.id;
      return _DetailsScaffold(
        title: documentDisplayName(document),
        subjectChip: 'Saved on this device',
        originalFormat: document.format.label,
        originalMeta:
            '${document.format.label} · ${formatFileSize(document.sizeBytes)} · ${document.pageCount} ${document.format.unitLabel}',
        previewTitle: document.title,
        previewPageLabel:
            '${document.format == DocumentFormat.pdf ? 'Page' : 'Slide'} 1 of ${document.pageCount}',
        previewText: preview == null
            ? 'Loading extracted text…'
            : preview.isEmpty
                ? 'No readable text was extracted from this document (for example, a scanned, image-only PDF — OCR did not find any readable text).'
                : preview,
        deckCount: setsForThisDoc ? result.flashcards.length : 0,
        quizCount: setsForThisDoc ? result.questions.length : 0,
        setsTitle: generatedMaterialTitle(
          config: config,
          documentName: document.originalFileName,
        ),
        onViewAll: extracted == null
            ? null
            : () {
                ref
                    .read(extractionProvider.notifier)
                    .loadExisting(extracted);
                context.push(AppRoutes.extractionReview);
              },
        onRename: () => _rename(context, ref, document),
        onExport: () async {
          final path = await ref
              .read(documentRepositoryProvider)
              .export(document.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Original saved on this device at $path'),
              ),
            );
          }
        },
        onDelete: () => context.push(AppRoutes.deleteFile),
        onOpenOriginal: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Original saved at ${document.storedPath}'),
            ),
          );
        },
      );
    }
    // Opened without a selection (only reachable by opening the
    // route directly): an honest empty state, never the design's
    // sample document.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Document details', onBack: () => context.pop()),
            const Expanded(
              child: EmptyState(
                icon: Icons.description_outlined,
                title: 'No document selected',
                message: 'Choose a document in the library to see its details.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Document document,
  ) async {
    final controller = TextEditingController(text: document.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Document title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newTitle == null || newTitle.isEmpty || newTitle == document.title) {
      return;
    }
    await ref.read(documentRepositoryProvider).rename(document.id, newTitle);
  }
}

/// Shared details layout, parameterised so the real-document
/// rendering shows its fields and its study sets.
class _DetailsScaffold extends StatelessWidget {
  const _DetailsScaffold({
    required this.title,
    required this.subjectChip,
    required this.originalFormat,
    required this.originalMeta,
    required this.previewTitle,
    required this.previewPageLabel,
    required this.previewText,
    required this.onViewAll,
    required this.onRename,
    required this.onExport,
    required this.onDelete,
    required this.onOpenOriginal,
    this.deckCount = 0,
    this.quizCount = 0,
    this.setsTitle = '',
  });

  final String title;
  final String subjectChip;
  final String originalFormat;
  final String originalMeta;
  final String previewTitle;
  final String previewPageLabel;
  final String previewText;
  final VoidCallback? onViewAll;
  final VoidCallback onRename;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final VoidCallback onOpenOriginal;

  /// Flashcards generated from this document this session (0 when
  /// none were, or when the last generation was from another file).
  final int deckCount;

  /// Quiz questions generated from this document this session.
  final int quizCount;

  /// Title for the study-set rows (topic, or the file name).
  final String setsTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Document details', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                children: [
                  Text(title, style: AppTextStyles.display),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subjectChip,
                          style: AppTextStyles.captionStrong.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Saved on this device',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _OriginalFileCard(
                    format: originalFormat,
                    meta: originalMeta,
                    onOpenOriginal: onOpenOriginal,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Extracted text', style: AppTextStyles.title),
                      if (onViewAll != null)
                        GestureDetector(
                          onTap: onViewAll,
                          child: Text('View all', style: AppTextStyles.link),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                previewTitle,
                                style: AppTextStyles.itemTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              previewPageLabel,
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          previewText,
                          style: AppTextStyles.muted.copyWith(
                            height: 20 / 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Associated study sets', style: AppTextStyles.title),
                      Text(
                        '${(deckCount > 0 ? 1 : 0) + (quizCount > 0 ? 1 : 0)} sets',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (deckCount > 0) ...[
                    _StudySetRow(
                      iconAsset: 'assets/icons/figma/gallery_vertical_end.svg',
                      title: setsTitle,
                      subtitle: '$deckCount flashcards',
                      onTap: () => context.push(AppRoutes.deck),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (quizCount > 0) ...[
                    _StudySetRow(
                      iconAsset: 'assets/icons/figma/list_checks.svg',
                      title: setsTitle,
                      subtitle: '$quizCount-question quiz',
                      onTap: () => context.push(AppRoutes.history),
                    ),
                  ],
                  if (deckCount == 0 && quizCount == 0)
                    Text(
                      'No study sets generated yet for this document.',
                      style: AppTextStyles.muted,
                    ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/pencil.svg',
                        label: 'Rename',
                        color: AppColors.primary,
                        onTap: onRename,
                      ),
                      const SizedBox(width: 8),
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/share_2.svg',
                        label: 'Export',
                        color: AppColors.primary,
                        onTap: onExport,
                      ),
                      const SizedBox(width: 8),
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/trash_2.svg',
                        label: 'Delete',
                        color: AppColors.danger,
                        backgroundColor: AppColors.dangerSurface,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const PrivacyReassurance(
                    text: 'Your notes stay on your device.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for the original file with its "Open original" action row.
class _OriginalFileCard extends StatelessWidget {
  const _OriginalFileCard({
    required this.format,
    required this.meta,
    required this.onOpenOriginal,
  });

  final String format;
  final String meta;
  final VoidCallback onOpenOriginal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(format, style: AppTextStyles.badge),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original file',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      meta,
                      style: AppTextStyles.muted.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/figma/file_text.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onOpenOriginal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Open original', style: AppTextStyles.link),
                SvgPicture.asset(
                  'assets/icons/figma/arrow_up_right.svg',
                  width: 15,
                  height: 15,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One associated study set row (flashcards deck or quiz).
class _StudySetRow extends StatelessWidget {
  const _StudySetRow({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.itemTitle),
                    const SizedBox(height: 5),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/figma/chevron_right.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.navInactive,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One action in the bottom management bar (Rename / Export / Delete).
class _ManagementAction extends StatelessWidget {
  const _ManagementAction({
    required this.iconAsset,
    required this.label,
    required this.color,
    required this.onTap,
    this.backgroundColor,
  });

  final String iconAsset;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: 15,
                  height: 15,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                Text(label, style: AppTextStyles.link.copyWith(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
