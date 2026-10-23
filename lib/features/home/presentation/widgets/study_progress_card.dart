import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/home_models.dart';

/// The blue summary card at the top of Home: on-device model status,
/// today's study metrics, and the daily-goal progress bar.
class StudyProgressCard extends StatelessWidget {
  const StudyProgressCard({required this.progress, super.key});

  final StudyProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma/ready_indicator.svg',
                width: 8,
                height: 8,
                colorFilter: progress.modelReady
                    ? null
                    : const ColorFilter.mode(
                        AppColors.navInactive,
                        BlendMode.srcIn,
                      ),
              ),
              const SizedBox(width: 6),
              Text(
                progress.modelReady
                    ? 'AI Ready Offline'
                    : 'AI Model Not Installed',
                style: progress.modelReady
                    ? AppTextStyles.successLabel
                    : AppTextStyles.tileLabel,
              ),
              const Spacer(),
              Text(
                '${progress.streakDays}-day streak',
                style: AppTextStyles.captionStrong,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: '${progress.cardsReviewed}',
                  label: 'Cards reviewed',
                ),
              ),
              Expanded(
                child: _Metric(
                  value: '${progress.minutesStudied} min',
                  label: 'Studied today',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Daily goal · ${progress.minutesRemaining} min to go',
                  style: AppTextStyles.caption,
                ),
              ),
              Text(
                '${progress.minutesStudied} / ${progress.dailyGoalMinutes} min',
                style: AppTextStyles.captionStrong,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.goalFraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.headline),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
