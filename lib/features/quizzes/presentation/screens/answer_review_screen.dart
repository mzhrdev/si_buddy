import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/quiz_bottom_bar.dart';
import '../widgets/quiz_progress.dart';

/// Answer review, implemented from the Figma frame
/// "SI Buddy · Answer Review" (5:6297): the reviewed question with
/// the user's (incorrect) answer, the correct answer, an explanation
/// and the source reference. Previous / Next step through the review
/// locally (the content shown is the design's Question 3).
class AnswerReviewScreen extends StatelessWidget {
  const AnswerReviewScreen({super.key});

  // Figma: success-surface
  static const _successSurface = AppColors.successSurface;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Answer review', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const QuizIdentity(
                      title: 'Cell structures',
                      meta: '7 correct · 3 incorrect, including 2 unanswered',
                    ),
                    const SizedBox(height: 16),
                    const QuizProgressBar(
                      leftLabel: 'Question 3 of 10',
                      rightLabel: 'Incorrect',
                      rightLabelColor: AppColors.danger,
                      fraction: 0.3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cell basics · Multiple choice',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'What is the basic unit of life?',
                      style: AppTextStyles.screenTitle,
                    ),
                    const SizedBox(height: 14),
                    _AnswerCard(
                      background: AppColors.dangerSurface,
                      iconAsset: 'assets/icons/figma/circle_x.svg',
                      iconColor: AppColors.danger,
                      label: 'Your answer',
                      labelColor: AppColors.danger,
                      value: 'B · A tissue',
                    ),
                    const SizedBox(height: 14),
                    _AnswerCard(
                      background: _successSurface,
                      iconAsset: 'assets/icons/figma/check_circle_2.svg',
                      iconColor: AppColors.success,
                      label: 'Correct answer',
                      labelColor: AppColors.successText,
                      value: 'C · The cell',
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why this is correct',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Cells are the basic unit of life. Each cell '
                            'contains structures that work together to '
                            'support its functions. A tissue is a group of '
                            'similar cells working together.',
                            style: AppTextStyles.muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/figma/file_text.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Source · Page 1 of 12',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cell Biology - Chapter 4.pdf',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            QuizBottomBar(
              leftLabel: 'Previous',
              rightLabel: 'Next',
              linkLabel: 'Back to Results',
              onLeft: () => context.pop(),
              // TODO(backend): step to the next reviewed question.
              onRight: () {},
              onLink: () => context.push(AppRoutes.results),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coloured answer comparison card: status icon beside a small
/// label and the answer text.
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.background,
    required this.iconAsset,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    required this.value,
  });

  final Color background;
  final String iconAsset;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: labelColor),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
