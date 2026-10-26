import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The preserved generation selections shown on the processing and
/// error frames (Figma "Preserved selections"): the setup choices the
/// user made, kept while generation runs or after it fails.
///
/// Defaults show the design's sample selections; a running job
/// passes the lines composed from its [GenerationConfig].
class GenerationSelections extends StatelessWidget {
  const GenerationSelections({
    super.key,
    this.summaryLine = '20 flashcards · Medium · English',
    this.detailLine = 'Cell structures · Explanations on',
  });

  /// '20 flashcards · Medium · English'
  final String summaryLine;

  /// 'Cell structures · Explanations on'
  final String detailLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your selections',
          style: AppTextStyles.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          summaryLine,
          style: AppTextStyles.muted.copyWith(height: 20 / 13),
        ),
        Text(
          detailLine,
          style: AppTextStyles.muted.copyWith(height: 20 / 13),
        ),
      ],
    );
  }
}
