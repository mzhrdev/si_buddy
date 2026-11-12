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
        Text(title, style: titleStyle ?? AppTextStyles.screenTitle(context)),
        const SizedBox(height: 3),
        Text(meta, style: AppTextStyles.caption(context)),
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
    this.rightLabelColor,
    super.key,
  });

  final String leftLabel;
  final String rightLabel;
  final double fraction;
  /// Null reads as the muted color.
  final Color? rightLabelColor;

  @override
  Widget build(BuildContext context) {
    final rightColor = rightLabelColor ?? context.appMuted;
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
              style: labelStyle.copyWith(color: context.appPrimary),
            ),
            Text(
              rightLabel,
              style: labelStyle.copyWith(
                color: rightColor,
                fontWeight: rightLabelColor == null
                    ? FontWeight.w400
                    : FontWeight.w600,
                height: rightLabelColor == null ? 18 / 12 : 16 / 12,
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
            backgroundColor: context.appSurface,
            valueColor: AlwaysStoppedAnimation(context.appPrimary),
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
            style: AppTextStyles.body(context).copyWith(
              fontSize: 12,
              height: 18 / 12,
              color: context.appMuted,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/figma/timer.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  context.appPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                timeLeft,
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: context.appPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
