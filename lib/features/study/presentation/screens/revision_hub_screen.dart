import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/study_destinations_bar.dart';

/// Revision Hub, implemented from the Figma frame
/// "SI Buddy · Revision Hub" (5:11704): the saved review collections
/// (bookmarks, difficult cards, incorrect answers), each with a
/// representative item and a review action.
class RevisionHubScreen extends StatelessWidget {
  const RevisionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Revision hub'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                children: [
                  const StudyDestinationsBar(currentIndex: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Focus on what needs practice.',
                    style: AppTextStyles.display.copyWith(letterSpacing: -0.48),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Biology · Your saved review collections',
                    style: AppTextStyles.greeting,
                  ),
                  const SizedBox(height: 16),
                  _RevisionCategory(
                    iconAsset: 'assets/icons/figma/bookmark.svg',
                    title: 'Bookmarks',
                    count: '4 saved',
                    materialTitle: 'Membranes & organelles',
                    materialMeta: 'Saved questions · 2 of 4 reviewed',
                    actionLabel: 'Review bookmarks',
                    // TODO(backend): review the bookmarked questions.
                    onAction: () {},
                  ),
                  const SizedBox(height: 12),
                  _RevisionCategory(
                    iconAsset: 'assets/icons/figma/flag.svg',
                    title: 'Difficult cards',
                    count: '3 cards',
                    materialTitle: 'What does the Golgi apparatus do?',
                    materialMeta: 'Cell structures · Rated Hard last session',
                    actionLabel: 'Review difficult cards',
                    onAction: () => context.push(AppRoutes.cardFront),
                  ),
                  const SizedBox(height: 12),
                  _RevisionCategory(
                    iconAsset: 'assets/icons/figma/circle_x.svg',
                    title: 'Incorrect answers',
                    count: '3 questions',
                    materialTitle: 'How do substances cross a membrane?',
                    materialMeta: 'Cell structures · Latest quiz: 7/10',
                    note: 'Includes 2 unanswered questions.',
                    actionLabel: 'Review incorrect answers',
                    onAction: () => context.push(AppRoutes.review),
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

/// One revision category card: icon + title + count heading, a
/// representative material, an optional bold note, and a full-width
/// primary review button.
class _RevisionCategory extends StatelessWidget {
  const _RevisionCategory({
    required this.iconAsset,
    required this.title,
    required this.count,
    required this.materialTitle,
    required this.materialMeta,
    required this.actionLabel,
    required this.onAction,
    this.note,
  });

  final String iconAsset;
  final String title;
  final String count;
  final String materialTitle;
  final String materialMeta;
  final String? note;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ),
              Text(count, style: AppTextStyles.captionAccent),
            ],
          ),
          const SizedBox(height: 10),
          Text(materialTitle, style: AppTextStyles.itemTitle),
          const SizedBox(height: 3),
          Text(materialMeta, style: AppTextStyles.caption),
          if (note != null) ...[
            const SizedBox(height: 3),
            Text(
              note!,
              style: AppTextStyles.badge.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
