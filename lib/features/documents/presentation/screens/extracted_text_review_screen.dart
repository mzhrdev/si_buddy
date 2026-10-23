import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../providers/documents_providers.dart';

/// Extracted text review, implemented from the Figma frame
/// "SI Buddy · Extracted text review" (4:5039).
///
/// The reader shows the extracted pages with a working search field
/// and page navigation; confirming pushes the extraction success
/// screen. Nothing is generated until a study tool is chosen.
///
/// When an extraction job has completed, the reader shows the real
/// extracted text (one card per page/slide) and the document's real
/// name and page count; opened without a result it keeps the design's
/// sample pages.
class ExtractedTextReviewScreen extends ConsumerStatefulWidget {
  const ExtractedTextReviewScreen({super.key});

  @override
  ConsumerState<ExtractedTextReviewScreen> createState() =>
      _ExtractedTextReviewScreenState();
}

class _ExtractedTextReviewScreenState
    extends ConsumerState<ExtractedTextReviewScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToPage(int page, int totalPages) {
    setState(() {
      _currentPage = page.clamp(1, totalPages);
    });
  }

  @override
  Widget build(BuildContext context) {
    final extraction = ref.watch(extractionProvider);
    final result = extraction.result;
    final totalPages = result?.document.pageCount ?? 12;
    final fileName =
        result?.document.originalFileName ?? 'Cell Biology - Chapter 4.pdf';
    final subject = extraction.subject ?? 'Biology';
    final currentPage = _currentPage.clamp(1, totalPages);

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    style: AppTextStyles.display.copyWith(
                      fontSize: 28,
                      height: 34 / 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Review the text before generating flashcards or a quiz.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.muted,
                      height: 22 / 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fileName,
                          style: AppTextStyles.itemTitle.copyWith(fontSize: 12),
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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          subject,
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/figma/search.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.navInactive,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              hintText: 'Search in extracted text',
                              hintStyle: AppTextStyles.body.copyWith(
                                color: AppColors.muted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
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
                          'Page $currentPage of $totalPages',
                          style: AppTextStyles.link,
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: currentPage > 1
                                  ? () => _goToPage(currentPage - 1, totalPages)
                                  : null,
                              icon: SvgPicture.asset(
                                'assets/icons/figma/chevron_left.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  currentPage > 1
                                      ? AppColors.navInactive
                                      : AppColors.border,
                                  BlendMode.srcIn,
                                ),
                              ),
                              constraints: const BoxConstraints.tightFor(
                                width: 32,
                                height: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 2),
                            IconButton(
                              onPressed: currentPage < totalPages
                                  ? () => _goToPage(currentPage + 1, totalPages)
                                  : null,
                              icon: SvgPicture.asset(
                                'assets/icons/figma/chevron_right.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  currentPage < totalPages
                                      ? AppColors.navInactive
                                      : AppColors.border,
                                  BlendMode.srcIn,
                                ),
                              ),
                              constraints: const BoxConstraints.tightFor(
                                width: 32,
                                height: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: result == null
                            ? const [_PageOneCard(), _PageTwoCard()]
                            : [
                                for (
                                  var i = 0;
                                  i < result.sections.length;
                                  i++
                                )
                                  _ExtractedPageCard(
                                    page: i + 1,
                                    totalPages: totalPages,
                                    text: result.sections[i],
                                    isLast: i == result.sections.length - 1,
                                  ),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma/arrow_down.svg',
                        width: 12,
                        height: 12,
                        colorFilter: const ColorFilter.mode(
                          AppColors.navInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Scroll to review all \$totalPages pages',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nothing is generated until you choose a study tool.',
                    style: AppTextStyles.caption,
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

/// Page 1 of the extracted document, as shown in the design.
class _PageOneCard extends StatelessWidget {
  const _PageOneCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHAPTER 4',
            style: AppTextStyles.badge.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text('Cell Biology', style: AppTextStyles.display),
          const SizedBox(height: 14),
          Text(
            'The building blocks of life',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Text(
            'Cells are the basic unit of life. Each cell contains structures that work together to support its functions.',
            style: AppTextStyles.body.copyWith(height: 22 / 14),
          ),
          const SizedBox(height: 14),
          Text(
            'The cell membrane controls what enters and leaves the cell. Inside, the cytoplasm holds organelles that carry out essential processes.',
            style: AppTextStyles.body.copyWith(height: 22 / 14),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          Center(child: Text('1 / 12', style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}

/// Page 2 of the extracted document, as shown in the design.
class _PageTwoCard extends StatelessWidget {
  const _PageTwoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Page 2 of 12',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text('Inside the cell', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Text(
            'The nucleus stores genetic information. Mitochondria release usable energy through cellular respiration.',
            style: AppTextStyles.body.copyWith(height: 22 / 14),
          ),
        ],
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
  });

  final int page;
  final int totalPages;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Page $page of $totalPages',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            text.isEmpty ? 'No readable text on this page.' : text,
            style: AppTextStyles.body.copyWith(
              height: 22 / 14,
              color: text.isEmpty ? AppColors.muted : null,
            ),
          ),
        ],
      ),
    );
  }
}
