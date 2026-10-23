import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/study_destinations_bar.dart';
import '../widgets/study_progress_track.dart';

/// Statistics Dashboard, implemented from the Figma frame
/// "SI Buddy · Statistics Dashboard" (5:11802): weekly totals, the
/// daily study-time chart, and per-topic strengths from the latest
/// quiz.
class StatisticsDashboardScreen extends StatelessWidget {
  const StatisticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Statistics'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                children: [
                  const StudyDestinationsBar(currentIndex: 2),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'This week',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                          ),
                        ),
                      ),
                      const Text(
                        '12–18 Oct 2026',
                        style: AppTextStyles.greeting,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _StudyMetric(
                          value: '55 min',
                          label: 'Study time',
                          sub: 'Today: 15 min',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StudyMetric(
                          value: '84',
                          label: 'Cards reviewed',
                          sub: 'Today: 24 reviews',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _StudyMetric(
                          value: '3',
                          label: 'Quizzes completed',
                          sub: 'Today: 1 attempt',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StudyMetric(
                          value: '60%',
                          label: 'Average score',
                          sub: '18/30 correct · 3 attempts',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _WeeklyActivityCard(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Topic strengths',
                          style: AppTextStyles.title,
                        ),
                      ),
                      Text('Latest quiz', style: AppTextStyles.link),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _TopicStrength(
                    topic: 'Cell basics',
                    score: '3/4 correct · 75%',
                    fraction: 0.75,
                  ),
                  const SizedBox(height: 10),
                  const _TopicStrength(
                    topic: 'Organelles',
                    score: '3/4 correct · 75%',
                    fraction: 0.75,
                  ),
                  const SizedBox(height: 10),
                  const _TopicStrength(
                    topic: 'Membranes',
                    score: '1/2 correct · 50%',
                    fraction: 0.5,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cell structures · 16 Oct · 70% overall',
                    style: AppTextStyles.badge.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One weekly total: a large value, a semibold label, and a bold
/// muted "today" line, in a white bordered card.
class _StudyMetric extends StatelessWidget {
  const _StudyMetric({
    required this.value,
    required this.label,
    required this.sub,
  });

  final String value;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.headline.copyWith(letterSpacing: -0.48),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            style: AppTextStyles.badge.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Bordered card with the daily study-time bar chart for the week.
/// Bars are surface-selected except today (Friday), which is primary;
/// bar height is 1.7px per minute with a 2px minimum.
class _WeeklyActivityCard extends StatelessWidget {
  const _WeeklyActivityCard();

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _minutes = [0, 0, 18, 22, 15, 0, 0];
  static const _todayIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Weekly activity', style: AppTextStyles.title),
              ),
              Text('Minutes', style: AppTextStyles.link),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < _days.length; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                Expanded(
                  child: _DayBar(
                    day: _days[i],
                    minutes: _minutes[i],
                    isToday: i == _todayIndex,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Week to date · Fri 16 Oct · 3-day streak',
            style: AppTextStyles.badge.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// One day column of the weekly chart: value label over a bottom
/// aligned bar, with the day label underneath.
class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.minutes,
    required this.isToday,
  });

  final String day;
  final int minutes;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.badge.copyWith(
      color: isToday ? AppColors.primary : AppColors.muted,
    );
    return Column(
      children: [
        SizedBox(
          height: 69,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('$minutes', style: labelStyle),
              const SizedBox(height: 7),
              Container(
                width: 25,
                height: minutes == 0 ? 2.0 : minutes * 1.7,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(day, style: labelStyle),
      ],
    );
  }
}

/// One topic strength row: topic name and score over a progress track.
class _TopicStrength extends StatelessWidget {
  const _TopicStrength({
    required this.topic,
    required this.score,
    required this.fraction,
  });

  final String topic;
  final String score;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                topic,
                style: AppTextStyles.greeting.copyWith(color: AppColors.text),
              ),
            ),
            Text(score, style: AppTextStyles.captionAccent),
          ],
        ),
        const SizedBox(height: 5),
        StudyProgressTrack(fraction: fraction),
      ],
    );
  }
}
