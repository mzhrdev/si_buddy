import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/study_material_row.dart';
import '../widgets/study_progress_track.dart';

/// Subject Details, implemented from the Figma frame
/// "SI Buddy · Subject Details" (5:11584): subject identity, the
/// flashcard mastery card, study shortcuts, and the subject's
/// materials.
class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Subject details', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                children: [
                  const Text(
                    'Biology',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 34 / 28,
                      letterSpacing: -0.56,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '4 study materials · Semester 1',
                    style: AppTextStyles.greeting,
                  ),
                  const SizedBox(height: 16),
                  const _MasteryCard(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.push(AppRoutes.deck),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Study deck'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.push(AppRoutes.cardFront),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Review 8 cards'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your materials',
                          style: AppTextStyles.title,
                        ),
                      ),
                      Text('4 items', style: AppTextStyles.link),
                    ],
                  ),
                  const SizedBox(height: 2),
                  StudyMaterialRow(
                    iconAsset: 'assets/icons/figma/layers.svg',
                    typeLabel: 'DECK',
                    title: 'Cell structures',
                    meta: '20 cards · 12 mastered · 3 difficult',
                    verticalPadding: 7,
                    onTap: () => context.push(AppRoutes.deck),
                  ),
                  StudyMaterialRow(
                    iconAsset: 'assets/icons/figma/list_checks.svg',
                    typeLabel: 'QUIZ',
                    title: 'Cell structures',
                    meta: '10 questions · Latest score 7/10',
                    verticalPadding: 7,
                    onTap: () => context.push(AppRoutes.history),
                  ),
                  StudyMaterialRow(
                    iconAsset: 'assets/icons/figma/file_text.svg',
                    typeLabel: 'SUMMARY',
                    title: 'Cell Biology · Chapter 4',
                    meta: 'Read 3 of 5 sections',
                    verticalPadding: 7,
                    // TODO(backend): open the generated summary.
                    onTap: () {},
                  ),
                  StudyMaterialRow(
                    iconAsset: 'assets/icons/figma/bookmark.svg',
                    typeLabel: 'SAVED QUESTIONS',
                    title: 'Membranes & organelles',
                    meta: '4 questions · 2 reviewed',
                    verticalPadding: 7,
                    onTap: () => context.push(AppRoutes.revision),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma/circle_check.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Saved on this device · Available offline',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
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
}

/// White bordered card with the flashcard mastery progress: heading,
/// progress track, the mastered/learning/difficult breakdown, and a
/// footnote about the last session.
class _MasteryCard extends StatelessWidget {
  const _MasteryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              const Expanded(
                child: Text(
                  'Flashcard mastery',
                  style: AppTextStyles.itemTitle,
                ),
              ),
              Text('12 / 20 mastered', style: AppTextStyles.link),
            ],
          ),
          const SizedBox(height: 10),
          const StudyProgressTrack(fraction: 12 / 20),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _MasteryMetric(value: '12', label: 'Mastered'),
              ),
              Expanded(
                child: _MasteryMetric(value: '5', label: 'Learning'),
              ),
              Expanded(
                child: _MasteryMetric(value: '3', label: 'Difficult'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Cell structures · 20/20 reviewed last session',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// One metric in the mastery breakdown: a large value over a muted
/// caption label.
class _MasteryMetric extends StatelessWidget {
  const _MasteryMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.headline.copyWith(letterSpacing: -0.48),
        ),
        const SizedBox(height: 1),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
