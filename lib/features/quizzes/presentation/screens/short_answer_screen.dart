import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../widgets/quiz_bottom_bar.dart';
import '../widgets/quiz_progress.dart';
import '../../../ai_generation/domain/generation_models.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';

/// Quiz question — short answer, implemented from the Figma frame
/// "SI Buddy · Quiz Question — Short Answer" (5:6077). The answer
/// field starts empty and is fully editable; its border uses the
/// primary colour as in the design.
///
/// With a generated quiz this session, the question comes from the
/// current short-answer question; otherwise an honest empty state
/// shows — never the design's sample question and answer.
class QuizShortAnswerScreen extends ConsumerStatefulWidget {
  const QuizShortAnswerScreen({super.key});

  @override
  ConsumerState<QuizShortAnswerScreen> createState() => _QuizShortAnswerScreenState();
}

class _QuizShortAnswerScreenState extends ConsumerState<QuizShortAnswerScreen> {
  final _controller = TextEditingController();
  String? _boundPrompt;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final questions = (result?.questions ?? const [])
        .where((q) => q.type == QuizQuestionType.shortAnswer)
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
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final answeredCount = result!.questions
        .where(
          (q) =>
              answers.containsKey(q.prompt) ||
              shortAnswers.containsKey(q.prompt),
        )
        .length;
    final total = questions.length;
    if (_boundPrompt != question.prompt) {
      _boundPrompt = question.prompt;
      _controller.text = shortAnswers[question.prompt] ?? '';
    }
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
                                  'SHORT ANSWER',
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
                              'Your answer',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _controller,
                              onChanged: (value) {
                                ref
                                    .read(quizShortAnswersProvider.notifier)
                                    .answer(question.prompt, value);
                              },
                              maxLines: null,
                              minLines: 6,
                              style: AppTextStyles.body.copyWith(
                                height: 22 / 14,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(14),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
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
              onRight: () => context.push(AppRoutes.unanswered),
              onLink: () => context.push(AppRoutes.unanswered),
            ),
          ],
        ),
      ),
    );
  }
}
