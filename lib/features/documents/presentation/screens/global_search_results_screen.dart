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
import '../widgets/global_search_field.dart';

/// Global search results, implemented from the Figma frame
/// "SI Buddy · Global Search Results" (4:11763). The category row filters
/// the result groups locally; the query field is editable with a clear
/// button.
///
/// The results are real: documents come from the library stream and
/// are matched by file name; flashcards and quiz questions come from
/// this session's generation and are matched by their text. There is
/// no summaries category — summaries do not exist yet, so there is
/// nothing to search in. An empty query or no matches shows an
/// honest empty state, never the design's sample results.
class GlobalSearchResultsScreen extends ConsumerStatefulWidget {
  const GlobalSearchResultsScreen({super.key});

  @override
  ConsumerState<GlobalSearchResultsScreen> createState() =>
      _GlobalSearchResultsScreenState();
}

class _GlobalSearchResultsScreenState
    extends ConsumerState<GlobalSearchResultsScreen> {
  final _controller = TextEditingController();
  int _category = 0;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _showDocuments => _category == 0 || _category == 1;
  bool get _showFlashcards => _category == 0 || _category == 2;
  bool get _showQuizzes => _category == 0 || _category == 3;

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(documentsStreamProvider);
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final query = _query.trim().toLowerCase();

    final documents = documentsAsync.value ?? const <Document>[];
    final matchingDocs = query.isEmpty
        ? documents
        : documents
              .where(
                (d) => d.originalFileName.toLowerCase().contains(query),
              )
              .toList();
    final cards = result?.flashcards ?? const [];
    final matchingCards = query.isEmpty
        ? cards
        : cards
              .where(
                (c) =>
                    c.front.toLowerCase().contains(query) ||
                    c.back.toLowerCase().contains(query),
              )
              .toList();
    final questions = result?.questions ?? const [];
    final matchingQuestions = query.isEmpty
        ? questions
        : questions
              .where((q) => q.prompt.toLowerCase().contains(query))
              .toList();

    final categories = [
      'All ${matchingDocs.length + matchingCards.length + matchingQuestions.length}',
      'Docs ${matchingDocs.length}',
      'Cards ${matchingCards.length}',
      'Quizzes ${matchingQuestions.length}',
    ];
    final total =
        matchingDocs.length + matchingCards.length + matchingQuestions.length;
    final sourceDoc = result == null
        ? null
        : documents
              .where((d) => d.id == result.documentId)
              .firstOrNull;
    final setsTitle = generatedMaterialTitle(
      config: config,
      documentName: sourceDoc?.originalFileName,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Search', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                children: [
                  GlobalSearchField(
                    controller: _controller,
                    focused: true,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < categories.length; i++)
                          _CategoryItem(
                            label: categories[i],
                            selected: _category == i,
                            onTap: () => setState(() => _category = i),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  if (_query.trim().isEmpty)
                    const EmptyState(
                      icon: Icons.search,
                      title: 'Search your study space',
                      message:
                          'Type a word to search your documents, flashcards and quizzes.',
                    )
                  else if (total == 0)
                    EmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'No results for \'${_query.trim()}\'',
                      message:
                          'Try a different word — only your documents and this session\'s study sets are searched.',
                    )
                  else ...[
                    Text(
                      '$total result${total == 1 ? '' : 's'} across your on-device study space',
                      style: AppTextStyles.caption,
                    ),
                    if (_showDocuments && matchingDocs.isNotEmpty) ...[
                      const SizedBox(height: 13),
                      _ResultGroup(
                        heading: 'Documents · ${matchingDocs.length}',
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            children: [
                              for (var i = 0; i < matchingDocs.length; i++) ...[
                                if (i > 0)
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                    ),
                                  ),
                                _DocumentResult(
                                  document: matchingDocs[i],
                                  onTap: () {
                                    ref
                                        .read(
                                          selectedDocumentIdProvider.notifier,
                                        )
                                        .select(matchingDocs[i].id);
                                    context.push(AppRoutes.details);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (_showFlashcards && matchingCards.isNotEmpty) ...[
                      const SizedBox(height: 13),
                      _ResultGroup(
                        heading: 'Flashcards · ${matchingCards.length}',
                        child: _TypedResult(
                          iconAsset:
                              'assets/icons/figma/gallery_vertical_end.svg',
                          title: setsTitle,
                          meta: '${cards.length} flashcards',
                          snippet: matchingCards.first.front,
                          onTap: () => context.push(AppRoutes.deck),
                        ),
                      ),
                    ],
                    if (_showQuizzes && matchingQuestions.isNotEmpty) ...[
                      const SizedBox(height: 13),
                      _ResultGroup(
                        heading: 'Quizzes · ${matchingQuestions.length}',
                        child: _TypedResult(
                          iconAsset: 'assets/icons/figma/list_checks.svg',
                          title: setsTitle,
                          meta: '${questions.length} questions',
                          snippet: matchingQuestions.first.prompt,
                          onTap: () => context.push(AppRoutes.mcq),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One item of the search category row: a surface chip with primary
/// semibold text when active, plain muted text otherwise.
class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: AppTextStyles.caption.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? AppColors.primary : AppColors.muted,
      ),
    );
    if (!selected) {
      return GestureDetector(onTap: onTap, child: text);
    }
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: text,
        ),
      ),
    );
  }
}

/// A titled result group: heading above its card(s).
class _ResultGroup extends StatelessWidget {
  const _ResultGroup({required this.heading, required this.child});

  final String heading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: AppTextStyles.itemTitle),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Small bold metadata line used inside result cards (10px, per Figma).
TextStyle get _metaStyle => const TextStyle(
  fontFamily: 'Inter',
  fontSize: 10,
  fontWeight: FontWeight.w700,
  height: 14 / 10,
  color: AppColors.muted,
);

/// One document row inside the grouped "Matching documents" card.
class _DocumentResult extends StatelessWidget {
  const _DocumentResult({required this.document, required this.onTap});

  final Document document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                document.format.label,
                style: AppTextStyles.badge,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentDisplayName(document),
                    style: AppTextStyles.itemTitle.copyWith(
                      fontSize: 12,
                      height: 16 / 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${document.format.label} · ${formatFileSize(document.sizeBytes)} · ${document.pageCount} ${document.format.unitLabel}',
                    style: _metaStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// A flashcard / quiz result card: surface type-identity box
/// with an icon, then title, accent meta and snippet lines.
class _TypedResult extends StatelessWidget {
  const _TypedResult({
    required this.iconAsset,
    required this.title,
    required this.meta,
    required this.snippet,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String meta;
  final String snippet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 17,
                  height: 17,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      style: _metaStyle.copyWith(color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      snippet,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
