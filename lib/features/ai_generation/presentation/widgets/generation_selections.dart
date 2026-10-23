import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The preserved generation selections shown on the processing and
/// error frames (Figma "Preserved selections"): the setup choices the
/// user made, kept while generation runs or after it fails.
class GenerationSelections extends StatelessWidget {
  const GenerationSelections({super.key});

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
          '20 flashcards · Medium · English',
          style: AppTextStyles.muted.copyWith(height: 20 / 13),
        ),
        Text(
          'Cell structures · Explanations on',
          style: AppTextStyles.muted.copyWith(height: 20 / 13),
        ),
      ],
    );
  }
}
