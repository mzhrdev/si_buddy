import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/global_search_field.dart';

/// Global search results, implemented from the Figma frame
/// "SI Buddy · Global Search Results" (4:11763). The category row filters
/// the result groups locally; the query field is editable with a clear
/// button.
class GlobalSearchResultsScreen extends StatefulWidget {
  const GlobalSearchResultsScreen({super.key});

  @override
  State<GlobalSearchResultsScreen> createState() =>
      _GlobalSearchResultsScreenState();
}

class _GlobalSearchResultsScreenState extends State<GlobalSearchResultsScreen> {
  static const _categories = [
    'All 5',
    'Docs 2',
    'Cards 1',
    'Quizzes 1',
    'Summaries 1',
  ];

  final _controller = TextEditingController(text: 'cell');
  int _category = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _showDocuments => _category == 0 || _category == 1;
  bool get _showFlashcards => _category == 0 || _category == 2;
  bool get _showQuizzes => _category == 0 || _category == 3;
  bool get _showSummaries => _category == 0 || _category == 4;

  @override
  Widget build(BuildContext context) {
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
                  GlobalSearchField(controller: _controller, focused: true),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < _categories.length; i++)
                          _CategoryItem(
                            label: _categories[i],
                            selected: _category == i,
                            onTap: () => setState(() => _category = i),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    '5 results across your on-device study space',
                    style: AppTextStyles.caption,
                  ),
                  if (_showDocuments) ...[
                    const SizedBox(height: 13),
                    _ResultGroup(
                      heading: 'Documents · 2',
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            _DocumentResult(
                              title: 'Cell Biology - Chapter 4.pdf',
                              meta: 'PDF · 16 Oct 2026 · 2 study sets',
                              snippet: 'Cells are the basic unit of life.',
                              onTap: () => context.push(AppRoutes.details),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.border),
                                ),
                              ),
                              child: _DocumentResult(
                                title: 'Cell Membranes.pdf',
                                meta: 'PDF · 10 Oct 2026 · 1 study set',
                                snippet:
                                    'The cell membrane controls transport.',
                                onTap: () => context.push(AppRoutes.details),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_showFlashcards) ...[
                    const SizedBox(height: 13),
                    _ResultGroup(
                      heading: 'Flashcards · 1',
                      child: _TypedResult(
                        iconAsset:
                            'assets/icons/figma/gallery_vertical_end.svg',
                        title: 'Cell structures',
                        meta: '20 flashcards · Biology',
                        snippet: 'What is the role of the cell nucleus?',
                        onTap: () => context.push(AppRoutes.deck),
                      ),
                    ),
                  ],
                  if (_showQuizzes) ...[
                    const SizedBox(height: 13),
                    _ResultGroup(
                      heading: 'Quizzes · 1',
                      child: _TypedResult(
                        iconAsset: 'assets/icons/figma/list_checks.svg',
                        title: 'Cell structures',
                        meta: '10 questions · Biology',
                        snippet: 'Test your knowledge of cell structures.',
                        onTap: () => context.push(AppRoutes.quizSetup),
                      ),
                    ),
                  ],
                  if (_showSummaries) ...[
                    const SizedBox(height: 13),
                    _ResultGroup(
                      heading: 'Summaries · 1',
                      child: _TypedResult(
                        iconAsset: 'assets/icons/figma/align_left.svg',
                        title: 'Cell membrane transport',
                        meta: 'Summary · Cell Membranes.pdf',
                        snippet: 'How substances enter and leave a cell.',
                        // TODO(backend): summary detail destination.
                        onTap: () {},
                      ),
                    ),
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
  const _DocumentResult({
    required this.title,
    required this.meta,
    required this.snippet,
    required this.onTap,
  });

  final String title;
  final String meta;
  final String snippet;
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
              child: Text('PDF', style: AppTextStyles.badge),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.itemTitle.copyWith(
                      fontSize: 12,
                      height: 16 / 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: _metaStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    snippet,
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

/// A flashcard / quiz / summary result card: surface type-identity box
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
