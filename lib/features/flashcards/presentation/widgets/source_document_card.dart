import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The source-document row shown on the deck overview and card editor:
/// a bordered format chip plus the file name and metadata. Callers
/// pass the real document; with none, it renders an honest "no
/// source document" row instead of the design's sample.
class SourceDocumentCard extends StatelessWidget {
  const SourceDocumentCard({super.key, this.title, this.subtitle, this.formatLabel});

  /// File name shown as the card's title; null renders the empty row.
  final String? title;

  /// Metadata line under the title.
  final String? subtitle;

  /// Short format label inside the file glyph.
  final String? formatLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 42,
            decoration: BoxDecoration(
              color: context.appCard,
              border: Border.all(color: context.appBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
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
                  style: AppTextStyles.captionStrong(context).copyWith(
                    fontSize: 12,
                    color: context.appText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle ?? 'Import a document to generate from it',
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
