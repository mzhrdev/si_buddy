import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Shared header for the study-card screens: deck identity, session
/// progress ("Card 4 of 20" · "3 reviewed · 15%") and the shuffle /
/// bookmark tools row. All values are the real session state —
/// callers pass the deck title, the card position and how many cards
/// have been rated this session.
class StudySessionHeader extends StatelessWidget {
  const StudySessionHeader({
    required this.title,
    required this.subtitle,
    required this.index,
    required this.total,
    required this.reviewed,
    required this.shuffleOn,
    required this.bookmarked,
    required this.onShuffleTap,
    required this.onBookmarkTap,
    super.key,
  });

  /// Deck title (the generation topic, or the source file name).
  final String title;

  /// Deck subtitle, e.g. 'English · 20 flashcards'.
  final String subtitle;

  /// Zero-based index of the card shown.
  final int index;

  /// Total cards in the deck.
  final int total;

  /// Cards rated this session.
  final int reviewed;

  final bool shuffleOn;
  final bool bookmarked;
  final VoidCallback onShuffleTap;
  final VoidCallback onBookmarkTap;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : reviewed / total;
    final percent = (fraction * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.screenTitle),
        const SizedBox(height: 3),
        Text(subtitle, style: AppTextStyles.caption),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Card ${index + 1} of $total',
                style: AppTextStyles.link.copyWith(height: 16 / 12),
              ),
            ),
            Text(
              '$reviewed reviewed · $percent%',
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                height: 18 / 12,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(100),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ToolAction(
                iconAsset: 'assets/icons/figma/shuffle.svg',
                label: shuffleOn ? 'Shuffle on' : 'Shuffle off',
                onTap: onShuffleTap,
              ),
              _ToolAction(
                iconAsset: 'assets/icons/figma/bookmark.svg',
                label: 'Bookmark',
                onTap: onBookmarkTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolAction extends StatelessWidget {
  const _ToolAction({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(width: 7),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              height: 18 / 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
