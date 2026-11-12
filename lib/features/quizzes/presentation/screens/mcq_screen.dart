import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/quiz_bottom_bar.dart';
import '../widgets/quiz_progress.dart';
import '../../../ai_generation/domain/generation_models.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';
import '../../../study/presentation/providers/study_providers.dart';

/// Quiz question — multiple choice, implemented from the Figma
/// frame "SI Buddy · Quiz Question — MCQ" (5:5927).
///
/// With a generated quiz this session, the question comes from the
/// current MCQ; otherwise an honest empty state shows — never the
/// design's sample question. Answers are presented as saved between
/// questions.
class QuizMcqScreen extends ConsumerStatefulWidget {
  const QuizMcqScreen({super.key});

  @override
  ConsumerState<QuizMcqScreen> createState() => _QuizMcqScreenState();
}

class _QuizMcqScreenState extends ConsumerState<QuizMcqScreen> {
  @override
  void initState() {
    super.initState();
    // Taking the quiz starts a study session (Phase 5): the
    // results screen ends it with its real duration. The tracker
    // ignores the call when a session for this deck is already open
    // (the `loadDeck` path).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckId = ref.read(generationJobProvider).deckId;
      if (deckId == null) return;
      unawaited(
        ref
            .read(studySessionTrackerProvider.notifier)
            .start(deckId: deckId, type: 'quiz'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final questions = (result?.questions ?? const [])
        .where((q) => q.type == QuizQuestionType.mcq)
        .toList();
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Quiz', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'No quiz questions yet',
                  message:
                      'Generate a quiz from a document to answer questions here.',
                  actionLabel: 'Generate a quiz',
                  onAction: () => context.push(AppRoutes.quizSetup),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final total = questions.length;
    final index = ref.watch(quizQuestionIndexProvider).clamp(0, total - 1);
    final question = questions[index];
    final answers = ref.watch(quizAnswersProvider);
    final answeredCount = result!.questions
        .where(
          (q) =>
              answers.containsKey(q.prompt) ||
              ref.watch(quizShortAnswersProvider).containsKey(q.prompt),
        )
        .length;
    final options = [
      for (var i = 0; i < question.options.length; i++)
        (String.fromCharCode('A'.codeUnitAt(0) + i), question.options[i]),
    ];
    final selected = answers[question.prompt] == null
        ? null
        : String.fromCharCode('A'.codeUnitAt(0) + answers[question.prompt]!);
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Quiz', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QuizIdentity(
                      title: generatedMaterialTitle(
                        config: config,
                        documentName: job.source?.document.originalFileName,
                      ),
                      meta:
                          '${config.language} · $total questions · ${config.difficulty.label} · ${config.materialType.label}',
                    ),
                    const SizedBox(height: 16),
                    QuizProgressBar(
                      leftLabel: 'Question ${index + 1} of $total',
                      rightLabel: '$answeredCount / $total answered',
                      fraction: total == 0 ? 0 : answeredCount / total,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.appBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'MULTIPLE CHOICE',
                                  style: AppTextStyles.caption(context)
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: context.appPrimary,
                                      ),
                                ),
                                Text(
                                  '${(index + 1).toString().padLeft(2, '0')} / $total',
                                  style: AppTextStyles.caption(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              question.prompt,
                              style: AppTextStyles.screenTitle(context),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Select one answer.',
                              style: AppTextStyles.body(context).copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                                color: context.appMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (var i = 0; i < options.length; i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              AnswerOptionTile(
                                marker: options[i].$1,
                                label: options[i].$2,
                                selected: selected == options[i].$1,
                                onTap: () {
                                  ref
                                      .read(quizAnswersProvider.notifier)
                                      .answer(question.prompt, i);
                                  // Persisted (Phase 5): the answer
                                  // joins the quiz attempt, so quiz
                                  // progress survives a restart.
                                  unawaited(
                                    ref
                                        .read(generationJobProvider.notifier)
                                        .recordQuizAnswer(
                                          prompt: question.prompt,
                                          selectedIndex: i,
                                        ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Answers are saved as you move between questions.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            QuizBottomBar(
              leftLabel: 'Previous',
              rightLabel: 'Next',
              linkLabel: 'Submit Quiz',
              onLeft: () {
                if (index > 0) {
                  ref.read(quizQuestionIndexProvider.notifier).previous();
                } else {
                  context.pop();
                }
              },
              // Next moves within this quiz's questions; on the last
              // one it opens the submit check instead of wandering
              // to another question type's (empty) screen.
              onRight: () {
                if (index >= total - 1) {
                  context.push(AppRoutes.unanswered);
                } else {
                  ref.read(quizQuestionIndexProvider.notifier).next(total);
                }
              },
              onLink: () => context.push(AppRoutes.unanswered),
            ),
          ],
        ),
      ),
    );
  }
}
