import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/layout/responsive_spacing.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/study_models.dart';
import '../providers/study_providers.dart';
import '../widgets/study_destinations_bar.dart';

/// Statistics Dashboard, implemented from the Figma frame
/// "SI Buddy · Statistics Dashboard" (5:11802).
///
/// Every number comes from the persisted study data
/// ([studyStatsProvider] + [dailyActivityProvider]): decks
/// generated, cards reviewed, quiz attempts with completion rate
/// and average score, tracked study time, the current streak, and
/// the last 7 days of study minutes. Nothing is fabricated — a
/// metric with no data yet reads 0 or "—", and the weekly chart
/// says so when the week is empty.
class StatisticsDashboardScreen extends ConsumerWidget {
  const StatisticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `.value ?? fallback` (not `.when(loading: spinner)`): the
    // providers read the local database, which resolves in
    // milliseconds on a device — but the values start as null, and
    // a spinner here would spin forever in environments where the
    // database never answers (widget tests). Zeros are the honest
    // interim state; the real numbers arrive as soon as the query
    // returns.
    final statsAsync = ref.watch(studyStatsProvider);
    final activityAsync = ref.watch(dailyActivityProvider);
    final stats = statsAsync.value ?? StudyStats.empty;
    final activity = activityAsync.value ?? const <DailyActivity>[];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Statistics'),
            Expanded(
              child: ListView(
                padding: ResponsiveSpacing.page(context, bottom: 20),
                children: [
                  const StudyDestinationsBar(currentIndex: 0),
                  const SizedBox(height: 16),
                  if (statsAsync.hasError || activityAsync.hasError)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Could not load your statistics. Try reopening this tab.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  _StatsGrid(stats: stats),
                  const SizedBox(height: 20),
                  Text('Last 7 days', style: AppTextStyles.title(context)),
                  const SizedBox(height: 4),
                  Text(
                    'Minutes studied per day, from your tracked sessions.',
                    style: AppTextStyles.caption(context),
                  ),
                  const SizedBox(height: 12),
                  _WeeklyChart(activity: activity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The all-time statistics, as a two-column grid of metric cards.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final StudyStats stats;

  @override
  Widget build(BuildContext context) {
    final completion = stats.totalQuizzesAttempted == 0
        ? '—'
        : '${(stats.quizCompletionRate * 100).round()}%';
    final average = stats.averageQuizScore == null
        ? '—'
        : '${(stats.averageQuizScore! * 100).round()}%';
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Fixed tile height: the tallest card (value + label + a
      // two-line caption) needs ~112px; a ratio-based height
      // overflowed on narrow screens.
      mainAxisExtent: 120,
      children: [
        _StatCard(
          label: 'Flashcards generated',
          value: '${stats.totalFlashcardsGenerated}',
        ),
        _StatCard(
          label: 'Quizzes generated',
          value: '${stats.totalQuizzesGenerated}',
        ),
        _StatCard(label: 'Cards reviewed', value: '${stats.cardsReviewed}'),
        _StatCard(
          label: 'Quizzes attempted',
          value: '${stats.totalQuizzesAttempted}',
        ),
        _StatCard(
          label: 'Quiz completion rate',
          value: completion,
          caption: stats.totalQuizzesAttempted == 0
              ? 'No quizzes attempted yet'
              : '${stats.quizzesCompleted} of ${stats.totalQuizzesAttempted} finished',
        ),
        _StatCard(
          label: 'Average quiz score',
          value: average,
          caption: stats.averageQuizScore == null
              ? 'No quiz finished yet'
              : null,
        ),
        _StatCard(
          label: 'Total study time',
          value: _formatDuration(stats.totalStudySeconds),
        ),
        _StatCard(
          label: 'Current streak',
          value: stats.streakDays == 0
              ? '0 days'
              : '${stats.streakDays} day${stats.streakDays == 1 ? '' : 's'}',
          caption: stats.streakDays == 0
              ? 'Study on consecutive days to start one'
              : null,
        ),
      ],
    );
  }
}

/// One metric card: a big value and a label, with an optional
/// explanatory caption.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.caption});

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.display(context).copyWith(fontSize: 24, height: 1.2),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption(context)),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: AppTextStyles.caption(context).copyWith(color: context.appMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Seven bars, one per day, of minutes studied. The tallest day
/// fills the chart; days with no studying show a flat baseline.
class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.activity});

  final List<DailyActivity> activity;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxMinutes = activity.fold<int>(
      0,
      (max, day) => day.studyMinutes > max ? day.studyMinutes : max,
    );
    if (maxMinutes == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appCard,
          border: Border.all(color: context.appBorder),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'No study activity in the last 7 days. Study a deck or take a quiz and it will show up here.',
          style: TextStyle(color: context.appMuted),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < activity.length; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activity[i].studyMinutes == 0
                        ? ''
                        : '${activity[i].studyMinutes}m',
                    style: AppTextStyles.badge(context).copyWith(
                      color: context.appPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height:
                        100 *
                        (activity[i].studyMinutes / maxMinutes).clamp(
                          0.04,
                          1.0,
                        ),
                    decoration: BoxDecoration(
                      color: activity[i].studyMinutes == 0
                          ? context.appBorder
                          : context.appPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dayLetters[(activity[i].date.weekday - 1) % 7],
                    style: AppTextStyles.caption(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
}
