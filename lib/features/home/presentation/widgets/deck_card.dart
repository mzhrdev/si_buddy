import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/home_models.dart';

/// Card for one deck in "Pick up where you left off".
class DeckCard extends StatelessWidget {
  const DeckCard({required this.deck, required this.onTap, super.key});

  final DeckSummary deck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 94,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck.title,
                  style: AppTextStyles.itemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 7),
                Text(deck.stats, style: AppTextStyles.captionAccent),
                const SizedBox(height: 7),
                Text(deck.lastStudied, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
