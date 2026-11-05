import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/quiz_bottom_bar.dart';
import '../widgets/quiz_progress.dart';
import '../../../ai_generation/domain/generation_models.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';

/// Quiz question — short answer, implemented from the Figma frame
/// "SI Buddy · Quiz Question — Short Answer" (5:6077). The answer
/// field is pre-filled with the design's answer text and is fully
/// editable; its border uses the primary colour as in the design.
class QuizShortAnswerScreen extends ConsumerStatefulWidget {
  const QuizShortAnswerScreen({super.key});

  @override
  ConsumerState<QuizShortAnswerScreen> createState() => _QuizShortAnswerScreenState();
}

class _QuizShortAnswerScreenState extends ConsumerState<QuizShortAnswerScreen> {
  final _controller = TextEditingController(
    text:
        'It controls what enters and leaves the cell, helping maintain '
        'a stable internal environment.',
  );
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
    final questions = (result?.questions ?? const [])
        .where((q) => q.type == QuizQuestionType.shortAnswer)
        .toList();
    final question = questions.isEmpty ? null : questions.first;
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final answeredCount = result == null
        ? 8
        : (result.questions
                .where((q) =>
                    answers.containsKey(q.prompt) ||
                    shortAnswers.containsKey(q.prompt))
                .length);
    final total = questions.isEmpty ? 10 : questions.length;
    if (question != null && _boundPrompt != question.prompt) {
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
                      title: question == null ? 'Cell structures' : config.topic,
                      meta: question == null
                          ? 'Biology · 10 questions · Medium · Mixed'
                          : '${config.language} · $total questions · ${config.difficulty.label} · ${config.materialType.label}',
                    ),
                    const SizedBox(height: 16),
                    QuizProgressBar(
                      leftLabel: question == null
                          ? 'Question 8 of 10'
                          : 'Question 1 of $total',
                      rightLabel: question == null
                          ? '8 / 10 answered'
                          : '$answeredCount / $total answered',
                      fraction: question == null
                          ? 0.8
                          : (total == 0 ? 0 : answeredCount / total),
                    ),
                    const SizedBox(height: 16),
                    const QuizTopicTimerRow(
                      topic: 'Membranes',
                      timeLeft: '04:10 left',
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
                                Text(question == null ? '08 / 10' : '01 / $total', style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              question?.prompt ??
                                  'What is the main function of the cell membrane?',
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
                                if (question != null) {
                                  ref
                                      .read(quizShortAnswersProvider.notifier)
                                      .answer(question.prompt, value);
                                }
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
