import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// White bordered card showing the selected document: a "PDF" format
/// box, the file name and a metadata line. Shared by the extraction
/// processing, review and success screens.
class SelectedDocumentCard extends StatelessWidget {
  const SelectedDocumentCard({
    required this.title,
    required this.subtitle,
    this.formatLabel = 'PDF',
    super.key,
  });

  final String title;
  final String subtitle;

  /// The label inside the format box (`PDF`, `PPTX`).
  final String formatLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(formatLabel, style: AppTextStyles.badge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.itemTitle.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
