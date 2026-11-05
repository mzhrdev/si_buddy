import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';
import '../widgets/study_destinations_bar.dart';
import '../widgets/study_progress_track.dart';
import '../widgets/study_section_heading.dart';

/// Study Planner, implemented from the Figma frame
/// "SI Buddy · Study Planner" (5:11948): today's goal progress, the
/// upcoming revision schedule, and the optional revision reminder.
///
/// The daily goals are the design's targets (20 minutes, 30 cards,
/// 1 quiz); the progress against them is this session's real state.
/// Study time is not tracked yet, so that goal honestly reads
/// "Not tracked". Upcoming revision lists only what is real: today's
/// learning and difficult cards, when there are any.
class StudyPlannerScreen extends ConsumerStatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  ConsumerState<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends ConsumerState<StudyPlannerScreen> {
  bool _reminderOn = false;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final ratings = ref.watch(cardRatingsProvider);
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final cards = result?.flashcards ?? const [];
    final questions = result?.questions ?? const [];
    final reviewed = ratings.length;
    final quizDone = questions.any(
      (q) =>
          answers.containsKey(q.prompt) ||
          (shortAnswers[q.prompt]?.trim().isNotEmpty ?? false),
    );
    final learning = ratings.values.where((r) => r == 'Medium').length;
    final difficult = ratings.values.where((r) => r == 'Hard').length;
    final toReview = learning + difficult;
    final completedGoals = (reviewed >= 30 ? 1 : 0) + (quizDone ? 1 : 0);
    final now = DateTime.now();
    final title = generatedMaterialTitle(
      config: config,
      documentName: job.source?.document.originalFileName,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Study planner'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                children: [
                  const StudyDestinationsBar(currentIndex: 3),
                  const SizedBox(height: 12),
                  StudySectionHeading(
                    title: 'Today, ${now.day} ${_months[now.month - 1]}',
                    actionLabel: 'Edit goals',
                    // TODO(backend): edit the daily goals.
                    onAction: () {},
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedGoals of 3 goals complete · A little every day adds up.',
                    style: AppTextStyles.greeting,
                  ),
                  const SizedBox(height: 12),
                  _DailyGoalsCard(reviewed: reviewed, quizDone: quizDone),
                  const SizedBox(height: 12),
                  StudySectionHeading(
                    title: 'Upcoming revision',
                    actionLabel: '+ Add',
                    // TODO(backend): schedule a revision session.
                    onAction: () {},
                  ),
                  const SizedBox(height: 10),
                  _PlannedRevision(
                    day: 'Today',
                    title: cards.isEmpty ? 'No deck yet' : title,
                    meta: cards.isEmpty
                        ? 'Generate flashcards to plan revision'
                        : toReview > 0
                            ? '$toReview learning & difficult cards'
                            : 'Nothing due today',
                  ),
                  const SizedBox(height: 12),
                  _ReminderCard(
                    reminderOn: _reminderOn,
                    onToggle: (value) => setState(() => _reminderOn = value),
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

/// White bordered card with the three daily goals and their progress.
/// Study time is not tracked yet; the other two goals read this
/// session's real progress.
class _DailyGoalsCard extends StatelessWidget {
  const _DailyGoalsCard({required this.reviewed, required this.quizDone});

  /// Cards rated this session.
  final int reviewed;

  /// Whether any quiz question was answered this session.
  final bool quizDone;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Daily goals', style: AppTextStyles.itemTitle),
              ),
              Text(
                'Completed / target',
                style: AppTextStyles.badge.copyWith(color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _DailyGoal(
            label: 'Study time',
            value: 'Not tracked',
            fraction: 0,
            complete: false,
          ),
          const SizedBox(height: 14),
          _DailyGoal(
            label: 'Review flashcards',
            value: '$reviewed / 30 cards',
            fraction: (reviewed / 30).clamp(0.0, 1.0),
            complete: reviewed >= 30,
          ),
          const SizedBox(height: 14),
          _DailyGoal(
            label: 'Complete a quiz',
            value: quizDone ? '1 / 1 quiz' : '0 / 1 quiz',
            fraction: quizDone ? 1 : 0,
            complete: quizDone,
          ),
        ],
      ),
    );
  }
}

/// One daily goal row: a state icon (empty circle, or circle-check
/// when complete) beside the label/value row and progress track.
class _DailyGoal extends StatelessWidget {
  const _DailyGoal({
    required this.label,
    required this.value,
    required this.fraction,
    required this.complete,
  });

  final String label;
  final String value;
  final double fraction;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 16 / 12,
    );
    return Row(
      children: [
        SvgPicture.asset(
          complete
              ? 'assets/icons/figma/circle_check.svg'
              : 'assets/icons/figma/circle.svg',
          width: 21,
          height: 21,
          colorFilter: ColorFilter.mode(
            complete ? AppColors.primary : AppColors.navInactive,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: labelStyle.copyWith(color: AppColors.text),
                    ),
                  ),
                  Text(
                    value,
                    style: labelStyle.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              StudyProgressTrack(fraction: fraction),
            ],
          ),
        ),
      ],
    );
  }
}

/// One planned revision row: a primary day label column beside the
/// session title and a bold muted meta line.
class _PlannedRevision extends StatelessWidget {
  const _PlannedRevision({
    required this.day,
    required this.title,
    required this.meta,
  });

  final String day;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 57,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: AppTextStyles.badge.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.itemTitle),
                const SizedBox(height: 3),
                Text(
                  meta,
                  style: AppTextStyles.badge.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bordered card with the optional revision reminder: a label and
/// status, the square toggle, the preferred-time chip, and the
/// explanatory note.
class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminderOn, required this.onToggle});

  final bool reminderOn;
  final ValueChanged<bool> onToggle;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revision reminder',
                      style: AppTextStyles.itemTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reminderOn ? 'Optional · On' : 'Optional · Off',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              _ReminderToggle(value: reminderOn, onToggle: onToggle),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text('Preferred time', style: AppTextStyles.greeting),
              ),
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 9),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('7:00 PM', style: AppTextStyles.greeting),
                    const SizedBox(width: 6),
                    SvgPicture.asset(
                      'assets/icons/figma/clock.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        AppColors.navInactive,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'No reminder is scheduled. Enabling will ask for notification '
            'permission if needed.',
            style: AppTextStyles.badge.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// The square SI Buddy toggle (40×24, radius 4): a border-colored
/// track with a white thumb when off, a primary track when on.
class _ReminderToggle extends StatelessWidget {
  const _ReminderToggle({required this.value, required this.onToggle});

  final bool value;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
