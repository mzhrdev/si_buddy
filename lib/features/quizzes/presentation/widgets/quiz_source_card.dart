import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Source document card shown on the quiz setup and quiz history
/// screens: a bordered format box beside the document title and
/// metadata. Callers pass the real document; with none, it renders
/// an honest "no source document" card instead of the design's
/// sample.
class QuizSourceCard extends StatelessWidget {
  const QuizSourceCard({super.key, this.title, this.subtitle, this.formatLabel});

  /// File name shown as the card's title; null renders the empty card.
  final String? title;

  /// Metadata line under the title.
  final String? subtitle;

  /// Short format label inside the file glyph.
  final String? formatLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              formatLabel ?? '—',
              style: AppTextStyles.badge(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'No source document',
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 16 / 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle ?? 'Import a document to generate a quiz from it',
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
