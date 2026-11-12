import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../study/domain/study_models.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../../domain/document_models.dart';
import '../providers/documents_providers.dart';
import '../widgets/document_actions.dart';
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
/// study-set rows are the document's real persisted decks,
/// clickable to study them. Opened without a selection it shows an
/// honest empty state — never the design's sample content.
class DocumentDetailsScreen extends ConsumerWidget {
  const DocumentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedDocumentIdProvider);
    if (selectedId != null) {
      final documentsAsync = ref.watch(documentsStreamProvider);
      final document = ref.watch(selectedDocumentProvider);
      final extractedAsync = ref.watch(selectedExtractedDocumentProvider);
      final decksAsync = ref.watch(documentDecksProvider(selectedId));
      if (documentsAsync.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (document == null) {
        return Scaffold(
          backgroundColor: context.appBackground,
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
                        style: AppTextStyles.body(context),
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
      final decks = decksAsync.value ?? const [];
      return _DetailsScaffold(
        title: documentDisplayName(document),
        subjectChip: 'Saved on this device',
        originalFormat: document.format.label,
        originalMeta:
            '${document.format.label} · ${formatFileSize(document.sizeBytes)} · ${document.pageCount} ${document.format.unitLabel} · Imported ${formatLibraryDate(document.createdAt)}',
        previewTitle: document.title,
        previewPageLabel:
            '${document.format == DocumentFormat.pdf ? 'Page' : 'Slide'} 1 of ${document.pageCount}',
        previewText: preview == null
            ? 'Loading extracted text…'
            : preview.isEmpty
            ? 'No readable text was extracted from this document (for example, a scanned, image-only PDF — OCR did not find any readable text).'
            : preview,
        studySets: decks,
        decksLoading: decksAsync.isLoading,
        onViewAll: extracted == null
            ? null
            : () {
                ref.read(extractionProvider.notifier).loadExisting(extracted);
                context.push(AppRoutes.extractionReview);
              },
        onOpenStudySet: (deck) => _openStudySet(context, ref, deck),
        onGenerateFlashcards: () =>
            _generateFromDocument(context, ref, document.id),
        onGenerateQuiz: () =>
            _generateQuizFromDocument(context, ref, document.id),
        onRename: () => showRenameDocumentDialog(context, ref, document),
        onExport: () => _export(context, ref, document),
        onDelete: () async {
          final deleted = await confirmDeleteDocument(
            context,
            ref,
            document,
            studySetCount: decks.length,
          );
          if (deleted) {
            ref.read(selectedDocumentIdProvider.notifier).clear();
            if (context.mounted) context.pop();
          }
        },
      );
    }
    // Opened without a selection (only reachable by opening the
    // route directly): an honest empty state, never the design's
    // sample document.
    return Scaffold(
      backgroundColor: context.appBackground,
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

  /// Opens a persisted deck in the study screens: loads it as the
  /// current session result, then navigates to the deck overview
  /// (flashcards) or the quiz (quiz decks).
  static Future<void> _openStudySet(
    BuildContext context,
    WidgetRef ref,
    StudyDeck deck,
  ) async {
    final loaded = await ref
        .read(generationJobProvider.notifier)
        .loadDeck(deck.id);
    if (!context.mounted) return;
    if (!loaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That study set is no longer available.')),
      );
      return;
    }
    context.push(deck.isQuiz ? AppRoutes.mcq : AppRoutes.deck);
  }

  static Future<void> _generateFromDocument(
    BuildContext context,
    WidgetRef ref,
    int documentId,
  ) async {
    final bound = await bindDocumentAsGenerationSource(ref, documentId);
    if (!context.mounted) return;
    if (bound) {
      context.push(AppRoutes.generationSetup);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This document has no readable text to generate from.'),
        ),
      );
    }
  }

  static Future<void> _generateQuizFromDocument(
    BuildContext context,
    WidgetRef ref,
    int documentId,
  ) async {
    final bound = await bindDocumentAsGenerationSource(ref, documentId);
    if (!context.mounted) return;
    if (bound) {
      context.push(AppRoutes.quizSetup);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This document has no readable text to generate from.'),
        ),
      );
    }
  }

  /// The internal storage path is never shown to the user.
  static Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    Document document,
  ) async {
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(document.storedPath)],
          subject: document.originalFileName,
        ),
      );
      if (!context.mounted) return;
      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shared ${documentDisplayName(document)}')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Couldn\'t share ${documentDisplayName(document)}. Try again.',
          ),
        ),
      );
    }
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
    required this.studySets,
    required this.decksLoading,
    required this.onOpenStudySet,
    required this.onGenerateFlashcards,
    required this.onGenerateQuiz,
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

  /// The document's persisted decks, newest first.
  final List<StudyDeck> studySets;

  /// True while the decks are still loading.
  final bool decksLoading;

  final void Function(StudyDeck deck) onOpenStudySet;
  final VoidCallback onGenerateFlashcards;
  final VoidCallback onGenerateQuiz;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Document details', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                children: [
                  Text(title, style: AppTextStyles.display(context)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: context.appSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subjectChip,
                          style: AppTextStyles.captionStrong(context).copyWith(
                            color: context.appPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _OriginalFileCard(format: originalFormat, meta: originalMeta),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Extracted text', style: AppTextStyles.title(context)),
                      if (onViewAll != null)
                        GestureDetector(
                          onTap: onViewAll,
                          child: Text('View all', style: AppTextStyles.link(context)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.appCard,
                      border: Border.all(color: context.appBorder),
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
                                style: AppTextStyles.itemTitle(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              previewPageLabel,
                              style: AppTextStyles.badge(context).copyWith(
                                color: context.appMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          previewText,
                          style: AppTextStyles.muted(context).copyWith(height: 20 / 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Associated study sets', style: AppTextStyles.title(context)),
                      Text(
                        '${studySets.length} set${studySets.length == 1 ? '' : 's'}',
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (decksLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (studySets.isEmpty) ...[
                    Text(
                      'No study sets generated yet for this document.',
                      style: AppTextStyles.muted(context),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: onGenerateFlashcards,
                            child: const Text('Generate flashcards'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onGenerateQuiz,
                            child: const Text('Create quiz'),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    for (final deck in studySets) ...[
                      _StudySetRow(
                        iconAsset: deck.isQuiz
                            ? 'assets/icons/figma/list_checks.svg'
                            : 'assets/icons/figma/gallery_vertical_end.svg',
                        title: deck.title,
                        subtitle: deck.isQuiz
                            ? '${deck.totalItems}-question quiz'
                            : '${deck.totalItems} flashcards',
                        onTap: () => onOpenStudySet(deck),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.appCard,
                border: Border(top: BorderSide(color: context.appBorder)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/pencil.svg',
                        label: 'Rename',
                        color: context.appPrimary,
                        onTap: onRename,
                      ),
                      const SizedBox(width: 8),
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/share_2.svg',
                        label: 'Export',
                        color: context.appPrimary,
                        onTap: onExport,
                      ),
                      const SizedBox(width: 8),
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/trash_2.svg',
                        label: 'Delete',
                        color: context.appDanger,
                        backgroundColor: context.appDangerSurface,
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

/// Card for the original file with its format, size, page count
/// and import date. The internal storage path is never shown.
class _OriginalFileCard extends StatelessWidget {
  const _OriginalFileCard({required this.format, required this.meta});

  final String format;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appCard,
              border: Border.all(color: context.appBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(format, style: AppTextStyles.badge(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Original file',
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(meta, style: AppTextStyles.muted(context).copyWith(fontSize: 12)),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/figma/file_text.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              context.appPrimary,
              BlendMode.srcIn,
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
            border: Border.all(color: context.appBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    context.appPrimary,
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
                    Text(title, style: AppTextStyles.itemTitle(context)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: AppTextStyles.caption(context)),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/figma/chevron_right.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  context.appNavInactive,
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
              color: backgroundColor ?? context.appCard,
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
                Text(label, style: AppTextStyles.link(context).copyWith(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
