import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';
import '../../../study/presentation/providers/study_providers.dart';

/// Quiz results, implemented from the Figma frame
/// "SI Buddy · Quiz Results" (5:6216): score summary card, topic
/// performance bars and the follow-up actions. All actions are
/// primary buttons, matching the design.
///
/// The score comes from this session's answers on the generated
/// quiz. Without a quiz it shows an honest empty state — never the
/// design's sample score and topics.
///
/// Showing the results finishes the quiz (Phase 5): the attempt is
/// completed with the score and the study session ends with its
/// real duration, so the statistics' attempts, completion rate,
/// average score and study time are genuine.
class QuizResultsScreen extends ConsumerStatefulWidget {
  const QuizResultsScreen({super.key});

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  bool _finalized = false;
  String? _durationLabel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _finalize());
  }

  Future<void> _finalize() async {
    if (_finalized) return;
    _finalized = true;
    final result = ref.read(lastGenerationResultProvider);
    final questions = result?.questions ?? const [];
    if (questions.isEmpty) return;
    final answers = ref.read(quizAnswersProvider);
    final correct = questions
        .where(
          (q) => q.correctIndex != null && answers[q.prompt] == q.correctIndex,
        )
        .length;
    final tracker = ref.read(studySessionTrackerProvider.notifier);
    final elapsed = tracker.elapsedNow();
    unawaited(
      ref.read(generationJobProvider.notifier).completeQuizAttempt(correct),
    );
    await tracker.end();
    if (mounted && elapsed != null) {
      setState(() => _durationLabel = _formatDuration(elapsed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final questions = result?.questions ?? const [];
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Quiz results', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'No quiz results yet',
                  message:
                      'Take a generated quiz to see your score and review here.',
                  actionLabel: 'Generate a quiz',
                  onAction: () => context.pushReplacement(AppRoutes.quizSetup),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final correct = questions
        .where(
          (q) => q.correctIndex != null && answers[q.prompt] == q.correctIndex,
        )
        .length;
    final answered = questions
        .where(
          (q) =>
              answers.containsKey(q.prompt) ||
              (shortAnswers[q.prompt]?.trim().isNotEmpty ?? false),
        )
        .length;
    final total = questions.length;
    final correctCount = correct;
    final incorrectCount = total - correctCount;
    final unanswered = total - answered;
    final percent = total == 0 ? 0 : (correctCount * 100 ~/ total);
    final fraction = total == 0 ? 0.0 : correctCount / total;
    final topics = [
      (
        generatedMaterialTitle(
          config: config,
          documentName: job.source?.document.originalFileName,
        ),
        '$correctCount / $total correct · $percent%',
        fraction,
      ),
    ];
    final actionStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      textStyle: AppTextStyles.button(context),
    );
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Quiz results', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nice work, study buddy.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${generatedMaterialTitle(config: config, documentName: job.source?.document.originalFileName)} · $total questions · ${config.difficulty.label}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(context).copyWith(
                        fontSize: 12,
                        height: 18 / 12,
                        color: context.appMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.appCard,
                        border: Border.all(color: context.appBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$correctCount / $total',
                                      style: _scoreStyle(context.appText),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Questions correct',
                                      style: _subStyle(context),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$percent%',
                                    style: _scoreStyle(context.appPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _durationLabel == null
                                        ? 'Duration · —'
                                        : 'Duration · $_durationLabel',
                                    style: _subStyle(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: fraction,
                              minHeight: 6,
                              backgroundColor: context.appSurface,
                              valueColor: AlwaysStoppedAnimation(
                                context.appPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$correctCount correct',
                                style: _countStyle(context.appSuccessText),
                              ),
                              Text(
                                '$incorrectCount incorrect',
                                style: _countStyle(context.appDanger),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Includes $unanswered unanswered, counted as incorrect. Short answers are counted as answered, not scored.',
                            style: AppTextStyles.caption(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Topic performance',
                      style: AppTextStyles.body(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < topics.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _TopicResult(
                        name: topics[i].$1,
                        score: topics[i].$2,
                        fraction: topics[i].$3,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      style: actionStyle,
                      onPressed: () => context.push(AppRoutes.review),
                      child: const Text('Review Answers'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      style: actionStyle,
                      onPressed: () => context.pushReplacement(AppRoutes.quizSetup),
                      child: const Text('Retry Quiz'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      style: actionStyle,
                      onPressed: () => context.pushReplacement(AppRoutes.generationSetup),
                      child: const Text('Generate Flashcards from Mistakes'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Use your $incorrectCount missed questions to focus your next review.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => context.push(AppRoutes.history),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/figma/history.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                context.appPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'View Quiz History',
                              style: AppTextStyles.body(context).copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 18 / 13,
                                color: context.appPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  static TextStyle _scoreStyle(Color color) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 38 / 32,
    letterSpacing: -0.64,
    color: color,
  );

  static TextStyle _subStyle(BuildContext context) => AppTextStyles.body(
    context,
  ).copyWith(fontSize: 12, height: 18 / 12, color: context.appMuted);

  static TextStyle _countStyle(Color color) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: color,
  );

  static String _formatDuration(Duration elapsed) {
    final seconds = elapsed.inSeconds;
    if (seconds < 60) return '$seconds sec';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
  }
}

/// One topic row in the results: name, score label and progress bar.
class _TopicResult extends StatelessWidget {
  const _TopicResult({
    required this.name,
    required this.score,
    required this.fraction,
  });

  final String name;
  final String score;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppTextStyles.body(
                context,
              ).copyWith(fontSize: 13, height: 20 / 13),
            ),
            Text(
              score,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 16 / 12,
                color: context.appPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
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
