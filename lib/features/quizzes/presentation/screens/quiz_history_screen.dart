import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/quiz_progress.dart';
import '../widgets/quiz_source_card.dart';

/// Quiz history, implemented from the Figma frame
/// "SI Buddy · Quiz History" (5:6367): the quiz and its source
/// document, followed by the previous attempts with review and
/// retry actions for each attempt.
class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  static const _attempts = [
    _Attempt(
      date: '16 Oct 2026 · 9:41 AM',
      latest: true,
      score: '7 / 10',
      percent: '70%',
      duration: '6m 24s',
    ),
    _Attempt(
      date: '15 Oct 2026 · 6:20 PM',
      latest: false,
      score: '6 / 10',
      percent: '60%',
      duration: '7m 12s',
    ),
    _Attempt(
      date: '14 Oct 2026 · 8:05 PM',
      latest: false,
      score: '5 / 10',
      percent: '50%',
      duration: '8m 03s',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Quiz history', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const QuizIdentity(
                      title: 'Cell structures',
                      meta: 'Biology · 10 questions · Medium · Mixed',
                      titleStyle: AppTextStyles.display,
                    ),
                    const SizedBox(height: 16),
                    const QuizSourceCard(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Previous attempts',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                          ),
                        ),
                        Text(
                          '3 attempts',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < _attempts.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _AttemptCard(attempt: _attempts[i]),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/figma/check_circle_2.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Saved quizzes can be studied offline.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock data for one previous quiz attempt.
class _Attempt {
  const _Attempt({
    required this.date,
    required this.latest,
    required this.score,
    required this.percent,
    required this.duration,
  });

  final String date;
  final bool latest;
  final String score;
  final String percent;
  final String duration;
}

/// One attempt card: date (with a LATEST tag on the newest attempt),
/// score + percentage + duration, and Review / Retry Quiz actions.
class _AttemptCard extends StatelessWidget {
  const _AttemptCard({required this.attempt});

  final _Attempt attempt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                attempt.date,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                ),
              ),
              if (attempt.latest)
                Text(
                  'LATEST',
                  style: AppTextStyles.badge.copyWith(color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(attempt.score, style: AppTextStyles.headline),
              const SizedBox(width: 8),
              Text(
                attempt.percent,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                attempt.duration,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  height: 18 / 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AttemptAction(
                  iconAsset: 'assets/icons/figma/list_checks.svg',
                  label: 'Review',
                  onTap: () => context.push(AppRoutes.review),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AttemptAction(
                  iconAsset: 'assets/icons/figma/rotate_ccw.svg',
                  label: 'Retry Quiz',
                  onTap: () => context.push(AppRoutes.quizSetup),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 36px bordered action button inside an attempt card.
class _AttemptAction extends StatelessWidget {
  const _AttemptAction({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 15,
                height: 15,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
