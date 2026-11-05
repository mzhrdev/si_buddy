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

/// Quiz question — True/False, implemented from the Figma frame
/// "SI Buddy · Quiz Question — True/False" (5:6006).
///
/// With a generated quiz this session, the statement comes from the
/// current true/false question; otherwise an honest empty state
/// shows — never the design's sample statement.
class QuizTrueFalseScreen extends ConsumerStatefulWidget {
  const QuizTrueFalseScreen({super.key});

  @override
  ConsumerState<QuizTrueFalseScreen> createState() => _QuizTrueFalseScreenState();
}

class _QuizTrueFalseScreenState extends ConsumerState<QuizTrueFalseScreen> {
  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final questions = (result?.questions ?? const [])
        .where((q) => q.type == QuizQuestionType.trueFalse)
        .toList();
    final question = questions.isEmpty ? null : questions.first;
    if (question == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
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
    final answers = ref.watch(quizAnswersProvider);
    final answeredCount = result!.questions
        .where(
          (q) =>
              answers.containsKey(q.prompt) ||
              ref.watch(quizShortAnswersProvider).containsKey(q.prompt),
        )
        .length;
    final total = questions.length;
    final options = [
      for (var i = 0; i < question.options.length; i++)
        (i == 0 ? 'T' : 'F', question.options[i]),
    ];
    final selected = answers[question.prompt] == null
        ? null
        : (answers[question.prompt] == 0 ? 'T' : 'F');
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        documentName:
                            job.source?.document.originalFileName,
                      ),
                      meta:
                          '${config.language} · $total questions · ${config.difficulty.label} · ${config.materialType.label}',
                    ),
                    const SizedBox(height: 16),
                    QuizProgressBar(
                      leftLabel: 'Question 1 of $total',
                      rightLabel: '$answeredCount / $total answered',
                      fraction: total == 0 ? 0 : answeredCount / total,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
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
                                  'TRUE/FALSE',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text('01 / $total', style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              question.prompt,
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Select one answer.',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                                color: AppColors.muted,
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
                        style: AppTextStyles.caption,
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
              onLeft: () => context.pop(),
              onRight: () => context.push(AppRoutes.shortAnswer),
              onLink: () => context.push(AppRoutes.unanswered),
            ),
          ],
        ),
      ),
    );
  }
}
