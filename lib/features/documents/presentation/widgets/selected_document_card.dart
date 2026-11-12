import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// White bordered card showing the selected document: a "PDF" format
/// box, the file name and a metadata line. Shared by the extraction
/// processing, review and success screens.
///
/// All fields are nullable: a null title renders "No document" and
/// a null subtitle hides the metadata line, instead of the design's
/// sample document.
class SelectedDocumentCard extends StatelessWidget {
  const SelectedDocumentCard({
    this.title,
    this.subtitle,
    this.formatLabel,
    super.key,
  });

  final String? title;
  final String? subtitle;

  /// The label inside the format box (`PDF`, `PPTX`).
  final String? formatLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.appChip,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              formatLabel ?? '–',
              style: AppTextStyles.badge(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'No document',
                  style: AppTextStyles.itemTitle(
                    context,
                  ).copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(subtitle!, style: AppTextStyles.caption(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
