import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/documents_providers.dart';

/// Extracted text review, implemented from the Figma frame
/// "SI Buddy · Extracted text review" (4:5039).
///
/// The reader shows the extracted pages with a working search field
/// and page navigation; confirming pushes the extraction success
/// screen. Nothing is generated until a study tool is chosen.
///
/// When an extraction job has completed, the reader shows the real
/// extracted text (one card per text block) and the document's real
/// name; opened without a result it shows an honest empty state —
/// never the design's sample pages.
///
/// Page boundaries are not always reliable (a page's own text can
/// contain blank lines, so the split produces more blocks than
/// pages), so the page count here is the number of text blocks
/// actually shown, not the document's page count. Each block can be
/// edited in place; saving persists the edited text locally.
class ExtractedTextReviewScreen extends ConsumerStatefulWidget {
  const ExtractedTextReviewScreen({super.key});

  @override
  ConsumerState<ExtractedTextReviewScreen> createState() =>
      _ExtractedTextReviewScreenState();
}

class _ExtractedTextReviewScreenState
    extends ConsumerState<ExtractedTextReviewScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _editController = TextEditingController();
  final _pageKeys = <GlobalKey>[];
  int _currentPage = 1;
  String _query = '';
  int? _editingIndex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _goToPage(int page, int totalPages) {
    final clamped = page.clamp(1, totalPages);
    setState(() => _currentPage = clamped);
    if (clamped - 1 < _pageKeys.length) {
      final key = _pageKeys[clamped - 1];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = key.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            alignment: 0.0,
          );
        }
      });
    }
  }

  void _startEditing(int index, String text) {
    setState(() {
      _editingIndex = index;
      _editController.text = text;
    });
  }

  Future<void> _saveEdit(List<String> sections, int documentId) async {
    final index = _editingIndex;
    if (index == null || _saving) return;
    setState(() => _saving = true);
    final updated = List<String>.of(sections);
    updated[index] = _editController.text;
    try {
      final repository = ref.read(documentRepositoryProvider);
      await repository.updateExtractedText(documentId, updated.join('\n\n'));
      final reloaded = await repository.getExtractedDocument(documentId);
      if (reloaded != null) {
        ref.read(extractionProvider.notifier).loadExisting(reloaded);
      }
      ref.invalidate(selectedExtractedDocumentProvider);
      if (mounted) {
        setState(() {
          _editingIndex = null;
          _saving = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Extracted text saved.')));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn\'t save the edited text. Try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final extraction = ref.watch(extractionProvider);
    final result = extraction.result;
    if (result == null) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'Review extracted text',
                onBack: () => context.pop(),
              ),
              const Expanded(
                child: EmptyState(
                  icon: Icons.description_outlined,
                  title: 'No extracted text to review',
                  message:
                      'Import a document first — its extracted text will appear here for review.',
                ),
              ),
            ],
          ),
        ),
      );
    }
    final sections = result.sections;
    // The blocks actually shown are the pages: the document's page
    // count can disagree with them when a page's text contains
    // blank lines.
    final totalPages = sections.isEmpty ? 1 : sections.length;
    while (_pageKeys.length < totalPages) {
      _pageKeys.add(GlobalKey());
    }
    final fileName = result.document.originalFileName;
    final subject = extraction.subject ?? 'No subject';
    final currentPage = _currentPage.clamp(1, totalPages);
    final searching = _query.isNotEmpty;
    final matches = searching
        ? [
            for (var i = 0; i < sections.length; i++)
              if (sections[i].toLowerCase().contains(_query)) i,
          ]
        : null;

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Review extracted text',
              onBack: () => context.pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A quick read, then study.',
                    style: AppTextStyles.display(
                      context,
                    ).copyWith(fontSize: 28, height: 34 / 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Review the text before generating flashcards or a quiz.',
                    style: AppTextStyles.body(
                      context,
                    ).copyWith(color: context.appMuted, height: 22 / 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fileName,
                          style: AppTextStyles.itemTitle(
                            context,
                          ).copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: context.appSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subject,
                          style: AppTextStyles.badge(
                            context,
                          ).copyWith(color: context.appPrimary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: context.appCard,
                      border: Border.all(color: context.appBorder),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/figma/search.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            context.appNavInactive,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.body(context),
                            decoration: InputDecoration(
                              hintText: 'Search in extracted text',
                              hintStyle: AppTextStyles.body(
                                context,
                              ).copyWith(color: context.appMuted),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (searching)
                          IconButton(
                            onPressed: _searchController.clear,
                            icon: const Icon(Icons.clear, size: 18),
                            color: context.appMuted,
                            constraints: const BoxConstraints.tightFor(
                              width: 48,
                              height: 48,
                            ),
                            padding: EdgeInsets.zero,
                            tooltip: 'Clear search',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          searching
                              ? '${matches!.length} match${matches.length == 1 ? '' : 'es'} for "$_query"'
                              : 'Page $currentPage of $totalPages',
                          style: AppTextStyles.link(context),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: searching || currentPage <= 1
                                  ? null
                                  : () =>
                                        _goToPage(currentPage - 1, totalPages),
                              tooltip: 'Previous page',
                              icon: SvgPicture.asset(
                                'assets/icons/figma/chevron_left.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  searching || currentPage <= 1
                                      ? context.appBorder
                                      : context.appNavInactive,
                                  BlendMode.srcIn,
                                ),
                              ),
                              constraints: const BoxConstraints.tightFor(
                                width: 48,
                                height: 48,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 2),
                            IconButton(
                              onPressed: searching || currentPage >= totalPages
                                  ? null
                                  : () =>
                                        _goToPage(currentPage + 1, totalPages),
                              tooltip: 'Next page',
                              icon: SvgPicture.asset(
                                'assets/icons/figma/chevron_right.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  searching || currentPage >= totalPages
                                      ? context.appBorder
                                      : context.appNavInactive,
                                  BlendMode.srcIn,
                                ),
                              ),
                              constraints: const BoxConstraints.tightFor(
                                width: 48,
                                height: 48,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: searching && matches!.isEmpty
                          ? Center(
                              child: Text(
                                'No pages contain that text.',
                                style: TextStyle(color: context.appMuted),
                              ),
                            )
                          : Builder(
                              builder: (context) {
                                final visibleIndices =
                                    matches ??
                                    List<int>.generate(
                                      sections.length,
                                      (j) => j,
                                    );
                                return ListView(
                                  controller: _scrollController,
                                  children: [
                                    for (final i in visibleIndices)
                                      _editingIndex == i
                                          ? _EditPageCard(
                                              key: _pageKeys[i],
                                              page: i + 1,
                                              totalPages: totalPages,
                                              controller: _editController,
                                              saving: _saving,
                                              onSave: () => _saveEdit(
                                                sections,
                                                result.document.id,
                                              ),
                                              onCancel: () => setState(
                                                () => _editingIndex = null,
                                              ),
                                            )
                                          : _ExtractedPageCard(
                                              key: _pageKeys[i],
                                              page: i + 1,
                                              totalPages: totalPages,
                                              text: sections[i],
                                              isLast: i == visibleIndices.last,
                                              onEdit: () =>
                                                  _startEditing(i, sections[i]),
                                            ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.appCard,
                border: Border(top: BorderSide(color: context.appBorder)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Column(
                children: [
                  if (!searching) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/figma/arrow_down.svg',
                          width: 12,
                          height: 12,
                          colorFilter: ColorFilter.mode(
                            context.appNavInactive,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Scroll to review all $totalPages pages',
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.extractionSuccess),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Confirm text'),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/icons/figma/arrow_right.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            context.appCard,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nothing is generated until you choose a study tool.',
                    style: AppTextStyles.caption(context),
                    textAlign: TextAlign.center,
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

/// One page/slide of real extracted text, in the review card chrome.
class _ExtractedPageCard extends StatelessWidget {
  const _ExtractedPageCard({
    required this.page,
    required this.totalPages,
    required this.text,
    required this.isLast,
    required this.onEdit,
    super.key,
  });

  final int page;
  final int totalPages;
  final String text;
  final bool isLast;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page $page of $totalPages',
                style: AppTextStyles.caption(
                  context,
                ).copyWith(color: context.appPrimary),
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Edit', style: AppTextStyles.link(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text.isEmpty ? 'No readable text on this page.' : text,
            style: AppTextStyles.body(context).copyWith(
              height: 22 / 14,
              color: text.isEmpty ? context.appMuted : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// The same card with the text editable: Save persists the edit
/// locally, Cancel discards it.
class _EditPageCard extends StatelessWidget {
  const _EditPageCard({
    required this.page,
    required this.totalPages,
    required this.controller,
    required this.saving,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final int page;
  final int totalPages;
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editing page $page of $totalPages',
            style: AppTextStyles.caption(
              context,
            ).copyWith(color: context.appPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: null,
            autofocus: true,
            style: AppTextStyles.body(context).copyWith(height: 22 / 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: saving ? null : onSave,
                  child: Text(saving ? 'Saving…' : 'Save'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: saving ? null : onCancel,
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
