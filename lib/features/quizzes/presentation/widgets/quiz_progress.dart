import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Quiz title block used at the top of the question, review and
/// history screens: quiz name over a one-line metadata summary.
class QuizIdentity extends StatelessWidget {
  const QuizIdentity({
    required this.title,
    required this.meta,
    this.titleStyle,
    super.key,
  });

  final String title;
  final String meta;

  /// Defaults to the 20px screen-title style; the history screen
  /// uses the 24px display style instead.
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle ?? AppTextStyles.screenTitle),
        const SizedBox(height: 3),
        Text(meta, style: AppTextStyles.caption),
      ],
    );
  }
}

/// Labelled progress bar from the quiz question and answer review
/// screens: a primary label on the left, a status label on the
/// right, and a 6px rounded track filled to [fraction].
class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    required this.leftLabel,
    required this.rightLabel,
    required this.fraction,
    this.rightLabelColor = AppColors.muted,
    super.key,
  });

  final String leftLabel;
  final String rightLabel;
  final double fraction;
  final Color rightLabelColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: labelStyle.copyWith(color: AppColors.primary),
            ),
            Text(
              rightLabel,
              style: labelStyle.copyWith(
                color: rightLabelColor,
                fontWeight: rightLabelColor == AppColors.muted
                    ? FontWeight.w400
                    : FontWeight.w600,
                height: rightLabelColor == AppColors.muted ? 18 / 12 : 16 / 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

/// Row under the progress bar on the question screens: the current
/// topic on the left and the remaining time (timer icon + label in
/// primary) on the right.
class QuizTopicTimerRow extends StatelessWidget {
  const QuizTopicTimerRow({
    required this.topic,
    required this.timeLeft,
    super.key,
  });

  final String topic;
  final String timeLeft;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            topic,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              height: 18 / 12,
              color: AppColors.muted,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/figma/timer.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                timeLeft,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
