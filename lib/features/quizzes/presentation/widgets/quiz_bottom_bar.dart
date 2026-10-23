import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Bottom action bar from the quiz question and answer review
/// screens: two 48px primary buttons side by side over a centred
/// text link, on a white strip with a top border.
class QuizBottomBar extends StatelessWidget {
  const QuizBottomBar({
    required this.leftLabel,
    required this.rightLabel,
    required this.linkLabel,
    required this.onLeft,
    required this.onRight,
    required this.onLink,
    super.key,
  });

  final String leftLabel;
  final String rightLabel;
  final String linkLabel;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(0, 48),
      textStyle: AppTextStyles.button,
    );
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: buttonStyle,
                    onPressed: onLeft,
                    child: Text(leftLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: buttonStyle,
                    onPressed: onRight,
                    child: Text(rightLabel),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 32,
              child: Center(
                child: TextButton(
                  onPressed: onLink,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    linkLabel,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 18 / 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
